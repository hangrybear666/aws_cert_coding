provider "aws" {
  region = "eu-central-1"
}

# S3 bucket for persisting uploaded user images
module "s3_image_storage" {
  source = "./modules/s3"
  bucket_name                   = var.image_processing_bucket_name
  bucket_description            = "Fiscalismia Image Upload Storage"
  fqdn                          = var.fqdn
  data_expiration               = false
  data_archival                 = false
  responsible_lambda_functions  = [module.lambda_image_processing.lambda_role_arn]
}

# S3 bucket for ETL on Google Sheets/TSV file transformations
module "s3_raw_data_etl_storage" {
  source = "./modules/s3"
  bucket_name                  = var.etl_bucket_name
  bucket_description           = "Fiscalismia ETL Repository for Raw Data Transformation for PSQL"
  fqdn                         = var.fqdn
  data_expiration              = true
  data_archival                = true
  responsible_lambda_functions = [module.lambda_raw_data_etl.lambda_role_arn]
}

# endpoint to connect fiscalismia containers (file upload) to lambdas for further processing
module "api_gateway" {
  source = "./modules/api_gateway"
  api_name                          = "fiscalismia-http-api-gw"
  api_description                   = "Fiscalismia HTTP API Gateway"
  fqdn                              = var.fqdn
  lambda_function_name_upload_img   = module.lambda_image_processing.function_name
  lambda_invoke_arn_upload_img      = module.lambda_image_processing.invoke_arn
  post_food_item_img_route          = "POST ${var.post_food_item_img_route}"
  default_stage                     = var.default_stage
}

# Lambda for receiving uploaded user images and reducing them in filesize
module "lambda_image_processing" {
  source                        = "./modules/lambda"
  function_purpose              = "image_processing"
  service_name                  = var.service_name
  runtime_env                   = "nodejs20.x"
  s3_bucket_name                = var.image_processing_bucket_name
}

# Lambda for receiving google sheets/tsv files and transforming them into queries to fiscalismia rest api
module "lambda_raw_data_etl" {
  source = "./modules/lambda"
  function_purpose              = "raw_data_etl"
  service_name                  = var.service_name
  runtime_env                   = "python3.8"
  s3_bucket_name                = var.etl_bucket_name
}