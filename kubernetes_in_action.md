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

# GCS Cluster
gcloud container clusters create <name> --machine-type=MACHINE_TYPE   # n1-standard-1

# EKS Cluster
eksctl create cluster -f /home/jeremy/AWS_EKS/eksctl/eks-course.yaml 

<!-- apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: jaykube
  region: us-east-1
nodeGroups:
  - name: ng-1
    instanceType: t2.small
    desiredCapacity: 3
    ssh: 
      publicKeyName: eks-course -->



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

k create -f  replicationController.yaml -n default

<!-- apiVersion: v1
kind: ReplicationController
metadata:
  name: kubia
spec:
  replicas: 1
  selector:
    app: kubia
  template:
    metadata:
      name: kubia
      labels:
        app: kubia
    spec:
      containers:
      - name: kubia
        image: luksa/kubia
        ports:
        - containerPort: 8080%                    -->

# in another terminal window

kg po --watch 

# check the pod

kg po 
kg po -owide
kg po <name> -owide

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
<!-- 
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
      protocol: TCP%             -->

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
<!-- 
apiVersion: v1
kind: Pod 
metadata: 
  name: kubia-manual-v2
  labels:
    creation_method: manual 
    env: prod 
spec:
  containers:
    - image: luksa/kubia
      name: kubia 
      ports:
      - containerPort: 8080 
        protocol: TCP
 -->


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




➜  yaml_files git:(master) ✗ k create -f kubia-gpu.yaml -n default
pod/kubia-gpu created
<!-- 
apiVersion: v1
kind: Pod 
metadata:
  name: kubia-gpu
spec:
  nodeSelector:
    gpu: "true"
  containers:
    - image: luksa/kubia
      name: kubia  -->

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
<!-- 
apiVersion: v1
kind: Namespace
metadata:
  name: custom-namespace% 

➜  yaml_files git:(master) ✗ kg ns
NAME               STATUS   AGE
custom-namespace   Active   3s
default            Active   2d1h
kube-node-lease    Active   2d1h
kube-public        Active   2d1h
kube-system        Active   2d1h -->


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

### Delete everything and move on


# create POD with liveness probe

k create -f kubia-liveness-probe.yaml -n default
<!-- 
apiVersion: v1
kind: Pod 
metadata:
  name: kubia-liveness
spec:
  containers:
    - name: kubia
      image: luksa/kubia-unhealthy
      livenessProbe:
          httpGet:
            path: / 
            port: 8080 

           -->
          
          
➜  yaml_files git:(master) ✗ kg po
NAME             READY   STATUS    RESTARTS   AGE
kubia-liveness   1/1     Running   0          89s
  


kd po
  Warning  Unhealthy  1s (x2 over 11s)  kubelet, gke-jaykube-default-pool-5886fede-bqds  Liveness probe failed: HTTP probe failed with statuscode: 500



➜  yaml_files git:(master) ✗ kg po
NAME             READY   STATUS    RESTARTS   AGE
kubia-liveness   1/1     Running   1          2m35s  <===== RESTARTS



➜  yaml_files git:(master) ✗ k logs kubia-liveness --previous 
Kubia server starting...
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1



  yaml_files git:(master) ✗ kd po kubia-liveness | grep -Ei "last state" | awk '{print $1 "  " $2 " "  $3 "    " $4}'        
Last  State: Terminated    
➜  yaml_files git:(master) ✗ kd po kubia-liveness | grep -Ei reason: | awk '{print $1 "  " $2 }'             
Reason:  Error

kdel po --all

✗ k create -f  kubia-liveness-probe-initial-delay.yaml -n default
<!-- 
apiVersion: v1
kind: Pod 
metadata:
  name: kubia-liveness
spec:
  containers:
    - name: kubia
      image: luksa/kubia-unhealthy
      livenessProbe:
          httpGet:
            path: / 
            port: 8080 
          initialDelaySeconds: 15
             -->

➜  yaml_files git:(master) ✗ kg po
NAME             READY   STATUS             RESTARTS   AGE
kubia-liveness   0/1     CrashLoopBackOff   6          13m

# Delete the POD and recreate with the delay


✗ k create -f  kubia-liveness-probe-initial-delay.yaml -n default


✗ kg po
NAME             READY   STATUS    RESTARTS   AGE
kubia-liveness   1/1     Running   0          10s



  yaml_files git:(master) ✗ kd po | grep -Ei liveness
Name:         kubia-liveness
    Liveness:     http-get http://:8080/ delay=15s timeout=1s period=10s #success=1 #failure=3
  Normal   Scheduled  2m                 default-scheduler                                Successfully assigned default/kubia-liveness to gke-jaykube-default-pool-5886fede-bqds
  Warning  Unhealthy  29s (x3 over 49s)  kubelet, gke-jaykube-default-pool-5886fede-bqds  Liveness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    29s                kubelet, gke-jaykube-default-pool-5886fede-bqds  Container kubia failed liveness probe, will be restarted


# Create Replica Controller 

k create -f  kubia-rc.yaml -n default
<!-- 
apiVersion: v1
kind: ReplicationController 
metadata:
  name: kubia
spec:
  replicas: 3
  selector:
    app: kubia 
  template:
    metadata:
      labels: 
        app: kubia 
    spec:
      containers:
        - name: kubia
          image: luksa/kubia
          ports:
          - containerPort: 8080 -->


➜  yaml_files git:(master) ✗ kg rc
NAME    DESIRED   CURRENT   READY   AGE
kubia   3         3         3       59s



➜  yaml_files git:(master) ✗ kg po
NAME             READY   STATUS    RESTARTS   AGE
kubia-24j2q      1/1     Running   0          4s
kubia-dcq2c      1/1     Running   0          4s
kubia-liveness   1/1     Running   3          6m37s
kubia-wbqxk      1/1     Running   0          4s



➜  yaml_files git:(master) ✗ kdel po kubia-24j2q kubia-wbqxk
pod "kubia-24j2q" deleted
pod "kubia-wbqxk" deleted



➜  DevStudy git:(master) ✗ kg po 
NAME             READY   STATUS              RESTARTS   AGE
kubia-24j2q      1/1     Terminating         0          115s
kubia-dcq2c      1/1     Running             0          115s
kubia-jhqw5      1/1     Running             0          2s
kubia-lhfmf      0/1     ContainerCreating   0          2s
kubia-liveness   1/1     Running             4          8m28s
kubia-wbqxk      1/1     Terminating         0          115s



  DevStudy git:(master) ✗ kg po
