# PIN-Final
1- Ejecutamos el codigo creado en Terraform para realizar   una instacia EC2.

2- Nos conectamos a dicha instancia a traves de SSH.

3- Clonamos el repositorio "xx":
git clone https://github.com/xxx/PIN-Final.git

4- Ejecutamos el codigo creado en Terraform para realizar un Cluster EKS.

5- Comprobamos los nodos del cluster:
kubectl get nodes

6- Realizamos un deploy de nginx:
kubectl --kubeconfig ./kubeconfig apply -f ./run-my-nginx.yaml

7- Verificamos el deply:
kubectl get pods -o wide

8- lo exponemos mediante el servicio Load Balancer:
kubectl expose deployment/nginx \
        --port=80 --target-port=80 \
        --name=my-nginx-service --type=LoadBalancer

9- Comprobamos su funcionamiento:
kubectl get svc my-nginx-service

lb_url="$(kubectl get svc my-nginx-service | \
            grep my-nginx-service | \
            awk '{print $4}')"

curl -k $lb_url

echo $lb_url

10- Instalación del driver EBS
kubectl apply -k
"github.com/kubernetes-sigs/aws-ebs-csi-
driver/deploy/kubernetes/overlays/stable/?ref=rele ase-1.20"
(verificar)

11- Instalamos Prometheus:
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
kubectl create namespace prometheus
helm install prometheus prometheus-community/prometheus --namespace prometheus --setalertmanager.persistentVolume.storageClass="gp2" --set server.persistentVolume.storageClass="gp2"

12- Comprobamos deployment de Prometeus:
kubectl get all -n prometheus

13- Exponemos Prometheus:
kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090 --address 0.0.0.0

14- Instalamos Grafana:
kubectl create namespace grafana

helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='grafana' \
    --values ${HOME}/environment/grafana/grafana.yaml \
    --set service.type=LoadBalancer

15- Comprobamos deploy de Grafana:
kubectl get all -n grafana

16- Obtenemos url:
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingresss[0].hostname}')
echo "http://$ELB"

16- Obtenemos las contraseña:
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

17- Ingresamos a url e imporatmos dashboard 3119 y 6417
