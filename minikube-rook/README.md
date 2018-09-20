Install minikube & kubectl: https://kubernetes.io/docs/tasks/tools/install-minikube/

---

Start minikube:

```
minikube start
```

---

Create the rook pod operators:
```
kubectl create -f operator.yaml
```
Wait for the Agent, Operator and Discover pods to be running in the `rook-ceph-system` namespace.

---

Create the Rook cluster:
```
kubectl create -f rook-cluster.yaml
```
Wait for the monitors and OSD pods to be running.

---

Expose the Ceph dashboard
```
kubectl create -f dashboard-external.yaml
```

---

Rook toolbox and Object Store can't be implemented in minikube since the cluster runs in a single node. More nodes are necessary to further implement Rook in k8s.