NAME             READY   STATUS    RESTARTS   AGE
kubia-dcq2c      1/1     Running   0          3m8s
kubia-jhqw5      1/1     Running   0          75s
kubia-lhfmf      1/1     Running   0          75s
kubia-liveness   1/1     Running   4          9m41s



# Introduce some Chaos - take down a node

➜  yaml_files git:(master) ✗ gcloud compute ssh gke-jaykube-default-pool-5886fede-bqds


jeremy@gke-jaykube-default-pool-5886fede-bqds ~ $ sudo ifconfig eth0 down


➜  DevStudy git:(master) ✗ kg no
NAME                                     STATUS     ROLES    AGE   VERSION
gke-jaykube-default-pool-5886fede-bqds   NotReady   <none>   72m   v1.14.10-gke.27



➜  DevStudy git:(master) ✗ kg no
NAME                                     STATUS     ROLES    AGE   VERSION
gke-jaykube-default-pool-5886fede-bqds   Ready      <none>   82m   v1.14.10-gke.27
gke-jaykube-default-pool-5886fede-ggs1   Ready      <none>   82m   v1.14.10-gke.27
gke-jaykube-default-pool-5886fede-s8nn   NotReady   <none>   82m   v1.14.10-gke.27



  DevStudy git:(master) ✗ kg po
NAME             READY   STATUS              RESTARTS   AGE
kubia-bpv67      0/1     ContainerCreating   0          2s
kubia-dcq2c      1/1     Running             2          22m
kubia-jhqw5      1/1     Running             2          20m
kubia-lhfmf      1/1     Unknown             0          20m
kubia-liveness   1/1     Running             11         28m



➜  ~ gcloud compute instances reset gke-jaykube-default-pool-5886fede-s8nn

➜  DevStudy git:(master) ✗ kg no
NAME                                     STATUS   ROLES    AGE   VERSION
gke-jaykube-default-pool-5886fede-bqds   Ready    <none>   89m   v1.14.10-gke.27
gke-jaykube-default-pool-5886fede-ggs1   Ready    <none>   89m   v1.14.10-gke.27
gke-jaykube-default-pool-5886fede-s8nn   Ready    <none>   89m   v1.14.10-gke.27



# Add labels to PODs managed by Replication Controller

➜  ~ k label po kubia-dcq2c type=special
pod/kubia-dcq2c labeled



➜  ~ kg po --show-labels
NAME             READY   STATUS    RESTARTS   AGE     LABELS
kubia-bpv67      1/1     Running   0          6m28s   app=kubia
kubia-dcq2c      1/1     Running   2          28m     app=kubia,type=special
kubia-jhqw5      1/1     Running   2          26m     app=kubia
kubia-liveness   1/1     Running   13         35m     <none>



➜  ~ k label po kubia-dcq2c app=foo --overwrite
pod/kubia-dcq2c labeled



➜  ~ kg po -L app
NAME             READY   STATUS    RESTARTS   AGE     APP
kubia-bpv67      1/1     Running   0          7m43s   kubia
kubia-dcq2c      1/1     Running   2          30m     foo
kubia-jhqw5      1/1     Running   2          28m     kubia
kubia-liveness   1/1     Running   13         36m     
kubia-s4jtm      1/1     Running   0          10s     kubia
➜  ~ 


# Horizontially scale the Replica Set

➜  ~ k scale rc kubia --replicas=10 
replicationcontroller/kubia scaled
➜  ~ kg rc
NAME    DESIRED   CURRENT   READY   AGE
kubia   10        10        6       33m



➜  ~ k edit rc kubia  # can also scale - k scale rc kubia --replicas=3

spec:
  replicas: 3  


➜  ~ kg rc
NAME    DESIRED   CURRENT   READY   AGE
kubia   3         3         3       35m
➜  ~ kg po
NAME             READY   STATUS        RESTARTS   AGE
kubia-bpv67      1/1     Running       0          13m
kubia-dcq2c      1/1     Running       2          35m
kubia-gvfwb      1/1     Terminating   0          119s
kubia-jhqw5      1/1     Running       2          33m
kubia-liveness   1/1     Running       14         42m
kubia-qg62l      1/1     Terminating   0          119s
kubia-s4jtm      1/1     Running       0          5m46s
kubia-sbmzk      1/1     Terminating   0          119s
kubia-tfjnt      1/1     Terminating   0          119s
kubia-tq7dd      1/1     Terminating   0          119s
kubia-v65ks      1/1     Terminating   0          119s
kubia-zznqt      1/1     Terminating   0          119s



➜  ~ kdel rc kubia --cascade=false
replicationcontroller "kubia" deleted
➜  ~ kg rc
No resources found in default namespace.
➜  ~ kg po
NAME          READY   STATUS    RESTARTS   AGE
kubia-bpv67   1/1     Running   0          16m
kubia-dcq2c   1/1     Running   2          38m
kubia-jhqw5   1/1     Running   2          37m
kubia-s4jtm   1/1     Running   0          9m5s


# Create Replica Set to adopt orphaned PODs

➜  ~ k create -f kubia-replicaset.yaml -n default
replicaset.apps/kubia created
<!-- 
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: kubia
spec:
  replicas: 3 
  selector:
    matchLabels: 
      app: kubia 
  template:
    metadata:
      labels:
        app: kubia 
    spec:
      containers:
        - name: kubia 
          image: luksa/kubia
 -->

➜  ~ kg rs
NAME    DESIRED   CURRENT   READY   AGE
kubia   3         3         3       41s


➜  ~ kd rs
Name:         kubia
Namespace:    default
Selector:     app=kubia
Labels:       <none>
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=kubia


# Add expressive Label Selectors to Replica Set

➜  ~ kdel rs kubia
replicaset.extensions "kubia" deleted


➜  ~ k create -f kubia-replicaset-matchexpressions.yaml -n default
replicaset.apps/kubia created
<!-- 
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: kubia
spec:
  replicas: 3 
  selector:
    matchExpressions:
      - key: app
        operator: In
        values:
        - kubia 
  template:
    metadata:
      labels:
        app: kubia 
    spec:
      containers:
        - name: kubia 
          image: luksa/kubia -->


➜  ~ kg po
NAME          READY   STATUS    RESTARTS   AGE
kubia-dcq2c   1/1     Running   2          49m
kubia-gctjt   1/1     Running   0          91s
kubia-w4zmx   1/1     Running   0          91s
kubia-wxdqh   1/1     Running   0          91s



