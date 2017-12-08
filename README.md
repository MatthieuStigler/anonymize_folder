Goal: anonymise a full folder in one single line
================================================

The simple function **ano()** will anonymise specified columns in a
directory, using the *sha256* algorithm. It does:

1.  Read all files with a given extension (**extension** = csv or dta)
2.  Search for the coumns indicated by user (argument **cols\_id**)
3.  Use R digest::digest function, with algorithm *sha256*. NOTE: digest
    syays *Please note that this package is not meant to be used for
    cryptographic purposes *
4.  Write the files. Either overwrite, or write adding *ANO* in name

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
    ## 1   Bob House Street -0.5715689
    ## 2  John  Main Street -0.3773685
    ## 3 Harry  Central Av. -0.6855229

    file_2

    ## # A tibble: 6 x 3
    ##   person  data       income
    ##    <chr> <chr>        <dbl>
    ## 1    Bob     h  0.792868098
    ## 2    Bob     d  0.444978962
    ## 3   John     q -1.264233523
    ## 4   John     e  0.372662120
    ## 5  Harry     t  0.061253504
    ## 6  Harry     l  0.006592464

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

    read_csv(path_1)

    ## Parsed with column specification:
    ## cols(
    ##   pers = col_character(),
    ##   address = col_character(),
    ##   data = col_double()
    ## )

    ## # A tibble: 3 x 3
    ##           pers      address       data
    ##          <chr>        <chr>      <dbl>
    ## 1 5022f23cb480 13fb303db61f -0.5715689
    ## 2 632dc5c5235d a6da84335acf -0.3773685
    ## 3 9ceb55e9ec3b bc8767157546 -0.6855229

    read_csv(path_2)

    ## Parsed with column specification:
    ## cols(
    ##   person = col_character(),
    ##   data = col_character(),
    ##   income = col_character()
    ## )

    ## # A tibble: 6 x 3
    ##         person  data       income
    ##          <chr> <chr>        <chr>
    ## 1 5022f23cb480     h f98cbd606de6
    ## 2 5022f23cb480     d c22a697f4bc9
    ## 3 632dc5c5235d     q 90248b48d7c7
    ## 4 632dc5c5235d     e 05bbd1392c6b
    ## 5 9ceb55e9ec3b     t b92132c3cc2a
    ## 6 9ceb55e9ec3b     l a4e046cff2e8
