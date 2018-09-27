This documentation presents step by step instructions on how to run a WordPress application with MySQL database in a remote Kubernetes cluster located on Google Cloud Platform (GCP) using Rook as the storage orchestrator.

* Below are the versions of each software used in this project:
 * Docker v17.03.3
 * kubectl v1.11.0
 * Kubernetes v.v1.11.1

### Table of contents
<!--ts-->
 * [Setup remote infrastructure](#setup-remote-infrastructure)
 * [Install Rook Operator chart using Helm](#install-rook-operator-chart-using-helm)</li>
 * [Create Rook cluster](#create-rook-cluster)</li>
 * [Run Rook toolbox](#run-rook-toolbox)</li>
 * [Create Storage Class](#create-storage-class)</li>
 * [Install WordPress chart](#install-wordpress-chart)</li>
</ul>
<!--te-->

---
### Set up remote infrastructure

See [this documentation](https://gitlab.com/matuzalemmuller/tcc-engtelecom/tree/rook-helm/gcp/remote-setup) for instructions on how to setup the remote infrastructure and environment.

---
## Install Rook

### Install Rook Operator chart using Helm

Add the rook beta channel to Helm:
```
helm repo add rook-beta https://charts.rook.io/beta
```

Install the rook chart:
```
helm install rook-beta/rook-ceph --namespace rook-ceph-system --name rook-chart --set agent.flexVolumeDirPath=/var/lib/kubelet/volumeplugins
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

---

# Common issues

* Can't install cart because there's already a chart with that name installed even though it was removed: remove chart again using `--purge` flag
* `rook-ceph` namespace stuck in terminating status: https://github.com/rook/rook/issues/1488#issuecomment-397241621
* Monitors failing to start: https://github.com/rook/rook.github.io/blob/master/docs/rook/v0.7/common-problems.md#failing-mon-pod
* OSDs failing to start: https://github.com/rook/rook.github.io/blob/master/docs/rook/v0.7/common-problems.md#osd-pods-are-failing-to-start
* Volume creation doesn't work: https://github.com/rook/rook.github.io/blob/master/docs/rook/v0.7/common-problems.md#volume-creation