➜  ~ kg po --show-labels
NAME          READY   STATUS    RESTARTS   AGE   LABELS
kubia-dcq2c   1/1     Running   2          49m   app=foo,type=special
kubia-gctjt   1/1     Running   0          99s   app=kubia
kubia-w4zmx   1/1     Running   0          99s   app=kubia
kubia-wxdqh   1/1     Running   0          99s   app=kubia
➜  ~ 



➜  ~ kdel rs --all
replicaset.extensions "kubia" deleted


# create Node Selector with Daemon set

➜  ~ k create  -f ssd-monitor-daemonset.yaml -n default
daemonset.apps/ssd-monitor created
<!-- 
apiVersion: apps/v1beta2
kind: DaemonSet
metadata:
  name: ssd-monitor 
spec:
  selector:
    matchLabels:
      app: ssd-monitor
  template:
    metadata:
      labels:
        app: ssd-monitor
    spec:
      containers:
        - name: main
          image: luksa/ssd-monitor 
      nodeSelector:
        disk: ssd 
         -->


➜  ~ kg ds
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
ssd-monitor   0         0         0       0            0           disk=ssd        112s


➜  ~ kg po
No resources found in default namespace.
➜  ~ 


k label node <node>  disk=ssd  # make a script to automate

➜  ~ k label node gke-jaykube-default-pool-5886fede-bqds disk=ssd
node/gke-jaykube-default-pool-5886fede-bqds labeled


➜  ~ kg po
NAME                READY   STATUS    RESTARTS   AGE
ssd-monitor-khgwh   1/1     Running   0          4s
➜  ~ 


# remove the label from the node

  ~ k label node gke-jaykube-default-pool-5886fede-bqds disk=hdd --overwrite
node/gke-jaykube-default-pool-5886fede-bqds labeled
➜  ~ 
➜  ~ 
➜  ~ 
➜  ~ kg po
NAME                READY   STATUS        RESTARTS   AGE
ssd-monitor-khgwh   1/1     Terminating   0          109s
➜  ~ 


➜  ~ kg ds
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
ssd-monitor   0         0         0       0            0           disk=ssd        6m39s
➜  ~ 
➜  ~ 
➜  ~ kdel ds ssd-monitor
daemonset.extensions "ssd-monitor" deleted
➜  ~ kg po
No resources found in default namespace.
➜  ~ 


# Define a Job Resource

➜  ~ k create -f  exporter.yaml -n default
job.batch/batch-job created

<!-- 
apiVersion: batch/v1
kind: Job 
metadata:
  name: batch-job 
spec: 
  template:
    metadata:
      labels:
        app: batch-job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: main
        image: luksa/batch-job
 -->

➜  ~ kg jobs
NAME        COMPLETIONS   DURATION   AGE
batch-job   0/1           22s        22s


➜  ~ kg po
NAME              READY   STATUS    RESTARTS   AGE
batch-job-mdbc4   1/1     Running   0          62s


➜  ~ kg jobs
NAME        COMPLETIONS   DURATION   AGE
batch-job   1/1           2m3s       2m23s



➜  ~ kg po
NAME              READY   STATUS      RESTARTS   AGE
batch-job-mdbc4   0/1     Completed   0          2m25s


➜  ~ k logs batch-job-mdbc4
Sat Apr 25 21:03:46 UTC 2020 Batch job starting
Sat Apr 25 21:05:46 UTC 2020 Finished succesfully



# Run Jobs in sequentially - This is optional if you have the time if not go to parallel

➜  ~ k create -f  multi-completion-batch-job.yaml -n default
job.batch/multi-completion-batch-job created
<!-- 

apiVersion: batch/v1
kind: Job 
metadata:
  name: multi-completion-batch-job
spec: 
  completions: 5
  template:
    metadata:
      labels:
        app: batch-job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: main
        image: luksa/batch-job
 -->


➜  ~ kg jobs
NAME                         COMPLETIONS   DURATION   AGE
batch-job                    1/1           2m3s       6m57s
multi-completion-batch-job   0/5           21s        21s


➜  ~ kg po
NAME                               READY   STATUS      RESTARTS   AGE
batch-job-mdbc4                    0/1     Completed   0          7m3s
multi-completion-batch-job-4s8kc   1/1     Running     0          27s



➜  ~ kg jobs
NAME                         COMPLETIONS   DURATION   AGE
batch-job                    1/1           2m3s       8m54s
multi-completion-batch-job   1/5           2m18s      2m18s



➜  ~ kg po
NAME                               READY   STATUS      RESTARTS   AGE
batch-job-mdbc4                    0/1     Completed   0          8m58s
multi-completion-batch-job-4s8kc   0/1     Completed   0          2m22s
multi-completion-batch-job-9g8f4   1/1     Running     0          20s


➜  ~ k logs multi-completion-batch-job-4s8kc
Sat Apr 25 21:10:22 UTC 2020 Batch job starting
Sat Apr 25 21:12:22 UTC 2020 Finished succesfully
➜  ~ 


➜  ~ kg jobs
NAME                         COMPLETIONS   DURATION   AGE
batch-job                    1/1           2m3s       10m
multi-completion-batch-job   2/5           4m17s      4m17s
➜  ~ kg po  
NAME                               READY   STATUS      RESTARTS   AGE
batch-job-mdbc4                    0/1     Completed   0          10m
multi-completion-batch-job-4s8kc   0/1     Completed   0          4m20s
multi-completion-batch-job-8g844   1/1     Running     0          16s
multi-completion-batch-job-9g8f4   0/1     Completed   0          2m18s
➜  ~ 


➜  ~ k logs multi-completion-batch-job-9g8f4
Sat Apr 25 21:12:24 UTC 2020 Batch job starting
Sat Apr 25 21:14:24 UTC 2020 Finished succesfully

  ~ kg jobs
NAME                         COMPLETIONS   DURATION   AGE
batch-job                    1/1           2m3s       15m
multi-completion-batch-job   4/5           9m         9m
➜  ~ kg po
NAME                               READY   STATUS      RESTARTS   AGE
batch-job-mdbc4                    0/1     Completed   0          15m
multi-completion-batch-job-4s8kc   0/1     Completed   0          9m2s
multi-completion-batch-job-8g844   0/1     Completed   0          4m58s
multi-completion-batch-job-9g8f4   0/1     Completed   0          7m
multi-completion-batch-job-pbxn8   0/1     Completed   0          2m56s
multi-completion-batch-job-x6ljh   1/1     Running     0          54s


# Run Jobs in Parallel

➜  ~ k create -f multi-completion-parallel-batch-job.yaml -n default

