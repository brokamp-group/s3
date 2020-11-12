# s3

> download files from AWS S3

## Usage

This R package can download files hosted on AWS S3 to a local directory based on their URI. It will avoid downloading files that are already present and also allows for customization of where to store downloaded files.

### Identifying files with a URI

URI stands for [Universal Resource Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier), which is a federated and extensible naming system. In practice, this means that a URI is a character string that can uniquely identify a particular resource. An example of a commonly used URI scheme is `https` for identifying web resources, e.g. `https://r-project.org`.

Here, we use the `s3` scheme as defined by AWS. For example, the URI for a file hosted on S3 called `mtcars.rds` in a bucket called `geomarker` in a folder called `test_downloads` would be:

 `s3://geomarker/test_downloads/mtcars.rds`


### Example Usage

Download a single file with:


Download multiple files with:

### Customizing download location

By default, files downloaded from S3 will be stored in a folder called `s3_downloads` located within the current working directory. This can be changed when downloading files by using the `download_folder` argument.

This can also be changed for the entire session by using the option `s3.download_folder`. For example, specifying `options(s3.download_folder = /scratch/broeg1/s3_downloads)` will write all downloaded files to `/scratch/broeg1/s3_downloads`.

Using a folder for all downloads will prevent duplication of files within different working directories, instead allowing all R sessions to access these files. This could be combined with something like [`rappdirs`](https://github.com/r-lib/rappdirs) to share files across users or temporarily cache them.



## Installation

Currently, the package is only available on GitHub. Install inside `R` with:

```r
# install.packages("remotes")
remotes::install_github("geomarker-io/s3")
```

### Setting up AWS credentials

AWS S3 uses credentials to allow access to non-public files. As with other AWS command line tools and R packages, you can use the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to gain access to such files. 

It is highly recommended to setup your environment variables outside of your R script to avoid including sensitive information within your R script. This can be done by exporting environment variables before starting R (see [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) on this) or by defining them in a `.Renviron` file (see `?.Renviron` within `R`).

You can use the helper function `check_for_aws_env_vars()` to check if your AWS key environment variables are set.
