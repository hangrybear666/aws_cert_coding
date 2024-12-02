provider "aws" {}

module "s3_image_storage" {
  source = "./modules/s3"
  bucket_name = "hangrybear-fiscalismia-image-storage"
  bucket_description = "Fiscalismia Image Upload Storage"
}

module "s3_raw_data_etl" {
  source = "./modules/s3"
  bucket_name = "hangrybear-fiscalismia-raw-data-etl"
  bucket_description = "Fiscalismia Raw Data Processing for PSQL"
}

module "api_gateway" {
  source = "./modules/api_gateway"
}

module "lambda_image_processing" {
  source = "./modules/lambda"
  function_purpose = "image_processing"
}

module "lambda_raw_data_etl" {
  source = "./modules/lambda"
  function_purpose = "raw_data_etl"
}