<!-- 
apiVersion: batch/v1
kind: Job 
metadata:
  name: multi-completion-parallel-batch-job
spec: 
  completions: 5
  parallelism: 2
  template:
    metadata:
      labels:
        app: batch-job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: main
        image: luksa/batch-job
 -->

➜  ~ kg jobs
NAME                                  COMPLETIONS   DURATION   AGE
batch-job                             1/1           2m3s       19m
multi-completion-batch-job            5/5           10m        13m
multi-completion-parallel-batch-job   0/5           4s         4s


➜  ~ kg po
NAME                                        READY   STATUS      RESTARTS   AGE
batch-job-mdbc4                             0/1     Completed   0          19m
multi-completion-batch-job-4s8kc            0/1     Completed   0          13m
multi-completion-batch-job-8g844            0/1     Completed   0          9m4s
multi-completion-batch-job-9g8f4            0/1     Completed   0          11m
multi-completion-batch-job-pbxn8            0/1     Completed   0          7m2s
multi-completion-batch-job-x6ljh            0/1     Completed   0          5m
multi-completion-parallel-batch-job-4r5jz   1/1     Running     0          8s
multi-completion-parallel-batch-job-wfxrn   1/1     Running     0          8s



➜  ~ kg jobs
NAME                                  COMPLETIONS   DURATION   AGE
batch-job                             1/1           2m3s       21m
multi-completion-batch-job            5/5           10m        15m
multi-completion-parallel-batch-job   2/5           2m4s       2m4s



➜  ~ kg po  
NAME                                        READY   STATUS      RESTARTS   AGE
batch-job-mdbc4                             0/1     Completed   0          21m
multi-completion-batch-job-4s8kc            0/1     Completed   0          15m
multi-completion-batch-job-8g844            0/1     Completed   0          11m
multi-completion-batch-job-9g8f4            0/1     Completed   0          13m
multi-completion-batch-job-pbxn8            0/1     Completed   0          9m1s
multi-completion-batch-job-x6ljh            0/1     Completed   0          6m59s
multi-completion-parallel-batch-job-479ws   1/1     Running     0          3s
multi-completion-parallel-batch-job-4r5jz   0/1     Completed   0          2m7s
multi-completion-parallel-batch-job-tr45b   1/1     Running     0          4s
multi-completion-parallel-batch-job-wfxrn   0/1     Completed   0          2m7s
➜  ~ 


➜  ~ kg jobs
NAME                                  COMPLETIONS   DURATION   AGE
batch-job                             1/1           2m3s       25m
multi-completion-batch-job            5/5           10m        18m
multi-completion-parallel-batch-job   4/5           5m24s      5m24s



➜  ~ kg po
NAME                                        READY   STATUS      RESTARTS   AGE
batch-job-mdbc4                             0/1     Completed   0          25m
multi-completion-batch-job-4s8kc            0/1     Completed   0          18m
multi-completion-batch-job-8g844            0/1     Completed   0          14m
multi-completion-batch-job-9g8f4            0/1     Completed   0          16m
multi-completion-batch-job-pbxn8            0/1     Completed   0          12m
multi-completion-batch-job-x6ljh            0/1     Completed   0          10m
multi-completion-parallel-batch-job-479ws   0/1     Completed   0          3m22s
multi-completion-parallel-batch-job-4r5jz   0/1     Completed   0          5m26s
multi-completion-parallel-batch-job-pvh2b   1/1     Running     0          81s
multi-completion-parallel-batch-job-tr45b   0/1     Completed   0          3m23s
multi-completion-parallel-batch-job-wfxrn   0/1     Completed   0          5m26s



# Set a cron job - to save time can skip to cronjob with deadline

➜  ~ k create -f cronjob.yaml -n default
cronjob.batch/batch-job-every-2-mins created

<!-- 
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: batch-job-every-2-mins
spec:
  schedule: "36,38,40,42 * * * *"
  jobTemplate:
    spec: 
      template:
        metadata:
          labels:
            app: periodic-batch-job
        spec:
          restartPolicy: OnFailure
          containers:
          - name: main
            image: luksa/batch-job
 -->

➜  ~ kg cronjob
NAME                     SCHEDULE              SUSPEND   ACTIVE   LAST SCHEDULE   AGE
batch-job-every-2-mins   36,38,40,42 * * * *   False     0        <none>          70s



➜  ~ kg cronjob
NAME                     SCHEDULE              SUSPEND   ACTIVE   LAST SCHEDULE   AGE
batch-job-every-2-mins   36,38,40,42 * * * *   False     1        15s             50s



➜  ~ kg po     
NAME                                      READY   STATUS    RESTARTS   AGE
batch-job-every-2-mins-1587850680-7s968   1/1     Running   0          9s


➜  ~ kg cronjob
NAME                     SCHEDULE              SUSPEND   ACTIVE   LAST SCHEDULE   AGE
batch-job-every-2-mins   36,38,40,42 * * * *   False     2        9s              2m44s


➜  ~ kg po     
NAME                                      READY   STATUS    RESTARTS   AGE
batch-job-every-2-mins-1587850680-7s968   1/1     Running   0          2m2s
batch-job-every-2-mins-1587850800-r97k8   1/1     Running   0          11s
➜  ~ 


# Cron Job with deadline

➜  yaml_files git:(master) ✗ k create -f cronjob_deadline.yaml -n default
cronjob.batch/batch-job-every-2-mins-deadline created
<!-- 

apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: batch-job-every-2-mins-deadline
spec:
  schedule: "36,38,40,42,44,46,48 * * * *"
  startingDeadlineSeconds: 15
  jobTemplate:
    spec: 
      template:
        metadata:
          labels:
            app: periodic-batch-job
        spec:
          restartPolicy: OnFailure
          containers:
          - name: main
            image: luksa/batch-job
 -->

➜  ~ kg cronjob
NAME                              SCHEDULE                       SUSPEND   ACTIVE   LAST SCHEDULE   AGE
batch-job-every-2-mins            36,38,40,42 * * * *            False     0        6m5s            10m
batch-job-every-2-mins-deadline   36,38,40,42,44,46,48 * * * *   False     2        5s              4m2s



➜  ~ kg po
NAME                                               READY   STATUS      RESTARTS   AGE
batch-job-every-2-mins-deadline-1587851160-57fws   0/1     Completed   0          2m10s
batch-job-every-2-mins-deadline-1587851280-tvl4l   1/1     Running     0          9s


❯ kdel cronjob --all
cronjob.batch "batch-job-every-2-mins-deadline" deleted
~                                                

