gcloud config set project YOUR_PROJECT_ID
gcloud services enable container.googleapis.com

gcloud container clusters create echo-cluster \
    --num-nodes=2 \
    --machine-type=e2-standard-2 \
    --zone=us-east4-b


gcloud container clusters get-credentials echo-cluster \
    --zone=us-east4-b

kubectl create deployment nginx-demo \
  --image=nginx:stable \
  --replicas=2

kubectl get deployments
kubectl get pods -o wide
kubectl rollout status deployment/nginx-demo

kubectl expose deployment nginx-demo \
  --name nginx-public \
  --type LoadBalancer \
  --port 80 \
  --target-port 80

kubectl get services

kubectl get service nginx-public --watch

kubectl get service nginx-public \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo

http://EXTERNAL_IP

kubectl delete service nginx-public

gcloud container clusters delete echo-cluster \
  --zone=us-east4-b