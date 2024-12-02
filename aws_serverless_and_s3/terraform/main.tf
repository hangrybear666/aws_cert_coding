provider "aws" {
  region = "eu-central-1"
}

# S3 bucket for persisting uploaded user images
module "s3_image_storage" {
  source = "./modules/s3"
  bucket_name                   = "hangrybear-fiscalismia-image-storage"
  bucket_description            = "Fiscalismia Image Upload Storage"
  fqdn                          = var.fqdn
  data_expiration               = false
  data_archival                 = false
}

# S3 bucket for ETL on Google Sheets/TSV file transformations
module "s3_raw_data_etl_storage" {
  source = "./modules/s3"
  bucket_name                  = "hangrybear-fiscalismia-raw-data-etl-storage"
  bucket_description           = "Fiscalismia ETL Repository for Raw Data Transformation for PSQL"
  fqdn                         = var.fqdn
  data_expiration              = true
  data_archival                = true
}

# endpoint to connect fiscalismia containers (file upload) to lambdas for further processing
module "api_gateway" {
  source = "./modules/api_gateway"
  api_name                          = "fiscalismia-http-api-gw"
  api_description                   = "Fiscalismia HTTP API Gateway"
  fqdn                              = var.fqdn
  lambda_function_name_upload_img   = module.lambda_image_processing.function_name
  lambda_invoke_arn_upload_img      = module.lambda_image_processing.invoke_arn
}

# Lambda for receiving uploaded user images and reducing them in filesize
module "lambda_image_processing" {
  source                        = "./modules/lambda"
  function_purpose              = "image_processing"
  service_name                  = var.service_name
  runtime_env                   = "nodejs18.x"
}

# Lambda for receiving google sheets/tsv files and transforming them into queries to fiscalismia rest api
module "lambda_raw_data_etl" {
  source = "./modules/lambda"
  function_purpose              = "raw_data_etl"
  service_name                  = var.service_name
  runtime_env                   = "python3.8"
}