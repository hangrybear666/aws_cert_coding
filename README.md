# aws_cert_coding
coming up

<details closed>
<summary><b>AWS IAM</b></summary>

#### 1. Create an organization in your root account and create a well Architected Multi Account Environment

- First Create Organization in AWS Console to be able to execute the terraform config
- Enable AWS Resource Explorer in AWS Console to find resources across your organization easily
- Enable AWS RAM (Resource Access Manager) in AWS Console to share resources between accounts on a high level.
- In Resource Access Manager Settings Enable Resource Sharing Across AWS Organizations

```bash
cd aws_iam/terraform
terraform init
terraform apply-auto-approve
```

<u>The Hierarchy is as follows:</u>

```bash
-----------------------------------------------
|           org/root                           |
| dev ou  | sandbox ou | prod ou | network ou  |
| dev_acc | tempdel ou |           network_acc |
|                                              |
-----------------------------------------------
```

*Notes:*
- The dev VPC and Subnet created by aws_ec2_vpc_subnets is shared across the organization via RAM

**To access EC2 instances of the admin account:**
- Then login to dev account using credentials provided by
- In the Switch Role dialog:
- **Account ID**: Enter the Account ID of your admin account
- - **Role Name**: Enter `EC2FullAccessRole`

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

<details closed>
<summary><b>AWS EC2 - VPC - Subnets</b></summary>

### TODO

- add private subnet
- add nat gateway in public subnet and route from private to establish stateful egress
- add proper security group

### 1. Install EC2, VPC, Subnets, IGW and so forth with terraform

#### a. Setup Environment Variables with your secrets and configuration
scaffold the .env files with the following script and fill in your own details.
```bash
cd scripts/ && ./setup-env-vars.sh
```

#### b. Associate SSH Key to Instance
Create Public/Private Key pair so ec2-instance can add the public key to its ssh_config or use an existing key pair.

#### c. Provide custom variables
Create `terraform-02-ec2-modularized/terraform.tfvars` file and change any desired variables by overwriting the default values within `variables.tf`
```bash
my_ips               = ["62.xxx.xxx.251/32", "3.xxx.xxx.109/32"]
public_key_location  = "~/.ssh/id_ed25519.pub"
private_key_location = "~/.ssh/id_ed25519"
instance_count       = 1
```

#### d. Create S3 bucket to store terraform state to synchronize the state to remote storage as secure backup

See https://github.com/hangrybear666/12-devops-bootcamp__terraform
- Simply follow bonus step 3 to setup the s3 backend used in this project's `provider.tf` file (only required once for all states).
- Change bucket = "{YOUR_S3_UNIQUE_BUCKET_NAME}" in `provider.tf` that you've set in bonus project 3.

#### e. Setup Infrastructure

```bash
cd aws_ec2_vpc_subnets/terraform
source .env
terraform init
terraform apply --auto-approve
```

</details>

-----
