# Easily download files from s3

The main function is called `download_s3`. Its arguments include

* `fl_names` - a character vector of file names (not the entire path) to be downloaded from s3 to your local files. May be programmatically constructed by other functions

* `s3_folder_url` - the file location within s3, e.g. `s3://bucket_name/folder_name/`

* `download_dir` - the local path where the downloaded files are saved

## Example Usage

```
download_s3(fl_names =  c('dng_2016_round1.qs', 'dng_2015_round2.qs'),
            s3_folder_url = 's3://geomarker/schwartz/exp_estimates_1km/by_gh3_year/',
            download_dir = getwd())
```

### Download Time Testing

| Download Method                 | Time to download 429.2 MB csv file  | Time to download 288.9 MB rds file |
| ------------------------------- | ----------------------------------: | ---------------------------------: |
| `download.file`                 |                               72.2s |                              48.6s |
| system call to Python aws cli   |                               72.9s |                              50.0s |
| `aws.s3::save_object`           |                               72.8s |                              49.3s |

Note: `download.file` requires the s3 file to have public permissions, while the other two methods require an aws key. 
