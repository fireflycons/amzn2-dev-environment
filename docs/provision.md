# Provision Infrastructure

The role assigned to the instance currenly only includes the managed policy `AmazonSSMManagedInstanceCore` so that you can connect to the instance with SSM Session Manager to e.g. debug connection issues. You may want to adjust this role first to grant the instance extra AWS access depending on what you intend doing. Edit the `aws_iam_role` resource in [resources.tf](../terraform/resources.tf) before deployment.

Terraform requires the following variables to have values before you can plan and deploy the infrastructure. For ease, add them to a `terraform.tfvars` file in the `terraform` directory.

| Variable | Required | Value |
|----------|----------|-------|
| vpc_id | Yes | ID of the VPC to deploy into |
| subnet_id | Yes |ID of a public subnet within the above VPC to which the instance will be attached |
| instance_type | Yes | AWS instance type to deploy. `t3.xlarge` is a reasonable choice with 4CPU and 16GB |
| domain_name | No | Name of a domain you have hosted on Route53 (e.g. `example.com`) |
| host_name | Conditional | If `domain_name` is provided, this is the name of the host record (A) to create in Route53 |
| notification_email | No | If set, enable idle shutdown alarm (30 min inactivity) and notify this address on shutdown |
| environment_name | No | This name is added to `Name` tag of all resources. Default = `MATE Devenv` |

**Costs will be incurred while the instance is running - anywhere from $0.16 - $0.22 USD/hour depending on region for `t3.xlarge` at time of writing**. Deploying this infrastructure will result in a running instance.</br>Ensure you [stop the instance](./park.md) when not in use.

The deployment will determine the public-facing IP address of the external router that the workstation you run the infrastructure deployment from sits behind, and will create a security group on the instance that permits ingress to only that address on all ports. The assumption being that you'll connect to the environment from the same machine you run the deployment from.

Change into the `terraform` directory and run

```
terraform plan
```

If you've built the AMI more than once, Terraform will select the latest version of it, redeploying the instance if it has been updated - ensure you copied anything you want to save off the instance!</br>
If all is good, then run

```
terraform apply
```

* [Next](./connect.md) - Connect to your new environment
* [Back](./ami.md) - Build the AMI
