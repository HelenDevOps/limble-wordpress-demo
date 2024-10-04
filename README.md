Limble WordPress on AWS with EKS, RDS

This project demonstrates how to set up a WordPress environment on AWS, using Kubernetes (EKS) to deploy the WordPress site, Amazon RDS (MariaDB) for the database, and AWS EBS for persistent storage. The infrastructure is managed with Terraform, and the WordPress application is deployed using Kubernetes manifests.

Project Structure

limble_assesment/
├── eks-module/                   # EKS cluster & worker nodes (Terraform)
├── helm-charts/
│   └── wordpress/k8s-templates/  # Kubernetes manifests for WordPress deployment
├── infra/                        # VPC & networking (Terraform)
├── rds/                          # RDS MariaDB instance (Terraform)
└── roots/project-limble/         # EKS & other resources (Terraform)

How to Set Up

Provision Infrastructure with Terraform:

    1.Navigate to infra/, rds/, and roots/project-limble/.

    2.Run:
        terraform init
        terraform apply

Deploy WordPress on EKS:

    1.Navigate to helm-charts/wordpress/k8s-templates/.
    2.Update secrets.yaml with your RDS credentials.
    3.Apply Kubernetes manifests:

        kubectl apply -f deployment.yaml -f service.yaml -f secrets.yaml
        or
        helm install my-wordpress ./ --namespace wordpress --values values.yaml


Verify Deployment:

    kubectl get pvc --namespace wordpress
    kubectl get pods --namespace wordpress

Get the external IP for WordPress:

    kubectl get svc --namespace wordpress
    
Conclusion
This project validates that WordPress can be hosted in containers on AWS using EKS with an RDS backend. The infrastructure is built with Terraform and optimized for speed.