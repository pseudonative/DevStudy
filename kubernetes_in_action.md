# This document is to be done everyday for repetition study
# Try to throw the cluster up the night before - saves time
# maybe even run 2 or 3 to practice moving between clusters
# aliases
k=kubectl
kd='kubectl describe'
kdel='kubectl delete'
kg='kubectl get'
ktx='k config get-contexts'
kuse='k config use-context'

# moving between clusters
kubectl config get-clusters

kubectl config use-cluster <cluster name>

gcloud container clusters create <name> --machine-type=MACHINE_TYPE   # f1-micro

# after cluster is built or if built on another workstation

gcloud container clusters get-credentials <name> 

kubectl cluster-info

Kubernetes master is running at https://35.222.43.4
GLBCDefaultBackend is running at https://35.222.43.4/api/v1/namespaces/kube-system/services/default-http-backend:http/proxy
Heapster is running at https://35.222.43.4/api/v1/namespaces/kube-system/services/heapster/proxy
KubeDNS is running at https://35.222.43.4/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://35.222.43.4/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

kubectl get nodes

kubectl describe <node name>

# deploy a pod via kubectl run

kubectl run kubia --image=luksa/kubia --port=8080 --generator=run/v1

# in another terminal window

kg po --watch 

# check the pod

kg po 
kg po -owide
➜  kubernetes_in_action git:(master) ✗ kg po -owide
NAME          READY   STATUS    RESTARTS   AGE     IP          NODE                                   NOMINATED NODE   READINESS GATES
kubia-8xvqb   1/1     Running   0          3m5s    10.4.1.19   gke-chaos-default-pool-57deedda-0q0n   <none>           <none>
kubia-p9982   1/1     Running   0          7m14s   10.4.1.18   gke-chaos-default-pool-57deedda-0q0n   <none>           <none>
kubia-vqdk4   1/1     Running   0          3m5s    10.4.2.5    gke-chaos-default-pool-57deedda-0gdt   <none>           <none>

kg po -oyaml
kd po 
kd po | more
kd po | grep -Ei Node: | awk '{print $1  "   "  $2}'
Node:   gke-chaos-default-pool-57deedda-0q0n/10.128.15.220

kd po | grep -Ei ready | awk '{print $1  "   "  $2}'
Ready:   True
Ready   True
ContainersReady   True
Tolerations:   node.kubernetes.io/not-ready:NoExecute



➜  kubernetes_in_action git:(master) ✗ kg rc
NAME    DESIRED   CURRENT   READY   AGE
kubia   1         1         1       12m



➜  kubernetes_in_action git:(master) ✗ kd rc
Name:         kubia
Namespace:    default
Selector:     run=kubia
Labels:       run=kubia
Annotations:  <none>
Replicas:     1 current / 1 desired
Pods Status:  1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  run=kubia
  Containers:
   kubia:
    Image:        luksa/kubia
    Port:         1100/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  12m   replication-controller  Created pod: kubia-4lvdh



➜  kubernetes_in_action git:(master) ✗ kd rc | grep -Ei Normal | awk '{print $1 "   " $2}'
Normal   SuccessfulCreate

# expose the replication controller

k expose rc kubia --type=LoadBalancer --name kubia-http

➜  kubernetes_in_action git:(master) ✗ kg svc
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP      10.7.240.1     <none>        443/TCP          46h
kubia-http   LoadBalancer   10.7.241.152   <pending>     1100:31157/TCP   12s


➜  kubernetes_in_action git:(master) ✗ kg svc  
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
kubernetes   ClusterIP      10.7.240.1     <none>          443/TCP          46h
kubia-http   LoadBalancer   10.7.241.152   34.68.141.247   1100:31157/TCP   49s  # External IP and Port


# Check the Load Balancer service

➜  kubernetes_in_action git:(master) ✗ ping 34.68.141.247
PING 34.68.141.247 (34.68.141.247) 56(84) bytes of data.
64 bytes from 34.68.141.247: icmp_seq=27 ttl=42 time=35.0 ms
64 bytes from 34.68.141.247: icmp_seq=28 ttl=42 time=33.7 ms
64 bytes from 34.68.141.247: icmp_seq=29 ttl=42 time=38.5 ms
^C
--- 34.68.141.247 ping statistics ---
29 packets transmitted, 3 received, 89% packet loss, time 28003ms
rtt min/avg/max/mdev = 33.745/35.771/38.555/2.046 ms

