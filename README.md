Goal: anonymise a full folder in one single line
================================================

The simple function **ano()** will anonymise specified columns in a
directory, using the [SHA-2](https://en.wikipedia.org/wiki/SHA-2)
algorithm. The SHA-2 is a deterministic hash funciton. This is used
because same key might appear in several files, preventing from using
simple stochastic keys. As such, original names could be found by brute
force. Using sha256, one needs 2^32 = 4 billions, while for sha512, it
is 2^64 = 1.8 e+19.

The funciton does:

1.  Read all files with a given extension (**extension** = csv or dta)
2.  Search for the coumns indicated by user (argument **cols\_id**)
3.  Use R
    [digest::digest](https://www.rdocumentation.org/packages/digest/versions/0.6.12/topics/digest)
    function, with **algo**= *sha256*.
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
    ## 1   Bob House Street -0.9294301
    ## 2  John  Main Street  0.3340140
    ## 3 Harry  Central Av.  0.1256490

    file_2

    ## # A tibble: 6 x 3
    ##   person  data     income
    ##    <chr> <chr>      <dbl>
    ## 1    Bob     m -1.7055573
    ## 2    Bob     t  0.7182128
    ## 3   John     h  0.1563680
    ## 4   John     g  0.8255275
    ## 5  Harry     f -1.3313323
    ## 6  Harry     i  0.1820262

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
    ## 1 5022f23cb480 13fb303db61f -0.9294301
    ## 2 632dc5c5235d a6da84335acf  0.3340140
    ## 3 9ceb55e9ec3b bc8767157546  0.1256490

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
    ## 1 5022f23cb480     m 532d01235861
    ## 2 5022f23cb480     t 087b24efb027
    ## 3 632dc5c5235d     h 2a069145d6af
    ## 4 632dc5c5235d     g a466504cb7a6
    ## 5 9ceb55e9ec3b     f b7cb1de98524
    ## 6 9ceb55e9ec3b     i 190dc6804af6
