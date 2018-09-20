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

Start the gcloud environment and connect to your account and project:
```
gcloud init
```

---
### Modify terraform-cluster.tf file to include correct account information and credentials

Generate local SSH keys, which will be used to connect to the remote VMs. Save both keys with the default name (id_rsa) and place both keys inside the directory "keys":
```
ssh-keygen -t rsa -b 4096 -C "email@domain.com"
```

Modify the file `terraform-cluster.tf` to include the user that will be created in the remote VMs and point to the project created in GCP (note that you should include the project ID):
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

---
### Install rke in local computer
https://rancher.com/docs/rke/v0.1.x/en/installation/

---
### Deploy remote k8s cluster

Modify the file `rancher-cluster.yml` to include the correct IPs and username so rancher can access the VMs and create the cluster. After changing the file, deploy the remote k8s cluster using rke:

```
rke up --config ./rancher-cluster.yml
```

* Note that when the VMs were started using terraform all the necessary firewall rules should have been setup already, but you may also need to change your settings to allow additional ports.

* Note that the version of docker installed in the VM needs to be compatible with the rke version installed in the local computer. For example, at the time this project is being worked on (Q3 of 2018), the latest stable release of rke is 1.9.0, which supports docker-ce 17.03.x. This is not the latest version of Docker at this time.

---
### Move k8s local file created by rancher to k8s local configuration folder

Move k8s configuration file created by rancher to the local configuration folder so k8s can locate the file and reach the nodes. Alternatively, you can also set the `KUBECONFIG` environmental variable to the path of `kube_config_rancher-cluster.yml`.
```
cp kube_config_rancher-cluster.yml ~/.kube/config
- or -
export KUBECONFIG=$(pwd)/kube_config_rancher-cluster.yml
```

---
### Install helm in remote k8s cluster

See https://github.com/helm/helm for instructions on how to install Helm.

After installing Helm, create the ServiceAccount and ClusterRobeBinding for the tiller service to manage charts.
```
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
```

Start Helm to be able to manage charts:
```
helm init
```

---
