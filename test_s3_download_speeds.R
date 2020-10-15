####### CSV file
# 429.2 MB in s3

system.time(
  download.file(url = 'https://geomarker.s3.us-east-2.amazonaws.com/cf/CF_centers_to_zcta_centroids_distance_and_drivetime.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAY6I67HSWWRUX766V/20201007/us-east-2/s3/aws4_request&X-Amz-Date=20201007T153429Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=95a8a21451c86f9d5ac8e64d84c67f54b57c5b0e8badaef71e3149ccc8a06d2b',
                destfile = 'cf_centers_to_zcta_centroids.csv')
)

# user  system elapsed
# 2.277   3.546  72.146


system.time(
  system('aws s3 cp s3://geomarker/cf/CF_centers_to_zcta_centroids_distance_and_drivetime.csv cf_centers_to_zcta_centroids.csv')
)

# user  system elapsed
# 4.937   3.998  72.876

system.time(
  aws.s3::get_object('s3://geomarker/cf/CF_centers_to_zcta_centroids_distance_and_drivetime.csv')
)

# user  system elapsed
# 2.503   2.176  72.816


###### RDS file
# 288.9 MB in s3

system.time(
  download.file(url = 'https://geomarker.s3.us-east-2.amazonaws.com/geometries/block_groups_2000_5072.rds?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAY6I67HSWWRUX766V/20201007/us-east-2/s3/aws4_request&X-Amz-Date=20201007T184928Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=0e627929cad0560e1d7e1e6b712ddaed40bc5f4fe8c56f5c0766ce224570c8b2',
                destfile = 'block_groups.rds')
)

# user  system elapsed
# 1.469   2.324  48.596


system.time(
  system('aws s3 cp s3://geomarker/geometries/block_groups_2000_5072.rds block_groups.rds')
)

# user  system elapsed
# 4.273   3.395  49.967

system.time(
  aws.s3::get_object('s3://geomarker/geometries/block_groups_2000_5072.rds')
)

# user  system elapsed
# 1.959   1.657  49.272


