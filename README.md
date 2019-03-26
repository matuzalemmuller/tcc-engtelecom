## Undergraduate thesis: k8s + rook

*Hosted at [GitLab](https://gitlab.com/matuzalemmuller/tcc-engtelecom) and mirrored to [GitHub](https://github.com/matuzalemmuller/tcc-engtelecom).*

Final project for completion of undergraduate degree in Telecommunications Engineering at IFSC. Project page (in Portuguese): https://goo.gl/drWL8Y

Project consists of setting up a remote Kubernetes (k8s) cluster and deploying a WordPress application which accesses files stored in a storage system orchestrated by Rook.

Remote infrastructure is set up using Terraform to create Virtual Machines (VMs) and firewall rules in Google Cloud Platform (GCP). Kubernetes instalation is automated by Rancher and installation of Rook and WordPress are done through Helm.

Folder `remote-setup` contains step by step instructions on how to create the remote infrastructure and install k8s while folder `k8s-deployment` outlines how to run Rook and WordPress in the cluster.