# Create a Service with YAML

k create -f  kubia-svc.yaml -n default
service/kubia created

<!-- 
apiVersion: v1
kind: Service
metadata:
  name: kubia
spec: 
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: kubia -->

kg svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.100.0.1       <none>        443/TCP   85m
kubia        ClusterIP   10.100.142.125   <none>        80/TCP    103s


 k exec kubia-5xjrb -- curl -s http://10.100.142.125
You've hit kubia-rkht6


# Need PODS to work with - k create -f kubia-replicaset.yaml -n default

kdel po --all
pod "kubia-9s4q7" deleted
pod "kubia-f9xf7" deleted
pod "kubia-jkgr8" deleted



kg po
NAME          READY   STATUS    RESTARTS   AGE
kubia-6sgfs   1/1     Running   0          38s
kubia-lpfbr   1/1     Running   0          38s
kubia-rtgc9   1/1     Running   0          38s



k exec kubia-6sgfs env

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=kubia-6sgfs
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT_443_TCP=tcp://10.100.0.1:443
KUBIA_SERVICE_HOST=10.100.90.188
KUBIA_SERVICE_PORT=80
KUBIA_PORT_80_TCP_PROTO=tcp
KUBERNETES_PORT=tcp://10.100.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
KUBIA_PORT_80_TCP_PORT=80
KUBERNETES_SERVICE_HOST=10.100.0.1
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.100.0.1
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBIA_PORT=tcp://10.100.90.188:80
KUBIA_PORT_80_TCP=tcp://10.100.90.188:80
KUBIA_PORT_80_TCP_ADDR=10.100.90.188


k exec -it kubia-6sgfs bash

root@kubia-6sgfs:/# curl http://kubia.default.svc.cluster.local
You've hit kubia-lpfbr

root@kubia-6sgfs:/# curl http://kubia.default
You've hit kubia-rtgc9

root@kubia-6sgfs:/# curl http://kubia        
You've hit kubia-lpfbr

root@kubia-6sgfs:/# curl http://kubia        
You've hit kubia-lpfbr
root@kubia-6sgfs:/# 
root@kubia-6sgfs:/# 
root@kubia-6sgfs:/# 
root@kubia-6sgfs:/# cat /etc/resolv.conf 
nameserver 10.100.0.10
search default.svc.cluster.local svc.cluster.local cluster.local ec2.internal
options ndots:5


kd svc kubia
Name:              kubia
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=kubia   <====== Pod Selctor
Type:              ClusterIP
IP:                10.100.90.188
Port:              <unset>  80/TCP
TargetPort:        8080/TCP
Endpoints:         192.168.26.253:8080,192.168.37.227:8080,192.168.58.188:8080  <====== Pod endpoints
Session Affinity:  None
Events:            <none>


kg endpoints kubia
NAME    ENDPOINTS                                                     AGE
kubia   192.168.26.253:8080,192.168.37.227:8080,192.168.58.188:8080   8m8s





# Service NodePort 

k create -f  kubia-svc-nodeport.yaml -n default
<!-- 
apiVersion: v1
kind: Service
metadata:
  name: kubia-nodeport
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30123
  selector:
    app: kubia -->

### for GCS ==> gcloud compute firewall-rules create kubia-svc-rule --allow=tcp:30123
### for AWS ==> edit the security group - port-range 30123  0.0.0.0/0

kg svc kubia-nodeport
NAME             TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubia-nodeport   NodePort   10.100.137.248   <none>        80:30123/TCP   3m22s


kg no -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
54.85.96.174 3.234.222.45 18.206.81.24


