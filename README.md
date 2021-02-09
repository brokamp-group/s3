---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# s3

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/s3)](https://CRAN.R-project.org/package=s3)
[![R build status](https://github.com/geomarker-io/s3/workflows/R-CMD-check/badge.svg)](https://github.com/geomarker-io/s3/actions)
<!-- badges: end -->

> download files from AWS S3

## Usage

This R package can download public and private files hosted on AWS S3 to a local directory based on their URI. It will avoid downloading files that are already present and also allows for customization of where to store downloaded files.

### Identifying files with a URI

URI stands for [Universal Resource Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier), which is a federated and extensible naming system. In practice, this means that a URI is a character string that can uniquely identify a particular resource. An example of a commonly used URI scheme is `https` for identifying web resources, e.g. `https://r-project.org`.

Here, we use the `s3` scheme as defined by AWS. For example, the URI for a file hosted on S3 called `mtcars.rds` in a bucket called `geomarker` in a folder called `test_downloads` would be:

 `s3://geomarker/test_downloads/mtcars.rds`


### Example Usage

Download a single file with:





```r
library(s3)
s3_get("s3://geomarker/testing_downloads/mtcars.rds")
```

If a file has already been downloaded or already exists, then it will not be re-downloaded:


```r
s3_get("s3://geomarker/testing_downloads/mtcars.rds")
#> [36mℹ[39m s3://geomarker/testing_downloads/mtcars.rds already exists at /Users/cole/code/s3/s3_downloads/geomarker/testing_downloads/mtcars.rds
```

Download multiple files with:


```r
s3_get_files(c(
          "s3://geomarker/testing_downloads/mtcars.rds",
          "s3://geomarker/testing_downloads/mtcars_again.rds"
        ),
	confirm = FALSE)
#> [36mℹ[39m 1 file already exist
#> [36mℹ[39m 1 file totaling 1.23 kB will be downloaded to /Users/cole/code/s3/s3_downloads
#> → Downloading 1 files.→ Got 0 files, downloading 1                            [32m✔[39m Downloaded 1 file in 124ms.
```


## Downloaded file paths

Files are saved within a directory structure matching that of the S3 URI; this directory is created if necessary. `s3_get` and `s3_get_files` both invisibly return the file path(s) of the downloaded files so that they can be further used to access the downloaded files. This makes it possible for different users with different operating systems and/or different project file structures and locations to utilize a downloaded S3 file without changing their source code:


```r
s3_get("s3://geomarker/testing_downloads/mtcars.rds") %>%
    readRDS()
#> [36mℹ[39m s3://geomarker/testing_downloads/mtcars.rds already exists at /Users/cole/code/s3/s3_downloads/geomarker/testing_downloads/mtcars.rds
#>                    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4         21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
#> Duster 360        14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
#> Merc 240D         24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
#> Merc 230          22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
#>  [ reached 'max' / getOption("max.print") -- omitted 23 rows ]
```

This means that `s3` is not just for downloading objects. Since `s3_get` and `s3_get_files` will not download files that already exist and always return paths to these files, code utilizing these functions can be kept in R scripts designed to read in objects everytime they are run.

### Customizing download location

By default, files downloaded from S3 will be stored in a folder called `s3_downloads` located within the current working directory. This can be changed when downloading files by using the `download_folder` argument:


```r
s3_get("s3://geomarker/testing_downloads/mtcars.rds", download_folder = fs::path_home('~/Desktop/s3_downloads'))
```


This can also be changed for the entire session by using the option `s3.download_folder`. For example, specifying `options(s3.download_folder = /scratch/broeg1/s3_downloads)` will write all downloaded files to `/scratch/broeg1/s3_downloads`.

Using a folder for all downloads will prevent duplication of files within different working directories, instead allowing all R sessions to access these files. This could be combined with something like [`rappdirs`](https://github.com/r-lib/rappdirs) to share files across users or temporarily cache them.

As above, this feature also allows different users to store downloaded S3 files in different locations (e.g. a network mounted drive, a scratch folder on a high performance cluster, an external hard drive, a temporary directory) without having to change their R script to specify file paths specific to their computer.


## Installation

Currently, the package is only available on GitHub. Install inside `R` with:

```r
# install.packages("remotes")
remotes::install_github("geomarker-io/s3")
```

No further configuration is necessary, *but* if you would like to download private files from S3, you will need to install the `boto3` python module.

### `boto3` python module installation

The package uses [`reticulate`](https://rstudio.github.io/reticulate/) to expose functions from the [`boto3`](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) python module.  This allows us to take advantage of its concurrent transfer operations using threads, but requires the module to be installed.

 Although the package can be installed, loaded, and used to download public files on S3  without the `boto3` python module, private files will not be able to be downloaded without it. If `boto3` is unavailable and an attempt to download a private S3 file is made, you will be advised to install it from within `R` by calling `reticulate::py_install("boto3")`, which will automatically install it within a virtualenv or Conda environment named `r-reticulate`. Additionally, if your system does not have a compatible version of python, you will be asked to install [`miniconda`](https://docs.conda.io/en/latest/miniconda.html) from within `R`.

### Setting up AWS credentials

You must have the appropriate AWS S3 credentials set to gain access to non-public files. As with other AWS command line tools and R packages, you can use the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to gain access to such files. 

It is highly recommended to setup your environment variables outside of your R script to avoid including sensitive information within your R script. This can be done by exporting environment variables before starting R (see [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) on this) or by defining them in a `.Renviron` file (see `?.Renviron` within `R`).

You can use the internal helper function `s3:::check_for_aws_env_vars()` to check if your AWS key environment variables are set.



