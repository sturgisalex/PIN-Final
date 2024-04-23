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
10- 
