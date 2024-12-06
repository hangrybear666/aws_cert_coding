output "http_aws_api_endpoint" {
  description = "The http api endpoint"
  value = module.api_gateway.aws_api.api_endpoint
}
output "http_aws_api_arn" {
  description = "The http api arn"
  value = module.api_gateway.aws_api.arn
}
output "http_aws_api_execution_arn" {
  description = "The http api execution arn"
  value = module.api_gateway.aws_api.execution_arn
}
output "route_upload_img" {
  value = "${module.api_gateway.aws_api.api_endpoint}/${var.default_stage}${var.post_img_route}"
}
output "route_post_sheet_url" {
  value = "${module.api_gateway.aws_api.api_endpoint}/${var.default_stage}${var.post_raw_data_route}"
}

output "lambda_invoke_cmd_upload_img" {
  description = "aws cli invoke command to test the lambda function for uploading images"
  value = <<EOT

#               __        ___          __        __        __              __                      __   __
#  | |\ | \  / /  \ |__/ |__     |  | |__) |    /  \  /\  |  \    |  |\/| / _`    |     /\   |\/| |__) |  \  /\
#  | | \|  \/  \__/ |  \ |___    \__/ |    |___ \__/ /~~\ |__/    |  |  | \__>    |___ /~~\  |  | |__) |__/ /~~\
aws lambda invoke --function-name ${module.lambda_image_processing.function_name} /dev/stdout && echo "" && \
  aws lambda invoke --function-name ${module.lambda_image_processing.function_name} --log-type Tail /dev/null | jq -r '.LogResult' | base64 --decode

  EOT
}

output "lambda_invoke_cmd_raw_etl_processing" {
  description = "aws cli invoke command to test the lambda function for processing raw data such as google sheets and tsv files"
  value = <<EOT

#               __        ___     __                 __       ___           ___ ___                          __   __
#  | |\ | \  / /  \ |__/ |__     |__)  /\  |  |     |  \  /\   |   /\      |__   |  |       |     /\   |\/| |__) |  \  /\
#  | | \|  \/  \__/ |  \ |___    |  \ /~~\ |/\| ___ |__/ /~~\  |  /~~\ ___ |___  |  |___    |___ /~~\  |  | |__) |__/ /~~\
aws lambda invoke --function-name ${module.lambda_raw_data_etl.function_name} \
  --payload '${jsonencode({key1 = "cli-test-value", sheet_url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSVcmgixKaP9LC-rrqS4D2rojIz48KwKA8QBmJloX1h7f8BkUloVuiw19eR2U5WvVT4InYgnPunUo49/pub?output=xlsx"})}' \
  --cli-binary-format raw-in-base64-out /dev/stdout

  EOT
}

output "lambda_invoke_cmd_upload_img_with_payload" {
  description = ""
  value = <<EOT
bash modules/lambda/scripts/curl-api-sheet-url.sh https://dvtkxey9mk.execute-api.eu-central-1.amazonaws.com/api/fiscalismia/post/sheet_url/process_lambda/return_tsv_file_urls lkasdkljadskl28281291dasfasfasf

//   __        __                   __               __                  __      ___       __   __   __   ___  __
//  /  ` |  | |__) |       |  |    |__) | |\ |  /\  |__) \ /    |  |\/| / _`    |__  |\ | /  ` /  \ |  \ |__  |  \
//  \__, \__/ |  \ |___    |/\|    |__) | | \| /~~\ |  \  |     |  |  | \__>    |___ | \| \__, \__/ |__/ |___ |__/
bash modules/lambda/scripts/curl-api-img-upload.sh ${module.api_gateway.aws_api.api_endpoint}/${var.default_stage}${var.post_img_route}


#   __        __                   __        ___  ___ ___           __
#  /  ` |  | |__) |       |  |    /__` |__| |__  |__   |      |  | |__) |
#  \__, \__/ |  \ |___    |/\|    .__/ |  | |___ |___  |  ___ \__/ |  \ |___

# WARNING: Do NOT save this output to version control. It contains your Secret API Key
bash modules/lambda/scripts/curl-api-sheet-url.sh ${module.api_gateway.aws_api.api_endpoint}/${var.default_stage}${var.post_raw_data_route} ${var.secret_api_key}

  EOT
}
