# aws_cert_coding
coming up

<details closed>
<summary><b>AWS Lambda</b></summary>

#### 1. Make changes to your example python lambda function, create payload zip archive, create resources and invoke function

```bash
cd aws_lambda/terraform/ && terraform init
cd payload && rm -rf payload.zip
zip -r payload.zip index.py && cd ..
terraform apply --auto-approve
```

<u>Invoke Function via CLI</u>

```bash
aws lambda invoke \
--function-name ExampleTestLambdaFunction \
--payload '{"key1":"value1" }' \
--cli-binary-format raw-in-base64-out \
output.txt
```


</details>

-----