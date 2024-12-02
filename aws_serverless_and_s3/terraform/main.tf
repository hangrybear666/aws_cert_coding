provider "aws" {
  region = "eu-central-1"
}

# S3 bucket for persisting uploaded user images
module "s3_image_storage" {
  source = "./modules/s3"
  bucket_name = "hangrybear-fiscalismia-image-storage"
  bucket_description = "Fiscalismia Image Upload Storage"
  data_expiration = false
  data_archival = false
}

# S3 bucket for ETL on Google Sheets/TSV file transformations
module "s3_raw_data_etl_storage" {
  source = "./modules/s3"
  bucket_name = "hangrybear-fiscalismia-raw-data-etl-storage"
  bucket_description = "Fiscalismia ETL Repository for Raw Data Transformation for PSQL"
  data_expiration = true
  data_archival = true
}

# endpoint to connect fiscalismia containers (file upload) to lambdas for further processing
module "api_gateway" {
  source = "./modules/api_gateway"
}

# Lambda for receiving uploaded user images and reducing them in filesize
module "lambda_image_processing" {
  source = "./modules/lambda"
  function_purpose = "image_processing"
}

# Lambda for receiving google sheets/tsv files and transforming them into queries to fiscalismia rest api
module "lambda_raw_data_etl" {
  source = "./modules/lambda"
  function_purpose = "raw_data_etl"
}