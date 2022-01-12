# Amazon Linux 2 Development Environment

This liitle project arose out of a need to have a Linux-based development environment in order to do a pairing exercise for a job interview. Unfortunately my PC is running Windows, and whilst there are options such as WSL, Docker and VirtualBox, these environments don't really cut the mustard of a full Linux desktop system - especially when you want to run a browser against things that can be quite tricky to route outside the workstation, e.g. minikube dashboard.

Having an AWS account, I checked to see if it is possible to run a Linux GUI in EC2, and indeed [it is](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-linux-2-install-gui/). Upon reading this document, I immediately set about automating the build described such that I could stand it up and tear it back down again with minimum fuss.

## How it works

You create an AMI of the environment, then use Terraform to provision it in your AWS account. The deployed environment runs a VNC server to which you connect from your Windows PC via an SSH tunnel.

Note that the following should also work for Macs as there is a TigerVNC viewer for Mac, but you'll need to use the appropriate SSH tools for the system.

## Deploying the Environment

This assumes you're running Windows and want to deploy a Linux desktop in your AWS account.

### Prerequisites

* PuTTY - SSH client (including PuTTYgen for creating key pair)
* Tiger VNC Viewer
* Hashcorp Packer
* Hashicorp Terraform
* AWS Account.
    * Ensure you've configured the AWS CLI with defaults for credentials and the region you want to deploy in. Packer and Terraform will both assume the credentials. Packer only will assume the default region. Terrafrom requires an explict region specified. See [main.tf](./terraform/main.tf).
    * You will also need a VPC with an Internet Gateway and at least one public subnet.

All of the above software can be installed using [chocolatey](https://chocolatey.org/) on Windows:

```
choco install packer terraform putty tigervnc-viewer -y
```

Ideally have a hosted zone in Route53 so that Terraform can automatically assign a DNS record to the instance.

Follow this guide to get up and running

1. [Generate SSH keypair](./docs/keypair.md)
1. [Build the AMI](./docs/ami.md)
1. [Provision Infrastructure](./docs/provision.md)
1. [Connect to your new environment](./docs/connect.md)
1. [Parking/Reusing your instance](./docs/park.md)
