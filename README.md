
<!-- README.md is generated from README.Rmd. Please edit that file -->

# s3

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/s3)](https://CRAN.R-project.org/package=s3)
[![R-CMD-check](https://github.com/geomarker-io/s3/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/geomarker-io/s3/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

s3 is an R package designed to download files hosted on AWS S3.

Downloads can be saved to a location shared across R sessions/users and
download functions always return paths to downloaded files. Files
already present in the download location will be used before trying to
download a file again. This means more concise code for reading/loading
files after downloading them (if they are not already downloaded). For
example:

``` r
s3::s3_get("s3://modis-aod-nasa/2020.05.22.tif")
```

## Installation

Install the CRAN latest release inside `R` with:

``` r
install.packages("s3")
```

Install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("geomarker-io/s3")
```

## Usage

### Downloading Files

``` r
library(s3)
```

Download a single file specified by its [URI](#URI) with:

``` r
s3_get("s3://geomarker/testing_downloads/mtcars.rds")
```

If a file has already been downloaded or already exists, then it will
not be re-downloaded:

``` r
s3_get("s3://geomarker/testing_downloads/mtcars.rds")
#> ℹ 's3://geomarker/testing_downloads/mtcars.rds' already exists at '/Users/broeg1/code/s3/s3_downloads/geomarker/testing_downloads/mtcars.rds'
```

Download multiple files with:

``` r
s3_get_files(c(
          "s3://geomarker/testing_downloads/mtcars.rds",
          "s3://geomarker/testing_downloads/mtcars_again.rds"
        ),
    confirm = FALSE)
#> ℹ 1 file already exists
#> ℹ 1 file totaling 1.23 kB will be downloaded to '/Users/broeg1/code/s3/s3_downloads'
#> → Downloading 1 file.
#> → Got 0 files, downloading 1
#> ✔ Downloaded 1 file in 123ms.
```

### Private Files

Downloading private files requires the name of the S3 bucket’s region
(this is determined automatically when the file is public):

``` r
s3_get("s3://geomarker/testing_downloads/mtcars_private.rds", region = "us-east-2")
```

#### Setting up AWS credentials

You must have the appropriate AWS S3 credentials set to gain access to
non-public files. As with other AWS command line tools and R packages,
you can use the environment variables `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` to gain access to such files.

It is highly recommended to setup your environment variables outside of
your R script to avoid including sensitive information within your R
script. This can be done by exporting environment variables before
starting R (see [AWS CLI
documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
on this) or by defining them in a `.Renviron` file (see `?.Renviron`
within `R`).

You can use the internal helper function to check if AWS key environment
variables are set.

``` r
s3:::check_for_aws_env_vars()
#> ✖ AWS_SECRET_ACCESS_KEY and/or AWS_ACCESS_KEY_ID are unset
#> ℹ Non-public S3 files will not be available
```

### Downloaded file paths

Files are saved within a directory structure matching that of the S3
URI; this directory is created if necessary. `s3_get` and `s3_get_files`
both invisibly return the file path(s) of the downloaded files so that
they can be further used to access the downloaded files. This makes it
possible for different users with different operating systems and/or
different project file structures and locations to utilize a downloaded
S3 file without changing their source code:

``` r
s3_get("s3://geomarker/testing_downloads/mtcars.rds") |>
    readRDS()
#> ℹ 's3://geomarker/testing_downloads/mtcars.rds' already exists at '/Users/broeg1/code/s3/s3_downloads/geomarker/testing_downloads/mtcars.rds'
#>                      mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710          22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
#> Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
#> Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
#> Merc 240D           24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
#> Merc 230            22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
#> Merc 280            19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
#> Merc 280C           17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
#> Merc 450SE          16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3
#> Merc 450SL          17.3   8 275.8 180 3.07 3.730 17.60  0  0    3    3
#> Merc 450SLC         15.2   8 275.8 180 3.07 3.780 18.00  0  0    3    3
#> Cadillac Fleetwood  10.4   8 472.0 205 2.93 5.250 17.98  0  0    3    4
#> Lincoln Continental 10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4
#> Chrysler Imperial   14.7   8 440.0 230 3.23 5.345 17.42  0  0    3    4
#> Fiat 128            32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
#> Honda Civic         30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2
#> Toyota Corolla      33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
#> Toyota Corona       21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
#> Dodge Challenger    15.5   8 318.0 150 2.76 3.520 16.87  0  0    3    2
#> AMC Javelin         15.2   8 304.0 150 3.15 3.435 17.30  0  0    3    2
#> Camaro Z28          13.3   8 350.0 245 3.73 3.840 15.41  0  0    3    4
#> Pontiac Firebird    19.2   8 400.0 175 3.08 3.845 17.05  0  0    3    2
#> Fiat X1-9           27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
#> Porsche 914-2       26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2
#> Lotus Europa        30.4   4  95.1 113 3.77 1.513 16.90  1  1    5    2
#> Ford Pantera L      15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4
#> Ferrari Dino        19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
#> Maserati Bora       15.0   8 301.0 335 3.54 3.570 14.60  0  1    5    8
#> Volvo 142E          21.4   4 121.0 109 4.11 2.780 18.60  1  1    4    2
```

### Customizing download location

By default, files downloaded from S3 will be stored in a folder called
`s3_downloads` located within the current working directory. This can be
changed when downloading files by using the `download_folder` argument:

``` r
s3_get("s3://geomarker/testing_downloads/mtcars.rds",
       download_folder = fs::path_home('~/Desktop/s3_downloads'))
```

This can also be changed for the entire session by using the option
`s3.download_folder`. For example, specifying
`options(s3.download_folder = /scratch/broeg1/s3_downloads)` will write
all downloaded files to `/scratch/broeg1/s3_downloads`.

Using a folder for all downloads will prevent duplication of files
within different working directories, instead allowing all R sessions to
access these files. This could be combined with something like
[`rappdirs`](https://github.com/r-lib/rappdirs) to share files across
users or temporarily cache them.

As above, this feature also allows different users to store downloaded
S3 files in different locations (e.g. a network mounted drive, a scratch
folder on a high performance cluster, an external hard drive, a
temporary directory) without having to change their R script to specify
file paths specific to their computer.

### URI

URI stands for [Universal Resource
Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier),
which is a federated and extensible naming system. In practice, this
means that a URI is a character string that can uniquely identify a
particular resource. An example of a commonly used URI scheme is `https`
for identifying web resources, e.g. `https://r-project.org`.

Here, we use the `s3` scheme as defined by AWS. For example, the URI for
a file hosted on S3 called `mtcars.rds` in a bucket called `geomarker`
in a folder called `test_downloads` would be:

`s3://geomarker/test_downloads/mtcars.rds`
