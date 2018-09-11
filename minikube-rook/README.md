
Install minikube & kubectl: https://kubernetes.io/docs/tasks/tools/install-minikube/

Start minikube:

```
minikube start
```

Create the rook pod operators:
```
kubectl create -f operator.yaml
```
Wait for the Agent, Operator and Discover pods to be running in the `rook-ceph-system` namespace.


Create the Rook cluster:
```
kubectl create -f rook-cluster.yaml
```
Wait for the monitors and OSD pods to be running.

Expose the Ceph dashboard
```
kubectl create -f dashboard-external.yaml
```

Run Rook toolbox
```
kubectl create -f toolbox.yaml
```