➜  kubernetes_in_action git:(master) ✗ curl 34.68.141.247:8080
You've hit kubia-p9982


# Scale the Replication Controller

➜  kubernetes_in_action git:(master) ✗ kg rc
NAME    DESIRED   CURRENT   READY   AGE
kubia   1         1         1       3m37s


➜  kubernetes_in_action git:(master) ✗ k scale rc kubia --replicas=3
replicationcontroller/kubia scaled


➜  kubernetes_in_action git:(master) ✗ kg rc
NAME    DESIRED   CURRENT   READY   AGE
kubia   3         3         2       4m18s


➜  kubernetes_in_action git:(master) ✗ kg rc
NAME    DESIRED   CURRENT   READY   AGE
kubia   3         3         2       4m23s


➜  kubernetes_in_action git:(master) ✗ kg po
NAME          READY   STATUS              RESTARTS   AGE
kubia-8xvqb   1/1     Running             0          22s
kubia-p9982   1/1     Running             0          4m31s
kubia-vqdk4   0/1     ContainerCreating   0          22s


➜  kubernetes_in_action git:(master) ✗ kd rc        
Name:         kubia
Namespace:    default
Selector:     run=kubia
Labels:       run=kubia
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  run=kubia
  Containers:
   kubia:
    Image:        luksa/kubia
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age    From                    Message
  ----    ------            ----   ----                    -------
  Normal  SuccessfulCreate  4m43s  replication-controller  Created pod: kubia-p9982
  Normal  SuccessfulCreate  34s    replication-controller  Created pod: kubia-vqdk4
  Normal  SuccessfulCreate  34s    replication-controller  Created pod: kubia-8xvqb

# check the loadbalancer service now

➜  kubernetes_in_action git:(master) ✗ curl 34.68.141.247:8080
You've hit kubia-vqdk4
➜  kubernetes_in_action git:(master) ✗ curl 34.68.141.247:8080
You've hit kubia-p9982
➜  kubernetes_in_action git:(master) ✗ curl 34.68.141.247:8080
You've hit kubia-8xvqb


# Optonal - check to make sure pod svc rc removed before using YAML 

# kdel all --all
# kg po --all-namespaces
# kg svc --all-namespaces
# kg rc --all-namespaces

# create pod via YAML get in the habbit of using namespaces

k create -f kubia-manual.yaml -n default

apiVersion: v1
kind: Pod 
metadata:
  name: kubia-manual
spec:
  containers:
  - image: luksa/kubia
    name: kubia 
    ports:
    - containerPort: 8080
      protocol: TCP%            

kg po -oyaml

k logs <pod id>

k logs <pod id> -c <container>  # if multiple containers in pod

# forward local machines port to the pod

k port-forward <pod> 1111:8080

➜  yaml_files git:(master) ✗ k port-forward kubia-manual 1111:8080
Forwarding from 127.0.0.1:1111 -> 8080
Forwarding from [::1]:1111 -> 8080
Handling connection for 1111

 
curl localhost:1111

➜  kubernetes_in_action curl localhost:1111
You've hit kubia-manual


# Create POD with Labels 

➜  yaml_files git:(master) ✗ k create -f  kubia-manual-with-labels.yaml -n default
pod/kubia-manual-v2 created

➜  yaml_files git:(master) ✗ kg po
NAME              READY   STATUS    RESTARTS   AGE
kubia-manual      1/1     Running   0          42m
kubia-manual-v2   1/1     Running   0          3s


➜  yaml_files git:(master) ✗ kg po --show-labels
NAME              READY   STATUS    RESTARTS   AGE   LABELS
kubia-manual      1/1     Running   0          42m   <none>
kubia-manual-v2   1/1     Running   0          23s   creation_method=manual,env=prod


