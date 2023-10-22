#!/bin/bash

# Define the pre-requisite function
pre_requisite() {
    # Check OS and print OS name
    os_name=$(uname)
    if [ "$os_name" == "Linux" ]; then
        echo "Operating System: Linux"
    elif [ "$os_name" == "Darwin" ]; then
        echo "Operating System: macOS"
    else
        echo "Unsupported Operating System"
        exit 1
    fi

    # Check for 'kind' or 'minikube' binary and install if not present
    if command -v kind &> /dev/null; then
        echo "kind binary found."
        k8s_tool="kind"
    elif command -v minikube &> /dev/null; then
        echo "minikube binary found."
        k8s_tool="minikube"
    else
        echo "Neither kind nor minikube binary found. Please install one of them."
        exit 1
    fi

    # Check for 'kubectl' binary
    if ! command -v kubectl &> /dev/null; then
        echo "kubectl binary not found. Exiting..."
        exit 1
    else
        echo "kubectl binary found."
        # Get the current context
        current_context=$(kubectl config current-context)
        if [ -z "$current_context" ]; then
            echo "Failed to get the current context. Exiting..."
            exit 1
        else
            echo "Current context: $current_context"
        fi
    fi

    # Additional actions can be added as needed, depending on whether 'kind' or 'minikube' is being used.
}

#!/bin/bash

install_dependencies() {
    # Install Ingress controller
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    # Wait for Ingress controller to be ready
    if ! kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s; then
      echo "Error: Ingress controller installation failed."
      exit 1
    fi

    # Create namespaces
    kubectl create ns monitor
    kubectl create ns ruby
    kubectl create ns argocd
}

install_monitoring() {
    # Install Prometheus for monitoring
    if ! helm install prometheus prometheus-community/kube-prometheus-stack -n monitor; then
        echo "Error: Monitoring installation failed."
        exit 1
    fi
}

install_argocd() {
    # Install ArgoCD
    if ! helm install argo argo/argo-cd -n argocd; then
        echo "Error: ArgoCD installation failed."
        exit 1
    fi
    # Wait for argo pods to come up
    if ! kubectl wait --namespace argocd \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/part-of=argocd \
      --timeout=360s; then
      echo "Error: argo-cd installation failed."
      exit 1
    fi

}

install_metrics_server() {
    # Install Metrics Server
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml

    # Patch Metrics Server deployment (assuming metric-server-patch.yaml is available)
    if ! kubectl patch deployment metrics-server -n kube-system --patch "$(cat metric-server-patch.yaml)"; then
        echo "Error: Metrics Server installation or patching failed."
        exit 1
    fi
}

login_to_argocd() {
    # Retrieve ArgoCD admin password
    PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    # Port Forward argo server
    kubectl port-forward svc/argo-argocd-server 9090:80  -n argocd 2>&1 > port_forward.log &
    # Log in to ArgoCD
    if ! argocd login localhost:9090 --insecure --username admin --password $PASSWORD; then
        echo "Error: ArgoCD login failed."
        exit 1
    fi
}

add_argo_app() {
    # Add an application to ArgoCD (assuming argo-project.yaml is available)
    if ! argocd repo add https://github.com/Privet-mir/ruby-http.git --type git; then 
        echo "Error: ArgoCD app creation failed."
        exit 1
    fi
    if ! argocd app create -f argo-project.yaml; then
       echo "Error: App create failed."
       exit 1
    fi
    if ! argocd app sync ruby; then
       echo "Error: App sync failed"
    fi
}

main() {
    # Perform the installation steps
    pre_requisite
    install_dependencies
    install_monitoring
    install_argocd
    install_metrics_server
    login_to_argocd
    add_argo_app
}

# Run the main function
main
