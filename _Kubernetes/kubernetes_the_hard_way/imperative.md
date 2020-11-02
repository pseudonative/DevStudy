kubectl run --image=nginx nginx

kubectl create deployment --image=nginx nginx

kubectl expose deployment nginx --port 80

kubectl edit deployment nginx

kubectl scale deployment nginx --replicas=5

kubectl set image deployment nginx nginx=nginx:1.18