[jeremy@eks_course kube_yaml_files]$ curl -v -k 54.85.96.174:30123
* About to connect() to 54.85.96.174 port 30123 (#0)
*   Trying 54.85.96.174...
* Connected to 54.85.96.174 (54.85.96.174) port 30123 (#0)
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Host: 54.85.96.174:30123
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Wed, 06 May 2020 20:23:17 GMT
< Connection: keep-alive
< Transfer-Encoding: chunked
< 
You've hit kubia-mkzk8
* Connection #0 to host 54.85.96.174 left intact
[jeremy@eks_course kube_yaml_files]$ curl  3.234.222.45:30123
You've hit kubia-dc47q





# Create LoadBalancer Service

k create -f kubia-svc-loadbalancer.yaml
service/kubia-loadbalancer created

<!-- 
apiVersion: v1
kind: Service
metadata:
  name: kubia-loadbalancer
spec: 
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: kubia -->


kg svc kubia-loadbalancer
NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP                                                               PORT(S)        AGE
kubia-loadbalancer   LoadBalancer   10.100.49.66   a0171468c8fdd11eabf3112b4bd47f1f-1966275983.us-east-1.elb.amazonaws.com   80:30231/TCP   43s


curl a0171468c8fdd11eabf3112b4bd47f1f-1966275983.us-east-1.elb.amazonaws.com
You've hit kubia-mkzk8


curl a0171468c8fdd11eabf3112b4bd47f1f-1966275983.us-east-1.elb.amazonaws.com
You've hit kubia-hw6cl



# Create an INgress resource

k create -f kubia-ingress.yaml -n default
ingress.extensions/kubia created
<!-- 

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kubia
spec:
  rules:
  - host: kubia.example.com
    http:
      paths:
      - path: /
        backend:
          serviceName: kubia-nodeport
          servicePort: 80 -->



kg ingresses
NAME    HOSTS               ADDRESS   PORTS   AGE
kubia   kubia.example.com             80      36s

❯ kg ingresses
NAME    HOSTS               ADDRESS          PORTS   AGE
kubia   kubia.example.com   35.244.178.129   80      112s


kdel po --all


 cat /etc/hosts

localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.122.35          kube-master.jeremycoando.com    m1
192.168.122.32          kube-slave1.jeremycoando.com    s1
192.168.122.5		kube-slave2.jeremycoando.com	s2
10.0.0.110		devops_server.example.com	dev

35.244.178.129 		kubia.example.com
~                                                                                                                                      
❯ curl http://kubia.example.com
You've hit kubia-gpl58
~                                                   


### TLS Traffic  
❯ kdel ingress kubia            
ingress.extensions "kubia" deleted

❯ k create -f kubia-ingress-tls.yaml 
ingress.extensions/kubia created

❯ kdel po --all
pod "kubia-5w88g" deleted
pod "kubia-bx6mx" deleted
pod "kubia-tkqnc" deleted


❯ openssl genrsa -out tls.key 2048
Generating RSA private key, 2048 bit long modulus
........................................................................................................................................+++
................................+++
e is 65537 (0x10001)
~                                                                                                                                      
❯ openssl req -new -x509 -key tls.key -out tls.cert -days 360 -subj /CN=kubia.example.com
~                          


❯ k create secret tls tls-secret --cert=tls.cert --key=tls.key
secret/tls-secret created


❯ kg secrets tls-secret
NAME         TYPE                DATA   AGE
tls-secret   kubernetes.io/tls   2      22s
~                                                                                                                               ○ kubia
❯ kd secrets tls-secret
Name:         tls-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1115 bytes
tls.key:  1675 bytes
~                          

❯ curl -k -v https://kubia.example.com/     
* About to connect() to kubia.example.com port 443 (#0)
*   Trying 35.244.178.129...
* Connected to kubia.example.com (35.244.178.129) port 443 (#0)
* Initializing NSS with certpath: sql:/etc/pki/nssdb
* skipping SSL peer certificate verification
* SSL connection using TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
* Server certificate:
* 	subject: CN=kubia.example.com
* 	start date: May 06 23:42:45 2020 GMT
* 	expire date: May 01 23:42:45 2021 GMT
* 	common name: kubia.example.com
* 	issuer: CN=kubia.example.com
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Host: kubia.example.com
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Wed, 06 May 2020 23:54:18 GMT
< Transfer-Encoding: chunked
< Via: 1.1 google
< Alt-Svc: clear
< 
You've hit kubia-gpl58


# Readiness Probe - Need LB svc kubia-svc-loadbalancer.yaml

k  apply -f kubia-rc-probe.yaml
<!-- 
apiVersion: v1
kind: ReplicationController 
metadata:
  name: kubia-probe
spec:
  replicas: 3
  selector:
    app: kubia 
  template:
    metadata:
      labels: 
        app: kubia 
    spec:
      containers:
        - name: kubia
          image: luksa/kubia
          readinessProbe:
            exec:
              command:
              - ls 
              - /var/ready
          ports:
          - containerPort: 8080 -->


❯ kg po
NAME          READY   STATUS    RESTARTS   AGE
kubia-probe-492tl                                  0/1     Running     0          5s
kubia-probe-4mpgj                                  0/1     Running     0          5s
kubia-probe-np7zb                                  0/1     Running     0          5s

~                                                                                                                               ○ 


❯ k exec kubia-probe-492tl -- touch /var/ready
~                                                                                                                               ○ kubia

                                                                                                   ○ kubia
❯ kg po
NAME          READY   STATUS    RESTARTS   AGE
kubia-probe-492tl                                  1/1     Running     0          118s
kubia-probe-4mpgj                                  0/1     Running     0          118s
kubia-probe-np7zb                                  0/1     Running     0          118s

~                         

~/Documents/Juniper_JUNOS                                                                                                              
❯ curl http://35.223.159.242
You've hit kubia-probe-492tl
~/Documents/Juniper_JUNOS                                                                                                              
❯ curl http://35.223.159.242
You've hit kubia-probe-492tl
~/Documents/Juniper_JUNOS                                                                                                              
❯ 


# Create a Headless Service

k create -f kubia-svc-headless.yaml
<!-- 
apiVersion: v1
kind: Service
metadata:
  name: kubia-headless
spec:
  clusterIP: None
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: kubia 
     -->

❯ k run dnsutils --image=tutum/dnsutils --generator=run-pod/v1 --command -- sleep infinity
pod/dnsutils created


❯ k exec dnsutils nslookup kubia-headless
Server:		10.55.240.10
Address:	10.55.240.10#53

Name:	kubia-headless.default.svc.cluster.local
Address: 10.52.0.14
Name:	kubia-headless.default.svc.cluster.local
Address: 10.52.1.9


# kdel all --all


# PV's and PVC's

❯ k create -f  fortune-pod.yaml -n default
pod/fortune created

<!-- 
apiVersion: v1
kind: Pod
metadata:
  name: fortune
spec:
  containers:
  - image: luksa/fortune
    name: html-generator
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html 
      mountPath: /usr/share/nginx/html
      readOnly: true 
    ports:
    - containerPort: 80
      protocol: TCP
  volumes:
  - name: html
    emptyDir: {} -->


k port-forward fortune 8888:80
Forwarding from 127.0.0.1:8888 -> 80
Forwarding from [::1]:8888 -> 80
Handling connection for 8888


❯ curl -I -v  http://localhost:8888
* About to connect() to localhost port 8888 (#0)
*   Trying ::1...
* Connected to localhost (::1) port 8888 (#0)
> HEAD / HTTP/1.1
> User-Agent: curl/7.29.0
> Host: localhost:8888
> Accept: */*
> 
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
< Server: nginx/1.17.10
Server: nginx/1.17.10
< Date: Tue, 12 May 2020 13:54:25 GMT
Date: Tue, 12 May 2020 13:54:25 GMT
< Content-Type: text/html
Content-Type: text/html
< Content-Length: 94
Content-Length: 94
< Last-Modified: Tue, 12 May 2020 13:54:20 GMT
Last-Modified: Tue, 12 May 2020 13:54:20 GMT
< Connection: keep-alive
Connection: keep-alive
< ETag: "5ebaaa8c-5e"
ETag: "5ebaaa8c-5e"
< Accept-Ranges: bytes
Accept-Ranges: bytes


❯ curl http://localhost:8888 
Excellent day to have a rotten day.


# create a Pod with Git Repo

k create -f gitrepo-volume-pod.yaml -n default
pod/gitrepot-volume-pod created
<!-- 
apiVersion: v1
kind: Pod
metadata:
  name: gitrepot-volume-pod
spec:
  containers:
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true 
    ports:
    - containerPort: 80
      protocol: TCP
  volumes:
  - name: html 
    gitRepo: 
      repository: https://github.com/pseudonative/kubia-website-example.git
      revision: master 
      directory: . -->

k port-forward gitrepot-volume-pod 8888:80
Forwarding from 127.0.0.1:8888 -> 80
Forwarding from [::1]:8888 -> 80
Handling connection for 8888


❯ curl localhost:8888
<html>
<body>
Hello there. This is Jeremy's gitVolume.
This is a second check the first haddt https twice
This is the Third Tiime.
</body>
</html>
~                                                                                                                                      
❯ 

Also Try it in a web browser


# Examining System Pods

❯ kg po -n kube-system | grep -Ei fluentd
fluentd-gcp-scaler-bfd6cf8dd-r4ztj                         1/1     Running   0          16h
fluentd-gcp-v3.1.1-27q5s                                   2/2     Running   0          16h
fluentd-gcp-v3.1.1-kr7q6                                   2/2     Running   0          16h
fluentd-gcp-v3.1.1-mqnt2                                   2/2     Running   0          16h


❯ kd po fluentd-gcp-v3.1.1-kr7q6 -n kube-system  

Volumes:
  varrun:
    Type:          HostPath (bare host directory volume)
    Path:          /var/run/google-fluentd
    HostPathType:  
  varlog:
    Type:          HostPath (bare host directory volume)
    Path:          /var/log
    HostPathType:  
  varlibdockercontainers:
    Type:          HostPath (bare host directory volume)
    Path:          /var/lib/docker/containers
    HostPathType:  
  config-volume:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      fluentd-gcp-config-v1.2.6
    Optional:  false
  fluentd-gcp-token-cx4jz:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  fluentd-gcp-token-cx4jz
    Optional:    false



# Using GCE Persistent Disk pod Volume

❯ gcloud container clusters list
NAME     LOCATION       MASTER_VERSION  MASTER_IP     MACHINE_TYPE   NODE_VERSION    NUM_NODES  STATUS
jaykube  us-central1-a  1.14.10-gke.27  34.69.76.133  n1-standard-1  1.14.10-gke.27  3          RUNNING
~                                                                                                            


❯ gcloud compute disks create --size=1Gib --zone=us-central1-a mongodb

NAME     ZONE           SIZE_GB  TYPE         STATUS
mongodb  us-central1-a  1        pd-standard  READY

New disks are unformatted. You must format and mount a disk before it
can be used. You can find instructions on how to do this at:

https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting

~                                                                                                                3s G kubernetes-222302
❯ gcloud compute disks list
NAME                                    LOCATION       LOCATION_SCOPE  SIZE_GB  TYPE         STATUS
gke-jaykube-default-pool-6124d961-6lcw  us-central1-a  zone            100      pd-standard  READY
gke-jaykube-default-pool-6124d961-8jt9  us-central1-a  zone            100      pd-standard  READY
gke-jaykube-default-pool-6124d961-v28l  us-central1-a  zone            100      pd-standard  READY
mongodb                                 us-central1-a  zone            1        pd-standard  READY
~             


k create -f  mongodb-pod-gecpd.yaml -n default
pod/mongodb created
<!-- 
apiVersion: v1
kind: Pod
metadata:
  name: mongodb 
spec:
  volumes:
  - name: mongodb-data
    gcePersistentDisk:
      pdName: mongodb
      fsType: ext4 
  containers:
  - image: mongo 
    name: mongodb
    volumeMounts:
    - name: mongodb-data 
      mountPath: /data/db 
    ports:
    - containerPort: 27017
      protocol: TCP
       -->

k exec -it mongodb mongo
---

> use mystore
switched to db mystore
> db.foo.insert({name:'MuthaFucka'})
WriteResult({ "nInserted" : 1 })
> db.foo.find()
{ "_id" : ObjectId("5ebab197b580b2b9869acc7f"), "name" : "MuthaFucka" }
> 


❯ kdel po mongodb
pod "mongodb" deleted
~                     


k create -f  mongodb-pod-gecpd.yaml -n default

❯ k exec -it mongodb mongo
MongoDB shell version v4.2.6

---

> use mystore
switched to db mystore
> db.foo.find()
{ "_id" : ObjectId("5ebab197b580b2b9869acc7f"), "name" : "MuthaFucka" }
> 
bye
~                          


# Create a pv - Persistent Volume

k create -f  mongodb-pv-gcepd.yaml -n default
persistentvolume/mongodb-pv created

<!-- 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodb-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  - ReadOnlyMany
  persistentVolumeReclaimPolicy: Retain 
  gcePersistentDisk:
    pdName: mongodb
    fsType: ext4
     -->

kg pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
mongodb-pv   1Gi        RWO,ROX        Retain           Available                                   28s
~                                    

# Create the pvc - Persistent Volume Claim

k create -f  mongodb-pvc.yaml
persistentvolumeclaim/mongodb-pvc created
<!-- 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-pvc 
spec:
  resources:
    requests:
      storage: 1Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: ""


   -->
kg pvc
NAME          STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mongodb-pvc   Bound    mongodb-pv   1Gi        RWO,ROX                       39s
~                     

kg pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
mongodb-pv   1Gi        RWO,ROX        Retain           Bound    default/mongodb-pvc                           4m59s
~                                              


# Use a Persistent Volume Claim in a Pod

kdel po mongodb

k create -f  mongodb-pod-pvc.yaml -n default
pod/mongodb created

<!-- 
apiVersion: v1
kind: Pod
metadata:
  name: mongodb
spec:
  containers:
  - image: mongo
    name: mongodb
    volumeMounts:
    - name: mongodb-data 
      mountPath: /data/db 
    ports:
    - containerPort: 27017
      protocol: TCP
  volumes:
  - name: mongodb-data
    persistentVolumeClaim:
      claimName: mongodb-pvc -->


k exec -it mongodb mongo
MongoDB shell version v4.2.6

---

> use mystore
switched to db mystore
> db.foo.find()
{ "_id" : ObjectId("5ebab197b580b2b9869acc7f"), "name" : "MuthaFucka" }
> 
bye
~                                  


# Recycle Persistent Volumes

❯ kdel po mongodb
pod "mongodb" deleted
~                                                                                                                          4s ○ jaykube
❯ kdel pvc mongodb-pvc
persistentvolumeclaim "mongodb-pvc" deleted
~                 


k create -f  mongodb-pod-pvc.yaml -n default
pod/mongodb created


❯ k create -f  mongodb-pvc.yaml
persistentvolumeclaim/mongodb-pvc created
                                                                                          ○ jaykube
❯ k create -f  mongodb-pod-pvc.yaml -n default
pod/mongodb created
                                                                                               
❯ 


❯ kg pvc
NAME          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mongodb-pvc   Pending                                                     42s
~                                                                                                                             ○ jaykube
❯ kg pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                 STORAGECLASS   REASON   AGE
mongodb-pv   1Gi        RWO,ROX        Retain           Released   default/mongodb-pvc                           14m
~                   


❯ kdel po mongodb
pod "mongodb" deleted
~                                                                                                                             ○ jaykube
❯ kdel pvc --all
persistentvolumeclaim "mongodb-pvc" deleted
~                                                                                                                             ○ jaykube
❯ kdel pv --all
persistentvolume "mongodb-pv" deleted
~                                                                                                                                      
❯ 


❯ k create -f  mongodb-pv-gcepd.yaml -n default
persistentvolume/mongodb-pv created
                                                               ○ jaykube
❯ k create -f  mongodb-pvc.yaml                
persistentvolumeclaim/mongodb-pvc created
                                                                              ○ jaykube
❯ k create -f  mongodb-pod-pvc.yaml -n default 
pod/mongodb created
                                                                  
❯ 


❯ kg pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
mongodb-pv   1Gi        RWO,ROX        Retain           Bound    default/mongodb-pvc                           52s
~                                                                                                                             ○ jaykube
❯ kg pvc
NAME          STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mongodb-pvc   Bound    mongodb-pv   1Gi        RWO,ROX                       45s
~                                                                                                                                      
❯ 

k exec -it mongodb mongo
---

> use mystore
switched to db mystore
> db.foo.find()
{ "_id" : ObjectId("5ebab197b580b2b9869acc7f"), "name" : "MuthaFucka" }
> 
> 
bye
~                          


# Define a storage class

kdel po mongodb

❯ kdel pv --all
persistentvolume "mongodb-pv" deleted

❯ kdel pvc --all
persistentvolumeclaim "mongodb-pvc" deleted

                                                                                       ○ jaykube
❯ kg pvc
NAME          STATUS        VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mongodb-pvc   Terminating   mongodb-pv   1Gi        RWO,ROX                       37m
                                                                                                    
❯ 

k create -f storageclass-fast-gcepd.yaml -n default
storageclass.storage.k8s.io/fast created
<!-- 

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  zone: us-central1-a
 -->


❯ kg storageclass fast
NAME   PROVISIONER            AGE
fast   kubernetes.io/gce-pd   46s
~                           


k create -f  mongodb-pvc-dp.yaml -n default
persistentvolumeclaim/mongodb-pvc created
<!-- 

apiVersion: v1
kind: PersistentVolumeClaim
metadata: 
  name: mongodb-pvc 
spec:
  storageClassName: fast 
  resources:
    requests:
      storage: 100Mi 
  accessModes:
    - ReadWriteOnce
 -->

    ❯ kg pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
pvc-31c34e07-9466-11ea-be15-42010a80010e   1Gi        RWO            Delete           Bound    default/mongodb-pvc   fast                    31s
~                                                                                                                             ○ jaykube


❯ kg pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mongodb-pvc   Bound    pvc-31c34e07-9466-11ea-be15-42010a80010e   1Gi        RWO            fast           35s
~             


 gcloud compute disks list | grep -Ei pd-ssd
gke-jaykube-9c1a0a79-d-pvc-31c34e07-9466-11ea-be15-42010a80010e  us-central1-a  zone            1        pd-ssd       READY
~       



❯ kg sc
NAME                 PROVISIONER            AGE
fast                 kubernetes.io/gce-pd   7m51s
standard (default)   kubernetes.io/gce-pd   17h
~    


# Create Persistent Volume withou specifying storage class

❯ kg sc standard -oyaml
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  creationTimestamp: "2020-05-11T21:50:33Z"
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
    kubernetes.io/cluster-service: "true"
  name: standard
  resourceVersion: "304"
  selfLink: /apis/storage.k8s.io/v1/storageclasses/standard
  uid: 705c43ff-93d1-11ea-be15-42010a80010e
parameters:
  type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Delete
volumeBindingMode: Immediate
~                      


k create -f  mongodb-pvc-dp-nostorageclass.yaml -n default
persistentvolumeclaim/mongodb-pvc2 created


<!-- apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-pvc2 
spec: 
  resources:
    requests:
      storage: 10Mi
  accessModes:
  - ReadWriteOnce 
  -->
  
❯ kg pvc mongodb-pvc2
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mongodb-pvc2   Bound    pvc-3479b215-9467-11ea-be15-42010a80010e   1Gi        RWO            standard       6m26s
~                                                                                                                             ○ jaykube


❯ kg pv pvc-3479b215-9467-11ea-be15-42010a80010e
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
pvc-3479b215-9467-11ea-be15-42010a80010e   1Gi        RWO            Delete           Bound    default/mongodb-pvc2   standard                6m34s
~                                                                                                                   G kubernetes-222302


❯ gcloud compute disks list
NAME                                                             LOCATION       LOCATION_SCOPE  SIZE_GB  TYPE         STATUS
gke-jaykube-9c1a0a79-d-pvc-31c34e07-9466-11ea-be15-42010a80010e  us-central1-a  zone            1        pd-ssd       READY
gke-jaykube-9c1a0a79-d-pvc-3479b215-9467-11ea-be15-42010a80010e  us-central1-a  zone            1        pd-standard  READY

kdel po mongodb

k create -f mongodb-pod-pvc-nostorageclass.yaml
pod/mongodb created

<!-- 
apiVersion: v1
kind: Pod
metadata:
  name: mongodb
spec:
  containers:
  - image: mongo
    name: mongodb
    volumeMounts:
    - name: mongodb-data 
      mountPath: /data/db 
    ports:
    - containerPort: 27017
      protocol: TCP
  volumes:
  - name: mongodb-data
    persistentVolumeClaim:
      claimName: mongodb-pvc2

       -->

kd po mongodb
Name:         mongodb
Namespace:    default
Priority:     0
Node:         gke-jaykube-default-pool-6124d961-8jt9/10.128.0.28
Start Time:   Tue, 12 May 2020 10:00:17 -0600
L.......
Events:
  Type    Reason                  Age   From                                             Message
  ----    ------                  ----  ----                                             -------
  Normal  Scheduled               23s   default-scheduler                                Successfully assigned default/mongodb to gke-jaykube-default-pool-6124d961-8jt9
  Normal  SuccessfulAttachVolume  15s   attachdetach-controller                          AttachVolume.Attach succeeded for volume "pvc-3479b215-9467-11ea-be15-42010a80010e"
  Normal  Pulling                 5s    kubelet, gke-jaykube-default-pool-6124d961-8jt9  Pulling image "mongo"
  Normal  Pulled                  5s    kubelet, gke-jaykube-default-pool-6124d961-8jt9  Successfully pulled image "mongo"
  Normal  Created                 4s    kubelet, gke-jaykube-default-pool-6124d961-8jt9  Created container mongodb
  Normal  Started                 4s    kubelet, gke-jaykube-default-pool-6124d961-8jt9  Started container mongodb
~                                       



###### Config Maps And Secrets
































