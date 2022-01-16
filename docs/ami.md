# Build the AMI

Using packer, we create an AMI which will be an image of the entire environment. The packer build requires all the following variables to be defined:

| Variable | Value |
|----------|-------|
| linux_username | Username of linux user to create for yourself |
| linux_password | Password for the above user |
| vnc_password | Password to connect to VNC server (see below) |
| ssh_public_key | Path to public key file for the keypair you will create to access the system (see above) |

It's much easier to put the your own values for these variables into a `vars.json` file in the `packer` directory, like this

```json
{
    "linux_username": "johndoe",
    "linux_password": "jdpassword",
    "vnc_password": "vncpassword",
    "ssh_public_key": "./path/to/pubkey.pub"
}
```

Now examine [provision.sh](../packer/provision.sh) and add in, modify or remove developer tools. The default in this repository installs the following:

* Visual Studio Code
* Chromium browser
* Docker
* git
* Minikube and kubectl
* GoLang 1.17.6
* Python 3.8 + devel
* gcc compiler suite and associated tooling
* Java JDK 17 (JAVA_HOME etc. will need configuring when you start the environment)
* NodeJS 16
* PowerShell
* Dotnet Core 3.1 SDK

Change into the `packer` directory and build the AMI as follows

```
packer build -var-file vars.json devenv.json
```

* [Next](./provision.md) - Provision Infrastructure
* [Back](./keypair.md) - Generate Key Pair