➜  yaml_files git:(master) ✗ k get po -L creation_method,env
NAME              READY   STATUS    RESTARTS   AGE    CREATION_METHOD   ENV
kubia-manual      1/1     Running   0          44m                      
kubia-manual-v2   1/1     Running   0          2m8s   manual            prod
kubia-sw7cq       1/1     Running   0          28s    



➜  yaml_files git:(master) ✗ k label po kubia-manual creation_method=manual
pod/kubia-manual labeled


➜  yaml_files git:(master) ✗ k label po kubia-manual-v2 env=debug --overwrite 
pod/kubia-manual-v2 labeled


➜  yaml_files git:(master) ✗ kg po -L creation_method,env
NAME              READY   STATUS    RESTARTS   AGE     CREATION_METHOD   ENV
kubia-manual      1/1     Running   0          51m     manual            
kubia-manual-v2   1/1     Running   0          9m31s   manual            debug
kubia-sw7cq       1/1     Running   0          7m51s    

       
➜  yaml_files git:(master) ✗ kg po -l creation_method=manual
NAME              READY   STATUS    RESTARTS   AGE
kubia-manual      1/1     Running   0          56m
kubia-manual-v2   1/1     Running   0          14m
➜  yaml_files git:(master) ✗    


➜  yaml_files git:(master) ✗ kg po -l env
NAME              READY   STATUS    RESTARTS   AGE
kubia-manual-v2   1/1     Running   0          14m
➜  yaml_files git:(master) ✗ 
➜  yaml_files git:(master) ✗ kg po -l '!env'   
NAME           READY   STATUS    RESTARTS   AGE
kubia-manual   1/1     Running   0          57m
kubia-sw7cq    1/1     Running   0          14m

# Label a Node

❯ kg no          
NAME                                   STATUS   ROLES    AGE   VERSION
gke-kubia-default-pool-75d2dcc5-32vf   Ready    <none>   37m   v1.14.10-gke.27
gke-kubia-default-pool-75d2dcc5-kq4k   Ready    <none>   37m   v1.14.10-gke.27
gke-kubia-default-pool-75d2dcc5-n7nd   Ready    <none>   37m   v1.14.10-gke.27
~/kubernetes_in_action/yaml_files                                                                                               ○ kubia


❯ k label node gke-kubia-default-pool-75d2dcc5-kq4k gpu=true
node/gke-kubia-default-pool-75d2dcc5-kq4k labeled
~/kubernetes_in_action/yaml_files                                                                                               ○ kubia


❯ kg no -l gpu=true
NAME                                   STATUS   ROLES    AGE   VERSION
gke-kubia-default-pool-75d2dcc5-kq4k   Ready    <none>   38m   v1.14.10-gke.27
~/kubernetes_in_action/yaml_files                                                                                               ○ kubia


❯ kg no -L gpu=true
NAME                                   STATUS   ROLES    AGE   VERSION           GPU=TRUE
gke-kubia-default-pool-75d2dcc5-32vf   Ready    <none>   38m   v1.14.10-gke.27   
gke-kubia-default-pool-75d2dcc5-kq4k   Ready    <none>   38m   v1.14.10-gke.27   
gke-kubia-default-pool-75d2dcc5-n7nd   Ready    <none>   38m   v1.14.10-gke.27   




➜  yaml_files git:(master) ✗ k create -f kubia-gpu.yaml -n default
pod/kubia-gpu created


❯ kg po
NAME              READY   STATUS    RESTARTS   AGE
kubia-2mjcz       1/1     Running   0          22m
kubia-gpu         1/1     Running   0          3s
.......


➜  yaml_files git:(master) ✗ k annotate po kubia-manual mycompany.com/someannotation="BadAss Shoshone"
pod/kubia-manual annotated


➜  yaml_files git:(master) ✗ kd po kubia-manual      

Annotations:  kubernetes.io/limit-ranger: LimitRanger plugin set: cpu request for container kubia
              mycompany.com/someannotation: BadAss Shoshone


