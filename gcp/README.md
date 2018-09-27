This documentation presents step by step instructions on how to set up a kubernetes cluster in Virtual Machines (VMs) from Google Cloud Platform (GCP). The cloud infrastructure is launched using Terraform, while the kubernetes cluster is remotely setup using Docker & Rancher. The instructions from this article are for OSX, but are also applicable to Linux hosts and possibly Windows devices.

* Instructions on how to use Terraform to launch VMs are based in: https://medium.com/@josephbleroy/using-terraform-with-google-cloud-platform-part-1-n-6b5e4074c059
* Below are the versions of each software used in this project:
  * Terraform v0.11.8
  * RKE v0.1.9
  * Docker v17.03.3
  * Rook v0.8.2 (beta)
  * kubectl v1.11.0
  * Kubernetes v.v1.11.1

<details><summary><big><b>Table of contents</b></big></summary>
<!--ts-->
  * [Create a project in GCP](#create-a-project-in-gcp)
  * [Setup Terraform in local device](#setup-terraform-in-local-device)
  * [Download and install Google SDK](#download-and-install-google-sdk)
  * [Modify terraform-infrastructure.tf file to include correct account information and credentials](#modify-terraform-infrastructuretf-file-to-include-correct-account-information-and-credentials)
  * [Run Terraform and create the GCP infrastructure](#run-terraform-and-create-the-gcp-infrastructure)
  * [Install docker in all VMs created](#install-docker-in-all-vms-created)
  * [Install rke in local computer](#install-rke-in-local-computer)
  * [Deploy remote k8s cluster](#deploy-remote-k8s-cluster)
  * [Move k8s local file created by rancher to k8s local configuration folder](#deploy-remote-k8s-cluster)
  * [Install Helm in remote k8s cluster](#install-Helm-in-remote-k8s-cluster)
  * [Install Rook Operator chart using Helm](#install-rook-operator-chart-using-Helm)
  * [Create Rook cluster](#create-rook-cluster)
  * [Run Rook toolbox](#run-rook-toolbox)
  * [Create Storage Class](#create-storage-class)
  * [Install WordPress chart](#install-wordpress-chart)

<!--te-->
</details>

## Setup remote infrastructure

### Create a project in GCP

https://cloud.google.com/resource-manager/docs/creating-managing-projects

---
### Setup Terraform in local device

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
cd remote-setup
curl https://sdk.cloud.google.com | bash
```

Start the gcloud environment and connect to your account and project:
```
gcloud init
```

---
### Modify terraform-infrastructure.tf file to include correct account information and credentials

Generate local SSH keys, which will be used to connect to the remote VMs. Save both keys with default name (id_rsa) and place both keys inside the directory "keys":
```
ssh-keygen -t rsa -b 4096 -C "email@domain.com"
```

Modify the file `remote-setup/terraform-infrastructure.tf` to include the user that will be created in the remote VMs and point to the project created in GCP (note that you should include the project ID):
```
(line 3)  default = "user"
...
(line 14) project = "test-project-1234"
```

Download the JSON credential of the service account which will be used by Terraform to manage the GCP resources and save this file with the name "gcp.json" inside the "keys" directory:
https://console.cloud.google.com/apis/credentials/serviceaccountkey

---
### Run Terraform and create the GCP infrastructure

Run the following commands within the `remote-setup` folder to see the changes that will be made by terraform, apply these changes and destroy them, respectively:
```
terraform plan
terraform apply
terraform destroy
```

---
### Install docker in all VMs created

https://docs.docker.com/install/linux/docker-ce/debian/#install-from-a-package
https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/

Give permissions to the user created in the remote VMs to run docker:
```
sudo usermod -aG docker <username>
```

---
### Install rke in local computer
https://rancher.com/docs/rke/v0.1.x/en/installation/

---
### Deploy remote k8s cluster

Modify the file `remote-setup/cluster.yml` to include the correct IPs and username so rancher can access the VMs and create the cluster. After changing the file, deploy the remote k8s cluster using rke:

```
rke up --config ./cluster.yml
```

* Note that when the VMs were started using terraform all the necessary firewall rules should have been setup already, but you may also need to change your settings to allow additional ports.

* The docker version installed in the VM needs to be compatible with the rke version installed in the local computer. For example, at the time this project is being worked on (Q3 of 2018) the latest stable release of rke is 1.9.0, which supports docker-ce 17.03.x. This is not the latest version of Docker at this time.

---
### Move k8s local file created by rancher to k8s local configuration folder

Move k8s configuration file created by rancher to the local configuration folder so k8s can locate the file and reach the nodes. Alternatively, you can also set the `KUBECONFIG` environmental variable to the path of `kube_config_cluster.yml`.
```
mv kube_config_cluster.yml config/ && cp config/kube_config_cluster.yml ~/.kube/config
- or -
export KUBECONFIG=$(pwd)/kube_config_cluster.yml
```

---
### Install Helm in remote k8s cluster

See https://github.com/Helm/Helm for instructions on how to install Helm in your local computer.

Since RBAC is enabled in the cluster it's necessary to create a ServiceAccount and ClusterRobeBinding for the tiller service to manage charts.
```
kubectl --namespace kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
kubectl --namespace kube-system patch deploy/tiller-deploy -p '{"spec": {"template": {"spec": {"serviceAccountName": "tiller"}}}}'
```

Start Helm to be able to manage charts:
```
Helm init
```

---
## Install Rook

### Install Rook Operator chart using Helm

Add the rook beta channel to Helm:
```
Helm repo add rook-beta https://charts.rook.io/beta
```

Install the rook chart:
```
Helm install  rook-beta/rook-ceph --namespace rook-ceph-system --name rook-ceph --set agent.flexVolumeDirPath=/var/lib/kubelet/volumeplugins
```

Installing the operator will create 7 pods:
* 3 rook agents, which will be running in each node
* 3 rook discovers, which will be running in each node
* 1 rook operator, which will be running in the master node

For more information about the configuration "agent.flexVolumeDirPath=/var/lib/kubelet/volumeplugins", visit [this link](https://github.com/rook/rook/blob/master/Documentation/flexvolume.md#configuring-the-rook-operator)

---
### Create Rook Cluster

This will deploy a rook cluster with monitors (MON), OSDs and a manager (MGR). All the necessary requirements such as namespaces and roles will also be created. However, it will still be necessary to setup for what rook will be used (i.e. object store, filesystem, etc).

```
kubectl create -f cluster.yaml
```

This command will create 10 pods:
* 3 monitors, which will be running in each node
* 3 osd prepare, which will run and complete in each node
* 3 osds, which will be running in each node
* 1 rook manager, which will be running in the master node

---
### Run Rook Toolbox

Rook toolbox allows to connect to the cluster via CLI and analyze the underlying Ceph system running cluster, which helps troubleshooting issues.

```
kubectl create -f toolbox.yaml
```

Wait for the toolbox to change the status to running:
```
kubectl -n rook-ceph get pod rook-tools
```

Access the rook toolbox pod:
```
kubectl -n rook-ceph exec -it rook-tools-XXX bash
```

Note: this pod can and will be assigned to any node automatically.

---
## Install WordPress chart and use Rook volume & bucket to store files

### Create Storage Class

Deploy storage class:

```
kubectl create -f storage-class.yaml
````

---
### Install WordPress chart

Install WordPress chart using Helm:
```
helm install stable/wordpress --name wordpress --set persistence.storageClass=rook-ceph-block
```

* This will install WordPress and create volumes based in the storage class `rook-ceph-block`
* More configurable parameters can be checked at https://github.com/helm/charts/tree/master/stable/wordpress
