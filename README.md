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

## Useful Links

* [AWS All Terraform Modules](https://gitlab.gluzdov.com/public-repos/terraform_modules)
* [AWS Workshop EKS](https://tf-eks-workshop.workshop.aws/000_workshop_introduction.html)
* [AWS VPC Example](https://adamtheautomator.com/terraform-vpc/)
* [AWS EKS Terraform Example](https://medium.com/devops-mojo/terraform-provision-amazon-eks-cluster-using-terraform-deploy-create-aws-eks-kubernetes-cluster-tf-4134ab22c594)
* [AWS Public/Private Subnets with Terrafrom](https://medium.com/@kuldeep.rajpurohit/vpc-with-public-and-private-subnet-nat-on-aws-using-terraform-85a18d17c95e)
* [IAM-Module-1](https://github.com/cytopia/terraform-aws-iam/tree/master)
* [IAM-Module-2](https://gitlab.gluzdov.com/public-repos/terraform_modules/-/tree/master/terraform-aws-iam)

* [Encrypt/Decrypt values/files with Terraform/Terragrunt](https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1#4df5)

* [AWS EKS Terraform Example-IMPORTANT](https://rderik.com/blog/setting-up-a-kubernetes-cluster-in-amazon-eks-using-terraform/)

* [Istio Network Policy Example](https://repo1.dso.mil/big-bang/product/packages/istio-controlplane/-/tree/main/chart)

* [Isto-CNI explained](https://www.redhat.com/architect/istio-CNI-plugin)

#### SEE THIS
* [Use AWS ALB ingress controller for kube services](https://rtfm.co.ua/en/aws-elastic-kubernetes-service-running-alb-ingress-controller/)

* [Istio + AWS ALB Ingress Controller + Istio Ingress Gateway](https://rtfm.co.ua/en/istio-external-aws-application-loadbalancer-and-istio-ingress-gateway/)

* [Deploying an Istio Gateway with TLS in EKS using the AWS Load Balancer Controller](https://itnext.io/deploying-an-istio-gateway-with-tls-in-eks-using-the-aws-load-balancer-controller-448812e081e5)

* [Secure end-to-end traffic on Amazon EKS using TLS certificate in ACM, ALB, and Istio](https://aws.amazon.com/blogs/containers/secure-end-to-end-traffic-on-amazon-eks-using-tls-certificate-in-acm-alb-and-istio/)

## TO DOs

* VPC &#9989;
* IAM &#9989;
* Route53 &#9989;
* EC2 &#9989;
* EKS &#9989;
* Load Balancer &#9989;
* RDS &#9989;
* S3 &#9989;
* KMS &#9989;
* AWS Secrets Manager &#9989;
* Gitlab-CI &#9989;
