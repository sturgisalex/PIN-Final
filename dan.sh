# PIN Final Mundose

account_id="$(aws sts get-caller-identity --query "Account" --output text)"

## Cluster

eksctl create cluster \
--name eks-mundos-e \
--region us-east-1 \
--node-type t3.small \
--nodes 3 \
--with-oidc \
--ssh-access \
--ssh-public-key /tmp/sshkey.pub \
--managed \
--full-ecr-access \
--zones us-east-1a,us-east-1b,us-east-1c

## NGINX

kubectl create namespace mundos-e-nginx

git clone https://github.com/danterpaniagua/mundose-pin2-eks-configs.git

kubectl apply -f mundose-pin2-eks-configs/deployment.yaml
kubectl apply -f mundose-pin2-eks-configs/service.yaml

### Debug

kubectl get deploy,svc,po  -n mundos-e-nginx
kubectl get services -n mundos-e-nginx

## Prometheus

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.29"
eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster eks-mundos-e --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --role-only --role-name AmazonEKS_EBS_CSI_DriverRole --region us-east-1

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace prometheus
helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"

aws sts get-caller-identity --query "Account" --output text
eksctl create addon --name aws-ebs-csi-driver --cluster eks-mundos-e --service-account-role-arn arn:aws:iam::$account_id:role/AmazonEKS_EBS_CSI_DriverRole --force --region us-east-1
kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090 --address 0.0.0.0

### Debugging

kubectl get all -n prometheus
kubectl describe pvc prometheus-server -n prometheus
kubectl get pvc,po -n prometheus


## Grafana

kubectl create namespace grafana



helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana \
--namespace grafana \
--set persistence.storageClassName="gp2" \
--set persistence.enabled=true \
--set adminPassword='EKS!sAWSome' \
--values ${HOME}/mundose-pin2-eks-configs/helm_grafana.yaml \
--set service.type=LoadBalancer

helm destroy grafana grafana/grafana

kubectl get all -n grafana