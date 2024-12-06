variable "region" {
  default = "eu-central-1"
  description = "region for aws resources"
  type = string
}
variable "fqdn" {
  default = "https://fiscalismia.com"
  description = "fully qualified domain name of source webservice for CORS access"
  type = string
}
variable "service_name" {
  default = "fiscalismia"
  description = "webservice name for resource naming"
  type = string
}
variable "default_stage" {
  default = "api"
  type = string
  description = "HTTP API can be separated into stages that change the endpoint routes to start with /stage/"
}
variable "post_img_route" {
  default = "/fiscalismia/upload/img/process_lambda/return_s3_img_url"
  type = string
  description = "http api route for aws. the default stage is prepended."
}
variable "post_raw_data_route" {
  default = "/fiscalismia/post/sheet_url/process_lambda/return_tsv_file_urls"
  type = string
  description = "http api route for google sheets url post to trigger lambda etl and s3 storage. Returns S3 URLS to exported TSV files"
}

variable "etl_bucket_name" {
  description = "Bucket Name for Raw Data Transformation"
  type = string
  default = "hangrybear-fiscalismia-raw-data-etl-storage"
}
variable "image_processing_bucket_name" {
  description = "Bucket Name for Image Downsizing"
  type = string
  default = "hangrybear-fiscalismia-image-storage"
}