# WordPress Deployment with Helm on EKS

## Prerequisites
1. EKS cluster running.
2. Helm installed on your local machine.

## Steps to Deploy WordPress:

1. Add the Bitnami repository to Helm:
   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm repo update