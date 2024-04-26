# PIN-Final
1- Ejecutamos el codigo creado en Terraform para realizar   una instacia EC2.

2- Crear rol ec2-admin.role y dar permisos AdmintratorAccess
asignar rol a la instancia ec2 que creamos
3- Nos conectamos a dicha instancia a traves de SSH.

4- Clonamos el repositorio "xx":
git clone https://github.com/xxx/PIN-Final.git

5- Creamos el cluster con siguiente codigo:

eksctl create cluster \
--name eks-cluster \
--region us-east-1 \
--node-type t3.small \
--nodes 3 \
--with-oidc \
--ssh-access \
--ssh-public-key mse_keypair \
--managed \
--full-ecr-access \
--zones us-east-1a,us-east-1b,us-east-1c

Nos conectamos al cluster de la siguiente manera:

aws eks update-kubeconfig --region us-east-1 --name eks-cluster

Comprobamos el cluster listando los nodos:

kubectl get nodes

6- Realizamos un deploy de nginx:
kubectl apply -f ./nginx.yaml

7- Verificamos el deply:
kubectl get pods -o wide

8- Comprobamos su funcionamiento:
kubectl get svc my-nginx-svc

lb_url="$(kubectl get svc my-nginx-svc | \
            grep my-nginx-svc | \
            awk '{print $4}')"

curl -k $lb_url

echo $lb_url

9- Instalamos driver cis ebs:
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.29"

10- Creamos politica:
eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster eks-cluster --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --role-only --role-name AmazonEKS_EBS_CSI_DriverRole --region us-east-1

11- Actualizamos repositorio para instalar Prometheus:
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

12- Creamos namespace prometheus:
kubectl create namespace prometheus

13- Instalamos Prometheus:
helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"

14- Verificamos Prometheus:
kubectl get all -n prometheus

Vemos que los pods de alertmanager y prometheus-server quedan en "Pending"

15- Procedemos a solucionar el problema:
Obtenemos account_id:
aws sts get-caller-identity --query "Account" --output text
account_id="$(aws sts get-caller-identity --query "Account" --output text)"

16- Creamos addon del driver EBS:
eksctl create addon --name aws-ebs-csi-driver --cluster eks-cluster --service-account-role-arn arn:aws:iam::$account_id:role/AmazonEKS_EBS_CSI_DriverRole --force --region us-east-1

17- Realizamos un forward a nuestro bastion:
kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090 --address 0.0.0.0

18- Ingresamos a url de Prometheus:

19- Creamos namespace grafana:
kubectl create namespace grafana

20- Actualizamos repositorios:
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

21- Instalamos Grafana:
helm install grafana grafana/grafana \
--namespace grafana \
--set persistence.storageClassName="gp2" \
--set persistence.enabled=true \
--set adminPassword='eks-grafana' \
--values ${HOME}/PIN-Final/grafana.yaml \
--set service.type=LoadBalancer

22- Comprobamos Grafana:
kubectl get all -n grafana

23- Obtenemos url:
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingresss[0].hostname}')
echo "http://$ELB"

24- Obtenemos las contraseña:
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

25- Ingresamos a url e imporatmos dashboard 3119 y 6417
