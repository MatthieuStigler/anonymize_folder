library(digest)
library(tidyverse)
# library(magrittr)

## utility function: vectorized digest
digest_vect <- function(x, trim=-1L) map_chr(x, ~digest(., algo="sha256")) %>%
  str_sub(end=trim)

## quick check
# digest_vect(c("Bob", "Bil"))


## main function
ano <- function(dir, cols_id = c("pers", "address"), extension=c("csv","dta"), overwrite=FALSE, trim=-1L){
  extension <- match.arg(extension)
  if(extension=="dta") require(haven)
  ext_full <- paste(extension, "$", sep="") # regexp: ends with extension
  files <- list.files(dir, recursive = TRUE, full.names = TRUE, pattern=ext_full)
  
  ## read/write functions
  read_fun <- switch(extension, "csv"= read_csv, "dta"=read_dta)
  write_fun <- switch(extension, "csv"= write_csv, "dta"=write_dta)
  
  ## read, extract cols, find relevant cols
  new_dir <- if(overwrite) dir else paste(dir, "ANONYMISED", sep="_")
  if(!overwrite) dir.create(new_dir)
  files_df <- data_frame(filename = files, 
                         filename_out = if(overwrite) filename else str_replace(filename, dir, new_dir),
                         data=map(filename, read_fun), 
                         colnames=map(data, ~data_frame(cols=colnames(.)) %>%
                                        filter(cols %in% cols_id)))

  ## ano each: overwrite data
  files_df_clean <- files_df %>%
    mutate(data =map2(data, colnames, ~mutate_at(.x, vars(unlist(.y)), digest_vect, trim)))

  ## write results
  out <- files_df_clean %>%
    {map2(.$filename_out, .$data, ~write_fun(.y, .x))}
    
  
}



## toy dataset
if(FALSE){
  names <- c("Bob", "John", "Harry")
  address <- c("House Street", "Main Street", "Central Av.")
  file_1 <- data_frame(pers = names, address=address, data=rnorm(3))
  file_2 <- data_frame(person = rep(names,each=2), data=sample(letters, size=6),
                       income=rnorm(6))
  
  temp_dir <- tempdir()
  path_1 <- paste(temp_dir, "file_1.csv", sep="/")
  path_2 <- paste(temp_dir, "file_2.csv", sep="/")
  write_csv(file_1, path_1)
  write_csv(file_2, path_2)

  ## check
  read_csv(path_1)
  read_csv(path_2)
  
  # anonymise csv file
  ano(dir=temp_dir, cols_id = c("pers", "address", "person", "income"), trim=12)
  
  ## check
  read_csv(path_1)
  read_csv(path_2)
  
  
### Try STATA  
  library(haven)
  path_1_dta <- paste(temp_dir, "file_1.dta", sep="/")
  path_2_dta <- paste(temp_dir, "file_2.dta", sep="/")
  write_dta(file_1, path_1_dta)
  write_dta(file_2, path_2_dta)
  read_dta(path_1_dta)
  read_dta(path_2_dta)
  
  # anonymise dta file
  ano(dir=temp_dir, cols_id = c("pers", "address", "person", "income"), trim=12, extension="dta")
  read_dta(path_1_dta)
  read_dta(path_2_dta)
  
}

