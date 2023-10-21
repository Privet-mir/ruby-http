# Ruby HTTP

This Bash script is designed to automate the installation and configuration of various Kubernetes components, including Ingress controller, monitoring with Prometheus, ArgoCD, Metrics Server, and more. It also checks for potential installation failures.

## Prerequisites

Before running the script, make sure you have the following tools and resources set up:

- **Kubernetes Cluster**: You should have a running Kubernetes cluster where you want to install the components.

- **kubectl**: Ensure that you have `kubectl` installed and properly configured to manage your Kubernetes cluster.

- **Helm**: Helm is required for installing Prometheus, ArgoCD, and other components. Make sure Helm is installed and initialized.

- **Kind or Minikube**: The script checks for the presence of either "kind" (Kubernetes in Docker) or "minikube." You can have one of them installed in your environment.

- **metric-server-patch.yaml**: If you need to patch the Metrics Server deployment, provide the necessary patch file.

- **argocd-project.yaml**: If you intend to add an ArgoCD application, ensure that this configuration file is available.

## Usage

Clone this repository to your local machine and execute below commands:

   ```shell
   $: git clone https://github.com/your-username/kubernetes-automation-script.git

   $: cd ruby-http

   $: chmod +x script.sh

   $: ./script.sh
   ```

The script will perform the following tasks:

* Install Ingress controller.
* Install and configure Prometheus for monitoring.
* Install ArgoCD for GitOps.
* Install the Metrics Server and apply any necessary patches.
* Log in to ArgoCD and add an application.

