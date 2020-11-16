# s3

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/s3)](https://CRAN.R-project.org/package=s3)
[![R build status](https://github.com/geomarker-io/s3/workflows/R-CMD-check/badge.svg)](https://github.com/geomarker-io/s3/actions)
<!-- badges: end -->

> download files from AWS S3

## Usage

This R package can download files hosted on AWS S3 to a local directory based on their URI. It will avoid downloading files that are already present and also allows for customization of where to store downloaded files.

### Identifying files with a URI

URI stands for [Universal Resource Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier), which is a federated and extensible naming system. In practice, this means that a URI is a character string that can uniquely identify a particular resource. An example of a commonly used URI scheme is `https` for identifying web resources, e.g. `https://r-project.org`.

Here, we use the `s3` scheme as defined by AWS. For example, the URI for a file hosted on S3 called `mtcars.rds` in a bucket called `geomarker` in a folder called `test_downloads` would be:

 `s3://geomarker/test_downloads/mtcars.rds`


### Example Usage

Download a single file with:

```r

```

If a file has already been downloaded or already exists, then it will not be re-downloaded:

```r

```


Download multiple files with:

```r

```

## Downloaded file paths

Files are saved within a directory structure matching that of the S3 URI; this directory is created if necessary. `s3_get` and `s3_get_files` both invisibly return the file path(s) of the downloaded files so that they can be further used to access the downloaded files. This makes it possible for different users with different operating systems and/or different project file structures and locations to utilize a downloaded S3 file without changing their source code:

```r
s3_get("s3://geomarker/testing_downloads/mtcars.rds") %>%
    readRDS()
```

### Customizing download location

By default, files downloaded from S3 will be stored in a folder called `s3_downloads` located within the current working directory. This can be changed when downloading files by using the `download_folder` argument:

```r

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

### `boto3` python module

The package uses [`reticulate`](https://rstudio.github.io/reticulate/) to expose functions from the [`boto3`](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) python module.  This allows us to take advantage of its concurrent transfer operations using threads, but requires the module to be installed.

 Although the package can be installed and loaded without the `boto3` python module, its core functionality will not be available without it. In this case, you will be advised to install it from within `R` by calling `reticulate::py_install("boto3")`, which will automatically install it within a virtualenv or Conda environment named `r-reticulate`. Additionally, if your system does not have a compatible version of python, you will be asked to install [`miniconda`](https://docs.conda.io/en/latest/miniconda.html) from within `R`.

### Setting up AWS credentials

AWS S3 uses credentials to allow access to non-public files. As with other AWS command line tools and R packages, you can use the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to gain access to such files. 

It is highly recommended to setup your environment variables outside of your R script to avoid including sensitive information within your R script. This can be done by exporting environment variables before starting R (see [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) on this) or by defining them in a `.Renviron` file (see `?.Renviron` within `R`).

You can use the helper function `check_for_aws_env_vars()` to check if your AWS key environment variables are set.
