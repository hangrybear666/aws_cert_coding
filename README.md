# aws_cert_coding
coming up

<details closed>
<summary><b>AWS IAM</b></summary>

#### 1. Create an organization in your root account and create a well Architected Multi Account Environment

- First Create Organization in AWS Console to be able to execute the terraform config

```bash
cd aws_iam/terraform
terraform init
terraform apply-auto-approve
```

<u>The Hierarchy is as follows:</u>

```bash
---------------------------------
|           org/root             |
| dev ou  | sandbox ou | prod ou |
| dev_acc | tempdel ou |         |
|                                |
---------------------------------
```

- Then login to management account and switch role to dev account
- In the Switch Role dialog:
- Account ID: Enter the Account ID of your new member account.
- Role Name: Enter `OrganizationAccountAccessRole`
- Display Name: for UI
- Color: Optional

</details>

-----
<details closed>
<summary><b>AWS Lambda</b></summary>

### Theory 

#### Anti-Patterns 

- Chaining 2-n Lambda functions synchronously (where the first function waits for the last function to return) creates exponentially overlapping costs 
- Breaking the single responsibility principle of a lambda function makes it difficult to monitor, optimize and debug a function and might create additional costs due to autoscaling to the level of the most demanding task 

#### Best Practices 

- Use step functions instead of synchronous lambda functions to construct an event flow, branching paths, error handling, retries and fallbacks
- When integrating with SQS use batch processing with x seconds wait window after queueing a message to collect multiple messages at once to avoid spamming lambda invocations (Optionally enable lambda to report failed message IDs in the batch to avoid reprocessing the entire batch) 

### Examples 

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
