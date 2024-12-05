resource "aws_lambda_layer_version" "dependency_layer" {
  layer_name  = var.layer_name
  description = var.layer_description
  compatible_runtimes = [var.runtime_env]
  compatible_architectures = ["x86_64"]
  filename = "${path.module}/${var.function_purpose}_layer/${var.runtime_env}_layer.zip"
  depends_on = [null_resource.create_dependency_layer]
  source_code_hash = filebase64sha256("${path.module}/${var.function_purpose}_layer/${var.runtime_env}_layer.zip")
}

# data "external" "create_dependency_layer" {
#   program = ["bash", "${path.module}/scripts/create_${var.function_purpose}_layer.sh" ]
# }

resource "null_resource" "create_dependency_layer" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}"
    command = "bash scripts/create_${var.function_purpose}_layer.sh"
  }
  triggers = {
    always_trigger = timestamp()
  }
}