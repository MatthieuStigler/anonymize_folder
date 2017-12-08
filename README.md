Goal: anonymise a full folder in one single line
================================================

The simple function **ano()** will anonymise specified columns in a
directory, using the *sha256* algorithm. It does:

1.  Read all files with a given extension (**extension** = csv or dta)
2.  Search for the coumns indicated by user (argument **cols\_id**)
3.  Use R digest::digest function, with algorithm *sha256*. NOTE: digest
    says *Please note that this package is not meant to be used for
    cryptographic purposes*.
4.  Write the files. Either in a newly created folder adding
    \*\_ANONYMISED\*, or simply overwrite the files in original folder
    (**overwrite**=TRUE)

Simply use the function:

    source("https://raw.githubusercontent.com/MatthieuStigler/anonymize_folder/master/anonymize_main.R")
    ano(dir, cols_id = c("pers", "address"))

Example
-------

### Load the function

    source("https://raw.githubusercontent.com/MatthieuStigler/anonymize_folder/master/anonymize_main.R")

### Create fake dataset

    library(tidyverse)
    names <- c("Bob", "John", "Harry")
    address <- c("House Street", "Main Street", "Central Av.")
    file_1 <- data_frame(pers = names, address=address, data=rnorm(3))
    file_2 <- data_frame(person = rep(names,each=2), data=sample(letters, size=6),
                         income=rnorm(6))

Check them:

    file_1

    ## # A tibble: 3 x 3
    ##    pers      address       data
    ##   <chr>        <chr>      <dbl>
    ## 1   Bob House Street -0.9761767
    ## 2  John  Main Street -1.7614878
    ## 3 Harry  Central Av.  0.7321746

    file_2

    ## # A tibble: 6 x 3
    ##   person  data     income
    ##    <chr> <chr>      <dbl>
    ## 1    Bob     j  1.0356953
    ## 2    Bob     f  1.7343948
    ## 3   John     z  0.8855771
    ## 4   John     a  1.1782688
    ## 5  Harry     g  1.8430461
    ## 6  Harry     r -0.2795634

Write this dataset on your disk:

    temp_dir <- tempdir()
    path_1 <- paste(temp_dir, "file_1.csv", sep="/")
    path_2 <- paste(temp_dir, "file_2.csv", sep="/")
    write_csv(file_1, path_1)
    write_csv(file_2, path_2)

test the function
-----------------

Here the cols are pers, person, address and income. We specify the
argument **trim**=12 just for seeing the output:

    ano(dir=temp_dir, cols_id = c("pers", "address", "person", "income"), trim=12)

    ## Parsed with column specification:
    ## cols(
    ##   pers = col_character(),
    ##   address = col_character(),
    ##   data = col_double()
    ## )

    ## Parsed with column specification:
    ## cols(
    ##   person = col_character(),
    ##   data = col_character(),
    ##   income = col_double()
    ## )

Files have been written. Read now:

    read_csv(paste(temp_dir, "_ANONYMISED/file_1.csv", sep=""))

    ## Parsed with column specification:
    ## cols(
    ##   pers = col_character(),
    ##   address = col_character(),
    ##   data = col_double()
    ## )

    ## # A tibble: 3 x 3
    ##           pers      address       data
    ##          <chr>        <chr>      <dbl>
    ## 1 5022f23cb480 13fb303db61f -0.9761767
    ## 2 632dc5c5235d a6da84335acf -1.7614878
    ## 3 9ceb55e9ec3b bc8767157546  0.7321746

    read_csv(paste(temp_dir, "_ANONYMISED/file_2.csv", sep=""))

    ## Parsed with column specification:
    ## cols(
    ##   person = col_character(),
    ##   data = col_character(),
    ##   income = col_character()
    ## )

    ## # A tibble: 6 x 3
    ##         person  data       income
    ##          <chr> <chr>        <chr>
    ## 1 5022f23cb480     j e837e24e188d
    ## 2 5022f23cb480     f 43e0045b8690
    ## 3 632dc5c5235d     z 7fa23ab447d6
    ## 4 632dc5c5235d     a aca2d6c02dce
    ## 5 9ceb55e9ec3b     g 03deca6d7a45
    ## 6 9ceb55e9ec3b     r 8a9c8a06fea3
