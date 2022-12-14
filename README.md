# AWS Kube Services with Terraform

## Requirements

* Minikube
* AWS
* Docker
* Terraform
* Helm
* Jenkins
* ArgoCD

```shell
# start minikube with following extra config for kube-prometheus stack
minikube start --kubernetes-version=v1.24.0 --memory=8g --bootstrapper=kubeadm --extra-config=kubelet.authentication-token-webhook=true --extra-config=kubelet.authorization-mode=Webhook --extra-config=scheduler.bind-address=0.0.0.0 --extra-config=controller-manager.bind-address=0.0.0.0
```

## Chart Version and App Version
| App Name  | Chart Version | App Version |
| ------------- | ------------- |  -------------|
| [Redis](https://artifacthub.io/packages/helm/bitnami/redis)  | 17.3.7  | 7.0.5  |
| [cert-manager](https://artifacthub.io/packages/helm/cert-manager/cert-manager)  | 1.10.0  | v1.10.0  |
| [nginx-ingress](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx)  | 4.3.0  | 1.4.0  |
| [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)  | 41.5.1  | 0.60.1  |
| [hashicorp-vault](https://artifacthub.io/packages/helm/hashicorp/vault)  | 0.22.0  | 1.11.3  |
| [External Secret Operator](https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets)  | 0.6.0  | v0.6.0  |
| [ArgoCD](https://artifacthub.io/packages/helm/argo/argo-cd)  | 5.8.2  | v2.5.0  |



## TO DOs

* VPC &#10060;
* Route53 &#10060;
* EKS &#10060;
* EC2 &#10060;
* S3 &#10060;
* Load Balancer &#10060;
* IAM &#10060;
* Gitlab-CI &#10060;