➜  yaml_files git:(master) ✗ kg ns
NAME              STATUS   AGE
default           Active   2d1h
kube-node-lease   Active   2d1h
kube-public       Active   2d1h
kube-system       Active   2d1h
➜  yaml_files git:(master) ✗ 
➜  yaml_files git:(master) ✗ 
➜  yaml_files git:(master) ✗ kg po -n kube-system
NAME                                                        READY   STATUS    RESTARTS   AGE
event-exporter-v0.2.5-7df89f4b8f-hb9wr                      2/2     Running   0          2d1h
fluentd-gcp-scaler-54ccb89d5-t5v48                          1/1     Running   0          2d1h
fluentd-gcp-v3.1.1-8x84b                                    2/2     Running   0          2d1h
fluentd-gcp-v3.1.1-h6fww                                    2/2     Running   0          2d1h
fluentd-gcp-v3.1.1-k972r                                    2/2     Running   0          2d1h
heapster-gke-798d7cd8fc-p4wgc                               3/3     Running   0          2d1h
kube-dns-5877696fb4-ccctd                                   4/4     Running   0          2d1h
kube-dns-5877696fb4-lmxf4                                   4/4     Running   0          2d1h
kube-dns-autoscaler-8687c64fc-42vvj                         1/1     Running   0          2d1h
kube-proxy-gke-chaos-default-pool-57deedda-0gdt             1/1     Running   0          2d1h
kube-proxy-gke-chaos-default-pool-57deedda-0q0n             1/1     Running   0          2d1h
kube-proxy-gke-chaos-default-pool-57deedda-qbws             1/1     Running   0          2d1h
l7-default-backend-8f479dd9-tg87f                           1/1     Running   0          2d1h
metrics-server-v0.3.1-5c6fbf777-gn4j8                       2/2     Running   0          2d1h
prometheus-to-sd-7j25b                                      2/2     Running   0          2d1h
prometheus-to-sd-bzgzh                                      2/2     Running   0          2d1h
prometheus-to-sd-wtlxv                                      2/2     Running   0          2d1h
stackdriver-metadata-agent-cluster-level-744c9bbf67-d25wg   2/2     Running   0          2d1h


# create a custom namespace via YAML

➜  yaml_files git:(master) ✗ k create -f  custome-namespace.yaml
namespace/custom-namespace created

➜  yaml_files git:(master) ✗ kg ns
NAME               STATUS   AGE
custom-namespace   Active   3s
default            Active   2d1h
kube-node-lease    Active   2d1h
kube-public        Active   2d1h
kube-system        Active   2d1h


➜  yaml_files git:(master) ✗ k create -f kubia-manual.yaml -n custom-namespace
pod/kubia-manual created

➜  yaml_files git:(master) ✗ kg po -n custom-namespace
NAME           READY   STATUS    RESTARTS   AGE
kubia-manual   1/1     Running   0          11s

# Deleting Pods and namespaces

➜  yaml_files git:(master) ✗ kdel po kubia-gpu
pod "kubia-gpu" deleted
➜  yaml_files git:(master) ✗ 

 delete pods with label selectors

➜  yaml_files git:(master) ✗ kdel po -l creation_method=manual
pod "kubia-manual" deleted
pod "kubia-manual-v2" deleted

delete pods by deleting the whole namespace

➜  yaml_files git:(master) ✗ kdel ns custom-namespace
namespace "custom-namespace" deleted

➜  yaml_files git:(master) ✗ kg po
NAME          READY   STATUS    RESTARTS   AGE
kubia-sw7cq   1/1     Running   0          90m

➜  yaml_files git:(master) ✗ kdel po --all
pod "kubia-sw7cq" deleted

➜  kubernetes_in_action kg po
NAME          READY   STATUS        RESTARTS   AGE
kubia-k492d   1/1     Running       0          12s
kubia-sw7cq   1/1     Terminating   0          91m


➜  yaml_files git:(master) ✗ kg po
NAME          READY   STATUS    RESTARTS   AGE
kubia-k492d   1/1     Running   0          40s

➜  yaml_files git:(master) ✗ kdel all --all
pod "kubia-k492d" deleted
replicationcontroller "kubia" deleted
service "kubernetes" deleted

➜  yaml_files git:(master) ✗ kg po
No resources found in default namespace.



















