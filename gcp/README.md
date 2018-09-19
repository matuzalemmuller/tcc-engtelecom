This documentation presents step by step instructions on how to set up a kubernetes cluster in Virtual Machines (VMs) from Google Cloud Platform (GCP). The cloud infrastructure is launched using Terraform, while the kubernetes cluster is remotely setup using Docker & Rancher.

* Instructions on how to use Terraform to launch VMs are based in: https://medium.com/@josephbleroy/using-terraform-with-google-cloud-platform-part-1-n-6b5e4074c059

---

### Create a project in GCP

https://cloud.google.com/resource-manager/docs/creating-managing-projects

--- 
### Setup Terraform in local device. These instructions are for OSX.

Install Terraform in local device:
```
mkdir /usr/local/terraform
wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_darwin_amd64.zip
unzip terraform_0.10.8_darwin_amd64.zip -d /usr/local/terraform
```

Set the PATH variable for Terraform:
```
vim ~/.bash_profile 
. . . 
# Required by Terraform
export PATH=$PATH:/usr/local/terraform
. . .
```

Restart the console/terminal and confirm that Terraform works:
```
terraform -v
```

---
### Download and install Google SDK

Download and install Google SDK:
```
curl https://sdk.cloud.google.com | bash
```

Start the gcloud enviroment and connect to your account and project:
```
gcloud init
```

---
### Modify gcp-cluster.tf file to include correct account information and credentials

Generate local SSH keys, which will be used to connect to the remote VMs. Save both keys with the default name (id_rsa) and blace both keys inside the directory "keys":
```
ssh-keygen -t rsa -b 4096 -C "email@domain.com"
```

Modify the file `gcp-cluster` to include the user that will be created in the remote VMs and point to the project created in GCP (note that you should include the project ID):
```
(line 3)  default = "user"
...
(line 14) project = "test-project-1234"
```

Download the JSON credential of the service account which will be used by Terraform to manage the GCP resources and save this file with the name "gcp.json" inside the "keys" directory:
https://console.cloud.google.com/apis/credentials/serviceaccountkey

---
### Run Terraform and create the GCP infrastructure

Run the following commands to see the changes that will be made by terraform, apply these changes and destroy them, respectively:
```
terraform plan
terraform apply 
terraform destroy
```

--- 
### Install docker in all VMs created
https://docs.docker.com/install/linux/docker-ce/debian/#install-from-a-package