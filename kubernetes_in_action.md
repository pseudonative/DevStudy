# ADHOC Commands:

kubectl run nginx-pod --image=nginx:alpine

kubectl run redis --image=redis:alpine --labels=tier=db

kubectl get pods --show-labels

kubectl expose pod redis --name redis-service --port 6379 --target-port 6379

kubectl create deployment webapp --image=kodekloud/webapp-color

kubectl scale deployment --replicas=3 webapp

kubectl run custom-nginx --image=nginx --port 8080

kubectl create ns dev-ns

kubectl create deployment redis-deploy --image=redis --namespace=dev-ns --dry-run=true -oyaml > deploy.yaml

code deploy.yaml

add replicas: 2

kubectl apply -f deploy.yaml

kubectl run httpd --image=httpd:alpine --port 80 --expose --dry-run=client -oyaml

kdel all --all

# This document is to be done everyday for repetition study

# Try to throw the cluster up the night before - saves time

# maybe even run 2 or 3 clusters, to practice moving between clusters

# aliases

k=kubectl
kd='kubectl describe'
kdel='kubectl delete'
kg='kubectl get'
ktx='k config get-contexts'
kuse='k config use-context'

# To resize Cluster

❯ gcloud container node-pools list --cluster kubia
NAME MACHINE_TYPE DISK_SIZE_GB NODE_VERSION
default-pool n1-standard-1 100 1.14.10-gke.36
~ G kubernetes-222302
❯ gcloud container clusters resize kubia --node-pool default-pool --num-nodes 4
Pool [default-pool] for [kubia] will be resized to 4.

Do you want to continue (Y/n)? y

# moving between clusters

kubectl config get-clusters

kubectl config use-cluster <cluster name>

# GCS Cluster

gcloud container clusters create <name> --machine-type=MACHINE_TYPE # n1-standard-1

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

gcloud container clusters list

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

k create -f replicationController.yaml -n default

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

watch kubectl get po

# check the pod

kg po
kg po -owide
kg po <name> -owide

➜ kubernetes_in_action git:(master) ✗ kg po -owide
NAME READY STATUS RESTARTS AGE IP NODE NOMINATED NODE READINESS GATES
kubia-8xvqb 1/1 Running 0 3m5s 10.4.1.19 gke-chaos-default-pool-57deedda-0q0n <none> <none>
kubia-p9982 1/1 Running 0 7m14s 10.4.1.18 gke-chaos-default-pool-57deedda-0q0n <none> <none>
kubia-vqdk4 1/1 Running 0 3m5s 10.4.2.5 gke-chaos-default-pool-57deedda-0gdt <none> <none>

kg po -oyaml
kd po
kd po | more
kd po | grep -Ei Node: | awk '{print $1 " " $2}'
Node: gke-chaos-default-pool-57deedda-0q0n/10.128.15.220

kd po | grep -Ei ready | awk '{print $1 " " $2}'
Ready: True
Ready True
ContainersReady True
Tolerations: node.kubernetes.io/not-ready:NoExecute

➜ kubernetes_in_action git:(master) ✗ kg rc
NAME DESIRED CURRENT READY AGE
kubia 1 1 1 12m

kd rc
Name: kubia
Namespace: default
Selector: run=kubia
Labels: run=kubia
Annotations: <none>
Replicas: 1 current / 1 desired
Pods Status: 1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
Labels: run=kubia
Containers:
kubia:
Image: luksa/kubia
Port: 1100/TCP
Host Port: 0/TCP
Environment: <none>
Mounts: <none>
Volumes: <none>
Events:
Type Reason Age From Message

---

Normal SuccessfulCreate 12m replication-controller Created pod: kubia-4lvdh

kd rc | grep -Ei Normal | awk '{print $1 " " $2}'
Normal SuccessfulCreate

# expose the replication controller

k expose rc kubia --type=LoadBalancer --name kubia-http

➜ kubernetes_in_action git:(master) ✗ kg svc
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
kubernetes ClusterIP 10.7.240.1 <none> 443/TCP 46h
kubia-http LoadBalancer 10.7.241.152 <pending> 1100:31157/TCP 12s

➜ kubernetes_in_action git:(master) ✗ kg svc  
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
kubernetes ClusterIP 10.7.240.1 <none> 443/TCP 46h
kubia-http LoadBalancer 10.7.241.152 34.68.141.247 1100:31157/TCP 49s # External IP and Port

# Check the Load Balancer service

ping 34.68.141.247
PING 34.68.141.247 (34.68.141.247) 56(84) bytes of data.
64 bytes from 34.68.141.247: icmp_seq=27 ttl=42 time=35.0 ms
64 bytes from 34.68.141.247: icmp_seq=28 ttl=42 time=33.7 ms
64 bytes from 34.68.141.247: icmp_seq=29 ttl=42 time=38.5 ms
^C
--- 34.68.141.247 ping statistics ---
29 packets transmitted, 3 received, 89% packet loss, time 28003ms
rtt min/avg/max/mdev = 33.745/35.771/38.555/2.046 ms

curl 34.68.141.247:8080
You've hit kubia-p9982

# Scale the Replication Controller

kg rc
NAME DESIRED CURRENT READY AGE
kubia 1 1 1 3m37s

k scale rc kubia --replicas=3
replicationcontroller/kubia scaled

kg rc
NAME DESIRED CURRENT READY AGE
kubia 3 3 2 4m18s

kg rc
NAME DESIRED CURRENT READY AGE
kubia 3 3 2 4m23s

kg po
NAME READY STATUS RESTARTS AGE
kubia-8xvqb 1/1 Running 0 22s
kubia-p9982 1/1 Running 0 4m31s
kubia-vqdk4 0/1 ContainerCreating 0 22s

kd rc  
Name: kubia
Namespace: default
Selector: run=kubia
Labels: run=kubia
Annotations: <none>
Replicas: 3 current / 3 desired
Pods Status: 3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
Labels: run=kubia
Containers:
kubia:
Image: luksa/kubia
Port: 8080/TCP
Host Port: 0/TCP
Environment: <none>
Mounts: <none>
Volumes: <none>
Events:
Type Reason Age From Message

---

Normal SuccessfulCreate 4m43s replication-controller Created pod: kubia-p9982
Normal SuccessfulCreate 34s replication-controller Created pod: kubia-vqdk4
Normal SuccessfulCreate 34s replication-controller Created pod: kubia-8xvqb

# check the loadbalancer service now

curl 34.68.141.247:8080
You've hit kubia-vqdk4
curl 34.68.141.247:8080
You've hit kubia-p9982
curl 34.68.141.247:8080
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

k logs <pod id> -c <container> # if multiple containers in pod

# forward local machines port to the pod

k port-forward <pod> 1111:8080

k port-forward kubia-manual 1111:8080
Forwarding from 127.0.0.1:1111 -> 8080
Forwarding from [::1]:1111 -> 8080
Handling connection for 1111

curl localhost:1111

➜ kubernetes_in_action curl localhost:1111
You've hit kubia-manual

# Create POD with Labels

k create -f kubia-manual-with-labels.yaml -n default
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

kg po
NAME READY STATUS RESTARTS AGE
kubia-manual 1/1 Running 0 42m
kubia-manual-v2 1/1 Running 0 3s

kg po --show-labels
NAME READY STATUS RESTARTS AGE LABELS
kubia-manual 1/1 Running 0 42m <none>
kubia-manual-v2 1/1 Running 0 23s creation_method=manual,env=prod

k get po -L creation_method,env
NAME READY STATUS RESTARTS AGE CREATION_METHOD ENV
kubia-manual 1/1 Running 0 44m  
kubia-manual-v2 1/1 Running 0 2m8s manual prod
kubia-sw7cq 1/1 Running 0 28s

k label po kubia-manual creation_method=manual
pod/kubia-manual labeled

k label po kubia-manual-v2 env=debug --overwrite
pod/kubia-manual-v2 labeled

kg po -L creation_method,env
NAME READY STATUS RESTARTS AGE CREATION_METHOD ENV
kubia-manual 1/1 Running 0 51m manual  
kubia-manual-v2 1/1 Running 0 9m31s manual debug
kubia-sw7cq 1/1 Running 0 7m51s

kg po -l creation_method=manual
NAME READY STATUS RESTARTS AGE
kubia-manual 1/1 Running 0 56m
kubia-manual-v2 1/1 Running 0 14m

kg po -l env
NAME READY STATUS RESTARTS AGE
kubia-manual-v2 1/1 Running 0 14m

kg po -l '!env'  
NAME READY STATUS RESTARTS AGE
kubia-manual 1/1 Running 0 57m
kubia-sw7cq 1/1 Running 0 14m

# Label a Node

❯ kg no  
NAME STATUS ROLES AGE VERSION
gke-kubia-default-pool-75d2dcc5-32vf Ready <none> 37m v1.14.10-gke.27
gke-kubia-default-pool-75d2dcc5-kq4k Ready <none> 37m v1.14.10-gke.27
gke-kubia-default-pool-75d2dcc5-n7nd Ready <none> 37m v1.14.10-gke.27
~/kubernetes_in_action/yaml_files ○ kubia

❯ k label node gke-kubia-default-pool-75d2dcc5-kq4k gpu=true
node/gke-kubia-default-pool-75d2dcc5-kq4k labeled
~/kubernetes_in_action/yaml_files ○ kubia

❯ kg no -l gpu=true
NAME STATUS ROLES AGE VERSION
gke-kubia-default-pool-75d2dcc5-kq4k Ready <none> 38m v1.14.10-gke.27
~/kubernetes_in_action/yaml_files ○ kubia

k create -f kubia-gpu.yaml -n default
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
NAME READY STATUS RESTARTS AGE
kubia-2mjcz 1/1 Running 0 22m
kubia-gpu 1/1 Running 0 3s
.......

k annotate po kubia-manual mycompany.com/someannotation="BadAss Shoshone"
pod/kubia-manual annotated

kd po kubia-manual

Annotations: kubernetes.io/limit-ranger: LimitRanger plugin set: cpu request for container kubia
mycompany.com/someannotation: BadAss Shoshone

kg ns
NAME STATUS AGE
default Active 2d1h
kube-node-lease Active 2d1h
kube-public Active 2d1h
kube-system Active 2d1h

kg po -n kube-system
NAME READY STATUS RESTARTS AGE
event-exporter-v0.2.5-7df89f4b8f-hb9wr 2/2 Running 0 2d1h
fluentd-gcp-scaler-54ccb89d5-t5v48 1/1 Running 0 2d1h
fluentd-gcp-v3.1.1-8x84b 2/2 Running 0 2d1h
fluentd-gcp-v3.1.1-h6fww 2/2 Running 0 2d1h
fluentd-gcp-v3.1.1-k972r 2/2 Running 0 2d1h
heapster-gke-798d7cd8fc-p4wgc 3/3 Running 0 2d1h
kube-dns-5877696fb4-ccctd 4/4 Running 0 2d1h
kube-dns-5877696fb4-lmxf4 4/4 Running 0 2d1h
kube-dns-autoscaler-8687c64fc-42vvj 1/1 Running 0 2d1h
kube-proxy-gke-chaos-default-pool-57deedda-0gdt 1/1 Running 0 2d1h
kube-proxy-gke-chaos-default-pool-57deedda-0q0n 1/1 Running 0 2d1h
kube-proxy-gke-chaos-default-pool-57deedda-qbws 1/1 Running 0 2d1h
l7-default-backend-8f479dd9-tg87f 1/1 Running 0 2d1h
metrics-server-v0.3.1-5c6fbf777-gn4j8 2/2 Running 0 2d1h
prometheus-to-sd-7j25b 2/2 Running 0 2d1h
prometheus-to-sd-bzgzh 2/2 Running 0 2d1h
prometheus-to-sd-wtlxv 2/2 Running 0 2d1h
stackdriver-metadata-agent-cluster-level-744c9bbf67-d25wg 2/2 Running 0 2d1h

# create a custom namespace via YAML

k create -f custome-namespace.yaml
namespace/custom-namespace created

<!--
apiVersion: v1
kind: Namespace
metadata:
  name: custom-namespace%
-->

kg ns
NAME STATUS AGE
custom-namespace Active 3s
default Active 2d1h
kube-node-lease Active 2d1h
kube-public Active 2d1h
kube-system Active 2d1h

k create -f kubia-manual.yaml -n custom-namespace
pod/kubia-manual created

kg po -n custom-namespace
NAME READY STATUS RESTARTS AGE
kubia-manual 1/1 Running 0 11s

# Deleting Pods and namespaces

kdel po kubia-gpu
pod "kubia-gpu" deleted

# delete pods with label selectors

kdel po -l creation_method=manual
pod "kubia-manual" deleted
pod "kubia-manual-v2" deleted

delete pods by deleting the whole namespace

kdel ns custom-namespace
namespace "custom-namespace" deleted

kg po
NAME READY STATUS RESTARTS AGE
kubia-sw7cq 1/1 Running 0 90m

kdel po --all
pod "kubia-sw7cq" deleted

➜ kubernetes_in_action kg po
NAME READY STATUS RESTARTS AGE
kubia-k492d 1/1 Running 0 12s
kubia-sw7cq 1/1 Terminating 0 91m

kg po
NAME READY STATUS RESTARTS AGE
kubia-k492d 1/1 Running 0 40s

kdel all --all
pod "kubia-k492d" deleted
replicationcontroller "kubia" deleted
service "kubernetes" deleted

kg po
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

kg po
NAME READY STATUS RESTARTS AGE
kubia-liveness 1/1 Running 0 89s

kd po
Warning Unhealthy 1s (x2 over 11s) kubelet, gke-jaykube-default-pool-5886fede-bqds Liveness probe failed: HTTP probe failed with statuscode: 500

kg po
NAME READY STATUS RESTARTS AGE
kubia-liveness 1/1 Running 1 2m35s <===== RESTARTS

k logs kubia-liveness --previous
Kubia server starting...
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1
Received request from ::ffff:10.48.2.1

kd po kubia-liveness | grep -Ei "last state" | awk '{print $1 " " $2 " " $3 " " $4}'  
Last State: Terminated  
kd po kubia-liveness | grep -Ei reason: | awk '{print $1 " " $2 }'  
Reason: Error

kdel po --all

k create -f kubia-liveness-probe-initial-delay.yaml -n default

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

kg po
NAME READY STATUS RESTARTS AGE
kubia-liveness 0/1 CrashLoopBackOff 6 13m

# Delete the POD and recreate with the delay

✗ k create -f kubia-liveness-probe-initial-delay.yaml -n default

✗ kg po
NAME READY STATUS RESTARTS AGE
kubia-liveness 1/1 Running 0 10s

kd po | grep -Ei liveness
Name: kubia-liveness
Liveness: http-get http://:8080/ delay=15s timeout=1s period=10s #success=1 #failure=3
Normal Scheduled 2m default-scheduler Successfully assigned default/kubia-liveness to gke-jaykube-default-pool-5886fede-bqds
Warning Unhealthy 29s (x3 over 49s) kubelet, gke-jaykube-default-pool-5886fede-bqds Liveness probe failed: HTTP probe failed with statuscode: 500
Normal Killing 29s kubelet, gke-jaykube-default-pool-5886fede-bqds Container kubia failed liveness probe, will be restarted

# Create Replica Controller

k create -f kubia-rc.yaml -n default

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

kg rc
NAME DESIRED CURRENT READY AGE
kubia 3 3 3 59s

kg po
NAME READY STATUS RESTARTS AGE
kubia-24j2q 1/1 Running 0 4s
kubia-dcq2c 1/1 Running 0 4s
kubia-liveness 1/1 Running 3 6m37s
kubia-wbqxk 1/1 Running 0 4s

kdel po kubia-24j2q kubia-wbqxk
pod "kubia-24j2q" deleted
pod "kubia-wbqxk" deleted

➜ DevStudy git:(master) ✗ kg po
NAME READY STATUS RESTARTS AGE
kubia-24j2q 1/1 Terminating 0 115s
kubia-dcq2c 1/1 Running 0 115s
kubia-jhqw5 1/1 Running 0 2s
kubia-lhfmf 0/1 ContainerCreating 0 2s
kubia-liveness 1/1 Running 4 8m28s
kubia-wbqxk 1/1 Terminating 0 115s

DevStudy git:(master) ✗ kg po
NAME READY STATUS RESTARTS AGE
kubia-dcq2c 1/1 Running 0 3m8s
kubia-jhqw5 1/1 Running 0 75s
kubia-lhfmf 1/1 Running 0 75s
kubia-liveness 1/1 Running 4 9m41s

# Introduce some Chaos - take down a node

gcloud compute ssh gke-jaykube-default-pool-5886fede-bqds

jeremy@gke-jaykube-default-pool-5886fede-bqds ~ $ sudo ifconfig eth0 down

➜ DevStudy git:(master) ✗ kg no
NAME STATUS ROLES AGE VERSION
gke-jaykube-default-pool-5886fede-bqds NotReady <none> 72m v1.14.10-gke.27

➜ DevStudy git:(master) ✗ kg no
NAME STATUS ROLES AGE VERSION
gke-jaykube-default-pool-5886fede-bqds Ready <none> 82m v1.14.10-gke.27
gke-jaykube-default-pool-5886fede-ggs1 Ready <none> 82m v1.14.10-gke.27
gke-jaykube-default-pool-5886fede-s8nn NotReady <none> 82m v1.14.10-gke.27

DevStudy git:(master) ✗ kg po
NAME READY STATUS RESTARTS AGE
kubia-bpv67 0/1 ContainerCreating 0 2s
kubia-dcq2c 1/1 Running 2 22m
kubia-jhqw5 1/1 Running 2 20m
kubia-lhfmf 1/1 Unknown 0 20m
kubia-liveness 1/1 Running 11 28m

# gcloud compute instances reset gke-jaykube-default-pool-5886fede-s8nn

➜ DevStudy git:(master) ✗ kg no
NAME STATUS ROLES AGE VERSION
gke-jaykube-default-pool-5886fede-bqds Ready <none> 89m v1.14.10-gke.27
gke-jaykube-default-pool-5886fede-ggs1 Ready <none> 89m v1.14.10-gke.27
gke-jaykube-default-pool-5886fede-s8nn Ready <none> 89m v1.14.10-gke.27

# Add labels to PODs managed by Replication Controller

➜ ~ k label po kubia-dcq2c type=special
pod/kubia-dcq2c labeled

➜ ~ kg po --show-labels
NAME READY STATUS RESTARTS AGE LABELS
kubia-bpv67 1/1 Running 0 6m28s app=kubia
kubia-dcq2c 1/1 Running 2 28m app=kubia,type=special
kubia-jhqw5 1/1 Running 2 26m app=kubia
kubia-liveness 1/1 Running 13 35m <none>

➜ ~ k label po kubia-dcq2c app=foo --overwrite
pod/kubia-dcq2c labeled

➜ ~ kg po -L app
NAME READY STATUS RESTARTS AGE APP
kubia-bpv67 1/1 Running 0 7m43s kubia
kubia-dcq2c 1/1 Running 2 30m foo
kubia-jhqw5 1/1 Running 2 28m kubia
kubia-liveness 1/1 Running 13 36m  
kubia-s4jtm 1/1 Running 0 10s kubia
➜ ~

# Horizontially scale the Replica Set

➜ ~ k scale rc kubia --replicas=10
replicationcontroller/kubia scaled
➜ ~ kg rc
NAME DESIRED CURRENT READY AGE
kubia 10 10 6 33m

➜ ~ k edit rc kubia # can also scale - k scale rc kubia --replicas=3

spec:
replicas: 3

➜ ~ kg rc
NAME DESIRED CURRENT READY AGE
kubia 3 3 3 35m
➜ ~ kg po
NAME READY STATUS RESTARTS AGE
kubia-bpv67 1/1 Running 0 13m
kubia-dcq2c 1/1 Running 2 35m
kubia-gvfwb 1/1 Terminating 0 119s
kubia-jhqw5 1/1 Running 2 33m
kubia-liveness 1/1 Running 14 42m
kubia-qg62l 1/1 Terminating 0 119s
kubia-s4jtm 1/1 Running 0 5m46s
kubia-sbmzk 1/1 Terminating 0 119s
kubia-tfjnt 1/1 Terminating 0 119s
kubia-tq7dd 1/1 Terminating 0 119s
kubia-v65ks 1/1 Terminating 0 119s
kubia-zznqt 1/1 Terminating 0 119s

➜ ~ kdel rc kubia --cascade=false
replicationcontroller "kubia" deleted
➜ ~ kg rc
No resources found in default namespace.
➜ ~ kg po
NAME READY STATUS RESTARTS AGE
kubia-bpv67 1/1 Running 0 16m
kubia-dcq2c 1/1 Running 2 38m
kubia-jhqw5 1/1 Running 2 37m
kubia-s4jtm 1/1 Running 0 9m5s

# Create Replica Set to adopt orphaned PODs

➜ ~ k create -f kubia-replicaset.yaml -n default
replicaset.apps/kubia created

<!--
apiVersion: apps/v1
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

➜ ~ kg rs
NAME DESIRED CURRENT READY AGE
kubia 3 3 3 41s

➜ ~ kd rs
Name: kubia
Namespace: default
Selector: app=kubia
Labels: <none>
Annotations: <none>
Replicas: 3 current / 3 desired
Pods Status: 3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
Labels: app=kubia

# Add expressive Label Selectors to Replica Set

➜ ~ kdel rs kubia
replicaset.extensions "kubia" deleted

➜ ~ k create -f kubia-replicaset-matchexpressions.yaml -n default
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

➜ ~ kg po
NAME READY STATUS RESTARTS AGE
kubia-dcq2c 1/1 Running 2 49m
kubia-gctjt 1/1 Running 0 91s
kubia-w4zmx 1/1 Running 0 91s
kubia-wxdqh 1/1 Running 0 91s

➜ ~ kg po --show-labels
NAME READY STATUS RESTARTS AGE LABELS
kubia-dcq2c 1/1 Running 2 49m app=foo,type=special
kubia-gctjt 1/1 Running 0 99s app=kubia
kubia-w4zmx 1/1 Running 0 99s app=kubia
kubia-wxdqh 1/1 Running 0 99s app=kubia
➜ ~

➜ ~ kdel rs --all
replicaset.extensions "kubia" deleted

# create Node Selector with Daemon set

➜ ~ k create -f ssd-monitor-daemonset.yaml -n default
daemonset.apps/ssd-monitor created

<!--
apiVersion: apps/v1
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

➜ ~ kg ds
NAME DESIRED CURRENT READY UP-TO-DATE AVAILABLE NODE SELECTOR AGE
ssd-monitor 0 0 0 0 0 disk=ssd 112s

➜ ~ kg po
No resources found in default namespace.
➜ ~

k label node <node> disk=ssd # make a script to automate

➜ ~ k label node gke-jaykube-default-pool-5886fede-bqds disk=ssd
node/gke-jaykube-default-pool-5886fede-bqds labeled

k label node gke-kubia-default-pool-13476f38-fvjr gke-kubia-default-pool-13476f38-kl8v disk=ssd
node/gke-kubia-default-pool-13476f38-fvjr labeled
node/gke-kubia-default-pool-13476f38-kl8v labeled

➜ ~ kg po
NAME READY STATUS RESTARTS AGE
ssd-monitor-khgwh 1/1 Running 0 4s
➜ ~

# remove the label from the node

~ k label node gke-jaykube-default-pool-5886fede-bqds disk=hdd --overwrite
node/gke-jaykube-default-pool-5886fede-bqds labeled
➜ ~
➜ ~
➜ ~
➜ ~ kg po
NAME READY STATUS RESTARTS AGE
ssd-monitor-khgwh 1/1 Terminating 0 109s
➜ ~

➜ ~ kg ds
NAME DESIRED CURRENT READY UP-TO-DATE AVAILABLE NODE SELECTOR AGE
ssd-monitor 0 0 0 0 0 disk=ssd 6m39s
➜ ~
➜ ~
➜ ~ kdel ds ssd-monitor
daemonset.extensions "ssd-monitor" deleted
➜ ~ kg po
No resources found in default namespace.
➜ ~

# Define a Job Resource

➜ ~ k create -f exporter.yaml -n default
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

➜ ~ kg jobs
NAME COMPLETIONS DURATION AGE
batch-job 0/1 22s 22s

➜ ~ kg po
NAME READY STATUS RESTARTS AGE
batch-job-mdbc4 1/1 Running 0 62s

➜ ~ kg jobs
NAME COMPLETIONS DURATION AGE
batch-job 1/1 2m3s 2m23s

➜ ~ kg po
NAME READY STATUS RESTARTS AGE
batch-job-mdbc4 0/1 Completed 0 2m25s

➜ ~ k logs batch-job-mdbc4
Sat Apr 25 21:03:46 UTC 2020 Batch job starting
Sat Apr 25 21:05:46 UTC 2020 Finished succesfully

# Run Jobs in sequentially - This is a optional if you have the time if not go to parallel

➜ ~ k create -f multi-completion-batch-job.yaml -n default
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

➜ ~ kg jobs
NAME COMPLETIONS DURATION AGE
batch-job 1/1 2m3s 6m57s
multi-completion-batch-job 0/5 21s 21s

➜ ~ kg po
NAME READY STATUS RESTARTS AGE
batch-job-mdbc4 0/1 Completed 0 7m3s
multi-completion-batch-job-4s8kc 1/1 Running 0 27s

➜ ~ kg jobs
NAME COMPLETIONS DURATION AGE
batch-job 1/1 2m3s 8m54s
multi-completion-batch-job 1/5 2m18s 2m18s

➜ ~ kg po
NAME READY STATUS RESTARTS AGE
batch-job-mdbc4 0/1 Completed 0 8m58s
multi-completion-batch-job-4s8kc 0/1 Completed 0 2m22s
multi-completion-batch-job-9g8f4 1/1 Running 0 20s

➜ ~ k logs multi-completion-batch-job-4s8kc
Sat Apr 25 21:10:22 UTC 2020 Batch job starting
Sat Apr 25 21:12:22 UTC 2020 Finished succesfully
➜ ~

➜ ~ kg jobs
NAME COMPLETIONS DURATION AGE
batch-job 1/1 2m3s 10m
multi-completion-batch-job 2/5 4m17s 4m17s
➜ ~ kg po  
NAME READY STATUS RESTARTS AGE
batch-job-mdbc4 0/1 Completed 0 10m
multi-completion-batch-job-4s8kc 0/1 Completed 0 4m20s
multi-completion-batch-job-8g844 1/1 Running 0 16s
multi-completion-batch-job-9g8f4 0/1 Completed 0 2m18s
➜ ~

➜ ~ k logs multi-completion-batch-job-9g8f4
Sat Apr 25 21:12:24 UTC 2020 Batch job starting
Sat Apr 25 21:14:24 UTC 2020 Finished succesfully

~ kg jobs
NAME COMPLETIONS DURATION AGE
batch-job 1/1 2m3s 15m
multi-completion-batch-job 4/5 9m 9m
➜ ~ kg po
NAME READY STATUS RESTARTS AGE
batch-job-mdbc4 0/1 Completed 0 15m
multi-completion-batch-job-4s8kc 0/1 Completed 0 9m2s
multi-completion-batch-job-8g844 0/1 Completed 0 4m58s
multi-completion-batch-job-9g8f4 0/1 Completed 0 7m
multi-completion-batch-job-pbxn8 0/1 Completed 0 2m56s
multi-completion-batch-job-x6ljh 1/1 Running 0 54s

# Run Jobs in Parallel

➜ ~ k create -f multi-completion-parallel-batch-job.yaml -n default

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

➜ ~ kg jobs
NAME COMPLETIONS DURATION AGE
batch-job 1/1 2m3s 19m
multi-completion-batch-job 5/5 10m 13m
multi-completion-parallel-batch-job 0/5 4s 4s

➜ ~ kg po
NAME READY STATUS RESTARTS AGE
batch-job-mdbc4 0/1 Completed 0 19m
multi-completion-batch-job-4s8kc 0/1 Completed 0 13m
multi-completion-batch-job-8g844 0/1 Completed 0 9m4s
multi-completion-batch-job-9g8f4 0/1 Completed 0 11m
multi-completion-batch-job-pbxn8 0/1 Completed 0 7m2s
multi-completion-batch-job-x6ljh 0/1 Completed 0 5m
multi-completion-parallel-batch-job-4r5jz 1/1 Running 0 8s
multi-completion-parallel-batch-job-wfxrn 1/1 Running 0 8s

➜ ~ kg jobs
NAME COMPLETIONS DURATION AGE
batch-job 1/1 2m3s 21m
multi-completion-batch-job 5/5 10m 15m
multi-completion-parallel-batch-job 2/5 2m4s 2m4s

➜ ~ kg po  
NAME READY STATUS RESTARTS AGE
batch-job-mdbc4 0/1 Completed 0 21m
multi-completion-batch-job-4s8kc 0/1 Completed 0 15m
multi-completion-batch-job-8g844 0/1 Completed 0 11m
multi-completion-batch-job-9g8f4 0/1 Completed 0 13m
multi-completion-batch-job-pbxn8 0/1 Completed 0 9m1s
multi-completion-batch-job-x6ljh 0/1 Completed 0 6m59s
multi-completion-parallel-batch-job-479ws 1/1 Running 0 3s
multi-completion-parallel-batch-job-4r5jz 0/1 Completed 0 2m7s
multi-completion-parallel-batch-job-tr45b 1/1 Running 0 4s
multi-completion-parallel-batch-job-wfxrn 0/1 Completed 0 2m7s
➜ ~

➜ ~ kg jobs
NAME COMPLETIONS DURATION AGE
batch-job 1/1 2m3s 25m
multi-completion-batch-job 5/5 10m 18m
multi-completion-parallel-batch-job 4/5 5m24s 5m24s

➜ ~ kg po
NAME READY STATUS RESTARTS AGE
batch-job-mdbc4 0/1 Completed 0 25m
multi-completion-batch-job-4s8kc 0/1 Completed 0 18m
multi-completion-batch-job-8g844 0/1 Completed 0 14m
multi-completion-batch-job-9g8f4 0/1 Completed 0 16m
multi-completion-batch-job-pbxn8 0/1 Completed 0 12m
multi-completion-batch-job-x6ljh 0/1 Completed 0 10m
multi-completion-parallel-batch-job-479ws 0/1 Completed 0 3m22s
multi-completion-parallel-batch-job-4r5jz 0/1 Completed 0 5m26s
multi-completion-parallel-batch-job-pvh2b 1/1 Running 0 81s
multi-completion-parallel-batch-job-tr45b 0/1 Completed 0 3m23s
multi-completion-parallel-batch-job-wfxrn 0/1 Completed 0 5m26s

# Set a cron job - to save time can skip to cronjob with deadline

➜ ~ k create -f cronjob.yaml -n default
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

➜ ~ kg cronjob
NAME SCHEDULE SUSPEND ACTIVE LAST SCHEDULE AGE
batch-job-every-2-mins 36,38,40,42 \* \* \* \* False 0 <none> 70s

➜ ~ kg cronjob
NAME SCHEDULE SUSPEND ACTIVE LAST SCHEDULE AGE
batch-job-every-2-mins 36,38,40,42 \* \* \* \* False 1 15s 50s

➜ ~ kg po  
NAME READY STATUS RESTARTS AGE
batch-job-every-2-mins-1587850680-7s968 1/1 Running 0 9s

➜ ~ kg cronjob
NAME SCHEDULE SUSPEND ACTIVE LAST SCHEDULE AGE
batch-job-every-2-mins 36,38,40,42 \* \* \* \* False 2 9s 2m44s

➜ ~ kg po  
NAME READY STATUS RESTARTS AGE
batch-job-every-2-mins-1587850680-7s968 1/1 Running 0 2m2s
batch-job-every-2-mins-1587850800-r97k8 1/1 Running 0 11s
➜ ~

# Cron Job with deadline

k create -f cronjob_deadline.yaml -n default
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

➜ ~ kg cronjob
NAME SCHEDULE SUSPEND ACTIVE LAST SCHEDULE AGE
batch-job-every-2-mins 36,38,40,42 \* \* \* _ False 0 6m5s 10m
batch-job-every-2-mins-deadline 36,38,40,42,44,46,48 _ \* \* \* False 2 5s 4m2s

➜ ~ kg po
NAME READY STATUS RESTARTS AGE
batch-job-every-2-mins-deadline-1587851160-57fws 0/1 Completed 0 2m10s
batch-job-every-2-mins-deadline-1587851280-tvl4l 1/1 Running 0 9s

❯ kdel cronjob --all
cronjob.batch "batch-job-every-2-mins-deadline" deleted
~

# Create a Service with YAML

k create -f kubia-svc.yaml -n default
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
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
kubernetes ClusterIP 10.100.0.1 <none> 443/TCP 85m
kubia ClusterIP 10.100.142.125 <none> 80/TCP 103s

k exec kubia-5xjrb -- curl -s http://10.100.142.125
You've hit kubia-rkht6

# Need PODS to work with - k create -f kubia-replicaset.yaml -n default

kdel po --all
pod "kubia-9s4q7" deleted
pod "kubia-f9xf7" deleted
pod "kubia-jkgr8" deleted

kg po
NAME READY STATUS RESTARTS AGE
kubia-6sgfs 1/1 Running 0 38s
kubia-lpfbr 1/1 Running 0 38s
kubia-rtgc9 1/1 Running 0 38s

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
Name: kubia
Namespace: default
Labels: <none>
Annotations: <none>
Selector: app=kubia <====== Pod Selctor
Type: ClusterIP
IP: 10.100.90.188
Port: <unset> 80/TCP
TargetPort: 8080/TCP
Endpoints: 192.168.26.253:8080,192.168.37.227:8080,192.168.58.188:8080 <====== Pod endpoints
Session Affinity: None
Events: <none>

kg endpoints kubia
NAME ENDPOINTS AGE
kubia 192.168.26.253:8080,192.168.37.227:8080,192.168.58.188:8080 8m8s

# Service NodePort

k create -f kubia-svc-nodeport.yaml -n default

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

### for AWS ==> edit the security group - port-range 30123 0.0.0.0/0

kg svc kubia-nodeport
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
kubia-nodeport NodePort 10.100.137.248 <none> 80:30123/TCP 3m22s

kg no -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
54.85.96.174 3.234.222.45 18.206.81.24

curl -v -k 54.85.96.174:30123

- About to connect() to 54.85.96.174 port 30123 (#0)
- Trying 54.85.96.174...
- Connected to 54.85.96.174 (54.85.96.174) port 30123 (#0)
  > GET / HTTP/1.1
  > User-Agent: curl/7.29.0
  > Host: 54.85.96.174:30123
  > Accept: _/_
  >
  > < HTTP/1.1 200 OK
  > < Date: Wed, 06 May 2020 20:23:17 GMT
  > < Connection: keep-alive
  > < Transfer-Encoding: chunked
  > <
  > You've hit kubia-mkzk8
- Connection #0 to host 54.85.96.174 left intact
  [jeremy@eks_course kube_yaml_files]$ curl 3.234.222.45:30123
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
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
kubia-loadbalancer LoadBalancer 10.100.49.66 a0171468c8fdd11eabf3112b4bd47f1f-1966275983.us-east-1.elb.amazonaws.com 80:30231/TCP 43s

curl a0171468c8fdd11eabf3112b4bd47f1f-1966275983.us-east-1.elb.amazonaws.com
You've hit kubia-mkzk8

curl a0171468c8fdd11eabf3112b4bd47f1f-1966275983.us-east-1.elb.amazonaws.com
You've hit kubia-hw6cl

# Create an Ingress resource

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
NAME HOSTS ADDRESS PORTS AGE
kubia kubia.example.com 80 36s

❯ kg ingresses
NAME HOSTS ADDRESS PORTS AGE
kubia kubia.example.com 35.244.178.129 80 112s

kdel po --all

cat /etc/hosts

localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.122.35 kube-master.jeremycoando.com m1
192.168.122.32 kube-slave1.jeremycoando.com s1
192.168.122.5 kube-slave2.jeremycoando.com s2
10.0.0.110 devops_server.example.com dev

35.244.178.129 kubia.example.com
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
NAME TYPE DATA AGE
tls-secret kubernetes.io/tls 2 22s
~ ○ kubia
❯ kd secrets tls-secret
Name: tls-secret
Namespace: default
Labels: <none>
Annotations: <none>

Type: kubernetes.io/tls

# Data

tls.crt: 1115 bytes
tls.key: 1675 bytes
~

❯ curl -k -v https://kubia.example.com/

- About to connect() to kubia.example.com port 443 (#0)
- Trying 35.244.178.129...
- Connected to kubia.example.com (35.244.178.129) port 443 (#0)
- Initializing NSS with certpath: sql:/etc/pki/nssdb
- skipping SSL peer certificate verification
- SSL connection using TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
- Server certificate:
-     subject: CN=kubia.example.com
-     start date: May 06 23:42:45 2020 GMT
-     expire date: May 01 23:42:45 2021 GMT
-     common name: kubia.example.com
-     issuer: CN=kubia.example.com
  > GET / HTTP/1.1
  > User-Agent: curl/7.29.0
  > Host: kubia.example.com
  > Accept: _/_
  >
  > < HTTP/1.1 200 OK
  > < Date: Wed, 06 May 2020 23:54:18 GMT
  > < Transfer-Encoding: chunked
  > < Via: 1.1 google
  > < Alt-Svc: clear
  > <
  > You've hit kubia-gpl58

# Readiness Probe - Need LB svc kubia-svc-loadbalancer.yaml

k apply -f kubia-rc-probe.yaml

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
NAME READY STATUS RESTARTS AGE
kubia-probe-492tl 0/1 Running 0 5s
kubia-probe-4mpgj 0/1 Running 0 5s
kubia-probe-np7zb 0/1 Running 0 5s

~ ○

❯ k exec kubia-probe-492tl -- touch /var/ready
~ ○ kubia

                                                                                                   ○ kubia

❯ kg po
NAME READY STATUS RESTARTS AGE
kubia-probe-492tl 1/1 Running 0 118s
kubia-probe-4mpgj 0/1 Running 0 118s
kubia-probe-np7zb 0/1 Running 0 118s

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
Server: 10.55.240.10
Address: 10.55.240.10#53

Name: kubia-headless.default.svc.cluster.local
Address: 10.52.0.14
Name: kubia-headless.default.svc.cluster.local
Address: 10.52.1.9

# kdel all --all

# PV's and PVC's

❯ k create -f fortune-pod.yaml -n default
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
    emptyDir: {}
     -->

# alias kpf

k port-forward fortune 8888:80
Forwarding from 127.0.0.1:8888 -> 80
Forwarding from [::1]:8888 -> 80
Handling connection for 8888

❯ curl -I -v http://localhost:8888

- About to connect() to localhost port 8888 (#0)
- Trying ::1...
- Connected to localhost (::1) port 8888 (#0)
  > HEAD / HTTP/1.1
  > User-Agent: curl/7.29.0
  > Host: localhost:8888
  > Accept: _/_
  >
  > < HTTP/1.1 200 OK
  > HTTP/1.1 200 OK
  > < Server: nginx/1.17.10
  > Server: nginx/1.17.10
  > < Date: Tue, 12 May 2020 13:54:25 GMT
  > Date: Tue, 12 May 2020 13:54:25 GMT
  > < Content-Type: text/html
  > Content-Type: text/html
  > < Content-Length: 94
  > Content-Length: 94
  > < Last-Modified: Tue, 12 May 2020 13:54:20 GMT
  > Last-Modified: Tue, 12 May 2020 13:54:20 GMT
  > < Connection: keep-alive
  > Connection: keep-alive
  > < ETag: "5ebaaa8c-5e"
  > ETag: "5ebaaa8c-5e"
  > < Accept-Ranges: bytes
  > Accept-Ranges: bytes

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
modify pseudonative/kubia-website-example/index.html
and check again

❯

Also Try it in a web browser

# Examining System Pods

❯ kg po -n kube-system | grep -Ei fluentd
fluentd-gcp-scaler-bfd6cf8dd-r4ztj 1/1 Running 0 16h
fluentd-gcp-v3.1.1-27q5s 2/2 Running 0 16h
fluentd-gcp-v3.1.1-kr7q6 2/2 Running 0 16h
fluentd-gcp-v3.1.1-mqnt2 2/2 Running 0 16h

❯ kd po fluentd-gcp-v3.1.1-kr7q6 -n kube-system

Volumes:
varrun:
Type: HostPath (bare host directory volume)
Path: /var/run/google-fluentd
HostPathType:  
 varlog:
Type: HostPath (bare host directory volume)
Path: /var/log
HostPathType:  
 varlibdockercontainers:
Type: HostPath (bare host directory volume)
Path: /var/lib/docker/containers
HostPathType:  
 config-volume:
Type: ConfigMap (a volume populated by a ConfigMap)
Name: fluentd-gcp-config-v1.2.6
Optional: false
fluentd-gcp-token-cx4jz:
Type: Secret (a volume populated by a Secret)
SecretName: fluentd-gcp-token-cx4jz
Optional: false

# Using GCE Persistent Disk pod Volume

❯ gcloud container clusters list
NAME LOCATION MASTER_VERSION MASTER_IP MACHINE_TYPE NODE_VERSION NUM_NODES STATUS
jaykube us-central1-a 1.14.10-gke.27 34.69.76.133 n1-standard-1 1.14.10-gke.27 3 RUNNING
~

❯ gcloud compute disks create --size=10GB --zone=us-central1-a mongodb

NAME ZONE SIZE_GB TYPE STATUS
mongodb us-central1-a 1 pd-standard READY

New disks are unformatted. You must format and mount a disk before it
can be used. You can find instructions on how to do this at:

https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting

~ 3s G kubernetes-222302
❯ gcloud compute disks list
NAME LOCATION LOCATION_SCOPE SIZE_GB TYPE STATUS
gke-jaykube-default-pool-6124d961-6lcw us-central1-a zone 100 pd-standard READY
gke-jaykube-default-pool-6124d961-8jt9 us-central1-a zone 100 pd-standard READY
gke-jaykube-default-pool-6124d961-v28l us-central1-a zone 100 pd-standard READY
mongodb us-central1-a zone 1 pd-standard READY
~

k create -f mongodb-pod-gecpd.yaml -n default
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

## k exec -it mongodb mongo

> use mystore
> switched to db mystore
> db.foo.insert({name:'MuthaFucka'})
> WriteResult({ "nInserted" : 1 })
> db.foo.find()
> { "\_id" : ObjectId("5ebab197b580b2b9869acc7f"), "name" : "MuthaFucka" }

❯ kdel po mongodb
pod "mongodb" deleted
~

k create -f mongodb-pod-gecpd.yaml -n default

❯ k exec -it mongodb mongo
MongoDB shell version v4.2.6

---

> use mystore
> switched to db mystore
> db.foo.find()
> { "\_id" : ObjectId("5ebab197b580b2b9869acc7f"), "name" : "MuthaFucka" }
>
> bye
> ~

# Create a pv - Persistent Volume

k create -f mongodb-pv-gcepd.yaml -n default
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
NAME CAPACITY ACCESS MODES RECLAIM POLICY STATUS CLAIM STORAGECLASS REASON AGE
mongodb-pv 1Gi RWO,ROX Retain Available 28s
~

# Create the pvc - Persistent Volume Claim

k create -f mongodb-pvc.yaml
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
NAME STATUS VOLUME CAPACITY ACCESS MODES STORAGECLASS AGE
mongodb-pvc Bound mongodb-pv 1Gi RWO,ROX 39s
~

kg pv
NAME CAPACITY ACCESS MODES RECLAIM POLICY STATUS CLAIM STORAGECLASS REASON AGE
mongodb-pv 1Gi RWO,ROX Retain Bound default/mongodb-pvc 4m59s
~

# Use a Persistent Volume Claim in a Pod

kdel po mongodb

k create -f mongodb-pod-pvc.yaml -n default
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
> switched to db mystore
> db.foo.find()
> { "\_id" : ObjectId("5ebab197b580b2b9869acc7f"), "name" : "MuthaFucka" }
>
> bye
> ~

# Recycle Persistent Volumes

❯ kdel po mongodb
pod "mongodb" deleted
~

k create -f mongodb-pod-pvc.yaml -n default
pod/mongodb created
....
Events:
Type Reason Age From Message

---

Warning FailedScheduling 19s (x2 over 19s) default-scheduler persistentvolumeclaim "mongodb-pvc" not found

kdel po mongodb
kdel pv --all
kdel pvc --all

                                                                               ○ jaykube

❯ k create -f mongodb-pod-pvc.yaml -n default
pod/mongodb created

❯

❯ kg pvc
NAME STATUS VOLUME CAPACITY ACCESS MODES STORAGECLASS AGE
mongodb-pvc Pending 42s
~ ○ jaykube
❯ kg pv
NAME CAPACITY ACCESS MODES RECLAIM POLICY STATUS CLAIM STORAGECLASS REASON AGE
mongodb-pv 1Gi RWO,ROX Retain Released default/mongodb-pvc 14m
~

❯ kdel po mongodb
pod "mongodb" deleted
~ ○ jaykube
❯ kdel pvc --all
persistentvolumeclaim "mongodb-pvc" deleted
~ ○ jaykube
❯ kdel pv --all
persistentvolume "mongodb-pv" deleted
~  
❯

❯ k create -f mongodb-pv-gcepd.yaml -n default
persistentvolume/mongodb-pv created
○ jaykube
❯ k create -f mongodb-pvc.yaml  
persistentvolumeclaim/mongodb-pvc created
○ jaykube
❯ k create -f mongodb-pod-pvc.yaml -n default
pod/mongodb created

❯

kd po mongodb
...
Events:
Type Reason Age From Message

---

Normal Scheduled 8s default-scheduler Successfully assigned default/mongodb to gke-jaykube-default-pool-7cd41a23-43tq
Normal SuccessfulAttachVolume 2s attachdetach-controller AttachVolume.Attach succeeded for volume "mongodb-pv"

❯ kg pv
NAME CAPACITY ACCESS MODES RECLAIM POLICY STATUS CLAIM STORAGECLASS REASON AGE
mongodb-pv 1Gi RWO,ROX Retain Bound default/mongodb-pvc 52s
~ ○ jaykube
❯ kg pvc
NAME STATUS VOLUME CAPACITY ACCESS MODES STORAGECLASS AGE
mongodb-pvc Bound mongodb-pv 1Gi RWO,ROX 45s
~  
❯

## k exec -it mongodb mongo

> use mystore
> switched to db mystore
> db.foo.find()
> { "\_id" : ObjectId("5ebab197b580b2b9869acc7f"), "name" : "MuthaFucka" }
>
> bye
> ~

# Define a storage class

kdel po mongodb

# you have to delete the pvc in order for the pv to delete

❯ kdel pvc --all
persistentvolumeclaim "mongodb-pvc" deleted

# PVC may get stuck - kubectl patch pvc mongodb-pvc {"metadata":{"finalizers":null}}

❯ kdel pv --all
persistentvolume "mongodb-pv" deleted

                                                                                       ○ jaykube

❯ kg pvc
NAME STATUS VOLUME CAPACITY ACCESS MODES STORAGECLASS AGE
mongodb-pvc Terminating mongodb-pv 1Gi RWO,ROX 37m

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
NAME PROVISIONER AGE
fast kubernetes.io/gce-pd 46s
~

k create -f mongodb-pvc-dp.yaml -n default
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

NAME CAPACITY ACCESS MODES RECLAIM POLICY STATUS CLAIM STORAGECLASS REASON AGE
pvc-31c34e07-9466-11ea-be15-42010a80010e 1Gi RWO Delete Bound default/mongodb-pvc fast 31s
~ ○ jaykube

❯ kg pvc
NAME STATUS VOLUME CAPACITY ACCESS MODES STORAGECLASS AGE
mongodb-pvc Bound pvc-31c34e07-9466-11ea-be15-42010a80010e 1Gi RWO fast 35s
~

gcloud compute disks list | grep -Ei pd-ssd
gke-jaykube-9c1a0a79-d-pvc-31c34e07-9466-11ea-be15-42010a80010e us-central1-a zone 1 pd-ssd READY
~

❯ kg sc
NAME PROVISIONER AGE
fast kubernetes.io/gce-pd 7m51s
standard (default) kubernetes.io/gce-pd 17h
~

# Create Persistent Volume without specifying storage class

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

k create -f mongodb-pvc-dp-nostorageclass.yaml -n default
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
NAME STATUS VOLUME CAPACITY ACCESS MODES STORAGECLASS AGE
mongodb-pvc2 Bound pvc-3479b215-9467-11ea-be15-42010a80010e 1Gi RWO standard 6m26s
~ ○ jaykube

❯ kg pv pvc-3479b215-9467-11ea-be15-42010a80010e
NAME CAPACITY ACCESS MODES RECLAIM POLICY STATUS CLAIM STORAGECLASS REASON AGE
pvc-3479b215-9467-11ea-be15-42010a80010e 1Gi RWO Delete Bound default/mongodb-pvc2 standard 6m34s
~ G kubernetes-222302

❯ gcloud compute disks list
NAME LOCATION LOCATION_SCOPE SIZE_GB TYPE STATUS
gke-jaykube-9c1a0a79-d-pvc-31c34e07-9466-11ea-be15-42010a80010e us-central1-a zone 1 pd-ssd READY
gke-jaykube-9c1a0a79-d-pvc-3479b215-9467-11ea-be15-42010a80010e us-central1-a zone 1 pd-standard READY

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
Name: mongodb
Namespace: default
Priority: 0
Node: gke-jaykube-default-pool-6124d961-8jt9/10.128.0.28
Start Time: Tue, 12 May 2020 10:00:17 -0600
L.......
Events:
Type Reason Age From Message

---

Normal Scheduled 23s default-scheduler Successfully assigned default/mongodb to gke-jaykube-default-pool-6124d961-8jt9
Normal SuccessfulAttachVolume 15s attachdetach-controller AttachVolume.Attach succeeded for volume "pvc-3479b215-9467-11ea-be15-42010a80010e"
Normal Pulling 5s kubelet, gke-jaykube-default-pool-6124d961-8jt9 Pulling image "mongo"
Normal Pulled 5s kubelet, gke-jaykube-default-pool-6124d961-8jt9 Successfully pulled image "mongo"
Normal Created 4s kubelet, gke-jaykube-default-pool-6124d961-8jt9 Created container mongodb
Normal Started 4s kubelet, gke-jaykube-default-pool-6124d961-8jt9 Started container mongodb
~

###### Config Maps And Secrets

k create -f fortune-pod-args.yaml -n default
pod/fortune2s created

<!--
apiVersion: v1
kind: Pod
metadata:
  name: fortune2s
spec:
  containers:
  - image: luksa/fortune:args
    args: ["2"]
    name: html-generator
    volumeMounts:
    - name: html
      mountPath:  /var/htdocs
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

k create -f fortune-pod-env.yaml -n default
pod/fortune-env created

<!--
apiVersion: v1
kind: Pod
metadata:
  name: fortune-env
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: INTERVAL
      value: "30"
    name: html-generator
    volumeMounts:
    - name: html
      mountPath:  /var/htdocs
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
    emptyDir: {}
 -->

k create -f fortune-pod-env-variable-inside-variable.yaml
pod/fortune-env-variable created

<!--
apiVersion: v1
kind: Pod
metadata:
  name: fortune-env-variable
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: FIRST_VAR
      value: "foo"
    - name: SECOND_VAR
      value: "$(FIRST_VAR)bar"
    name: html-generator
    volumeMounts:
    - name: html
      mountPath:  /var/htdocs
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
    emptyDir: {}
 -->

❯ k create configmap fortune-config --from-literal=sleep-interval=25
configmap/fortune-config created
~ ○ jaykube
❯ kg configmap fortune-config
NAME DATA AGE
fortune-config 1 9s
~ ○ jaykube
❯ kd configmap fortune-config
Name: fortune-config
Namespace: default
Labels: <none>
Annotations: <none>

# Data

## sleep-interval:

25
Events: <none>
~  
❯

❯ k create configmap myconfigmap --from-literal=foo=bar --from-literal=bar=baz --from-literal=one=two
configmap/myconfigmap created
~ ○ jaykube

                                                                                                                           ○ jaykube

❯ kg configmap myconfigmap
NAME DATA AGE
myconfigmap 3 16s
~ ○ jaykube
❯ kd configmap myconfigmap
Name: myconfigmap
Namespace: default
Labels: <none>
Annotations: <none>

# Data

## bar:

baz
foo:

---

bar
one:

---

two
Events: <none>
~  
❯

❯ kg configmap fortune-config -oyaml
apiVersion: v1
data:
sleep-interval: "25"
kind: ConfigMap
metadata:
creationTimestamp: "2020-05-16T17:13:17Z"
name: fortune-config
namespace: default
resourceVersion: "29368"
selfLink: /api/v1/namespaces/default/configmaps/fortune-config
uid: 89157b7a-9798-11ea-ab20-42010a80008d
~

# Use configmap fortune-config to create fortune-config.yaml

<!--
apiVersion: v1
data:
  sleep-interval: "25"
kind: ConfigMap
metadata:
  creationTimestamp: "2020-05-16T17:13:17Z"
  name: fortune-config-from-config
  namespace: default
  resourceVersion: "29368"
  selfLink: /api/v1/namespaces/default/configmaps/fortune-config
  uid: 89157b7a-9798-11ea-ab20-42010a80008d
  -->

cp fortune-config.yaml config-file.conf

k create configmap my-config --from-file=/home/jeremy/DevStudy/yaml_files/config-file.conf
configmap/my-config created

k create -f fortune-pod-env-configmap.yaml -n default
pod/fortune-env-from-configmap created

<!--
apiVersion: v1
kind: Pod
metadata:
  name: fortune-env-from-configmap
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
    name: html-generator
    volumeMounts:
    - name: html
      mountPath:  /var/htdocs
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

k create -f fortune-pod-args-configmap.yaml -n default

<!--
apiVersion: v1
kind: Pod
metadata:
  name: fortuen-args-from-configmap
spec:
  containers:
  - image: luksa/fortune:args
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
    args: ["$(interval)"]
    name: html-generator
    volumeMounts:
    - name: html
      mountPath:  /var/htdocs
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

cat configmap-files/my-nginx-config.conf

<!--
server {
    listen              80:
    server_name         www.kubia-example.com;

    gzip on;
    gzip_types text/plain application/xml;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }
}
 -->

❯ cat configmap-files/sleep-interval

<!--
25
 -->

kdel configmap fortune-config
configmap "fortune-config" deleted
~

k create configmap fortune-config --from-file=/home/jeremy/DevStudy/yaml_files/configmap-files
configmap/fortune-config created

❯ kd configmap fortune-config

<!-- Name:         fortune-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
fortune-pod-configmap-volume.yaml:
----
apiVersion: v1
kind: Pod
metadata:
  name: fortune-configmap-volume
spec:
  containers:
  - image: luksa/fortune:env
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: sleep-interval
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
    - name: config
      mountPath: /etc/nginx/conf.d
      readOnly: true
    - name: config
      mountPath: /tmp/whole-fortune-config-volume
      readOnly: true
    ports:
      - containerPort: 80
        name: http
        protocol: TCP
  volumes:
  - name: html
    emptyDir: {}
  - name: config
    configMap:
      name: fortune-config

my-nginx-config.conf:
----
server {
    listen              80:
    server_name         www.kubia-example.com;

    gzip on;
    gzip_types text/plain application/xml;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }
}
sleep-interval:
----
25

Events:  <none>
~                             -->

kg configmap fortune-config -oyaml

<!-- apiVersion: v1
data:
  fortune-pod-configmap-volume.yaml: "apiVersion: v1\nkind: Pod\nmetadata:\n  name:
    fortune-configmap-volume\nspec:\n  containers:\n  - image: luksa/fortune:env\n
    \   env:\n    - name: INTERVAL\n      valueFrom:\n        configMapKeyRef:\n          name:
    fortune-config \n          key: sleep-interval \n    name: html-generator \n    volumeMounts:\n
    \   - name: html  \n      mountPath: /var/htdocs\n  - image: nginx:alpine\n    name:
    web-server \n    volumeMounts:\n    - name: html \n      mountPath: /usr/share/nginx/html\n
    \     readOnly: true \n    - name: config \n      mountPath: /etc/nginx/conf.d\n
    \     readOnly: true\n    - name: config\n      mountPath: /tmp/whole-fortune-config-volume\n
    \     readOnly: true\n    ports:\n      - containerPort: 80\n        name: http\n
    \       protocol: TCP\n  volumes:\n  - name: html\n    emptyDir: {}\n  - name:
    config\n    configMap:\n      name: fortune-config\n"
  my-nginx-config.conf: |-
    server {
        listen              80:
        server_name         www.kubia-example.com;

        gzip on;
        gzip_types text/plain application/xml;

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }
    }
  sleep-interval: |
    25
kind: ConfigMap
metadata:
  creationTimestamp: "2020-05-16T17:43:03Z"
  name: fortune-config
  namespace: default
  resourceVersion: "35715"
  selfLink: /api/v1/namespaces/default/configmaps/fortune-config
  uid: b19e8b09-979c-11ea-ab20-42010a80008d
~
❯   -->

k create -f fortune-pod-confimgmap-volume.yaml -n default
pod/fortune-configmap-volume created

❯ k port-forward fortune-configmap-volume 8888:80 &
[1] 4895
~ ≡
❯ Forwarding from 127.0.0.1:8888 -> 80
Forwarding from [::1]:8888 -> 80

❯ curl -H "Accept-Encoding: gzip" -I localhost:8888
HTTP/1.1 200 OK
Server: nginx/1.17.10
Date: Sat, 16 May 2020 18:46:27 GMT
Content-Type: text/html
Last-Modified: Sat, 16 May 2020 18:46:09 GMT
Connection: keep-alive
ETag: W/"5ec034f1-1fd"
Content-Encoding: gzip

~  
❯ Forwarding from 127.0.0.1:8888 -> 80
Forwarding from [::1]:8888 -> 80
Handling connection for 8888

k exec fortune-configmap-volume -c web-server ls /etc/nginx/conf.d
fortune-pod-configmap-volume.yaml
my-nginx-config.conf
sleep-interval
~

k apply -f fortune-pod-confimgmap-volume-defaultMode.yaml -n default

k edit configmap fortune-config

gzip off

wq

configmap/fortune-config edited

❯ k exec fortune-configmap-volume -c web-server cat /etc/nginx/conf.d/my-nginx-config.conf
server {
listen 80;
server_name www.kubia-example.com;

    gzip off;
    gzip_types text/plain application/xml;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }

} ~  
❯

k exec fortune-configmap-volume -c web-server -- nginx -s reload
2020/05/16 19:01:04 [notice] 17#17: signal process started
~

❯ k exec -it fortune-configmap-volume -c web-server -- ls -lA /etc/nginx/conf.d
total 4
drwxr-xr-x 2 root root 4096 May 16 18:59 ..2020_05_16_18_59_10.880794085
lrwxrwxrwx 1 root root 31 May 16 18:59 ..data -> ..2020_05_16_18_59_10.880794085
lrwxrwxrwx 1 root root 40 May 16 18:44 fortune-pod-configmap-volume.yaml -> ..data/fortune-pod-configmap-volume.yaml
lrwxrwxrwx 1 root root 27 May 16 18:44 my-nginx-config.conf -> ..data/my-nginx-config.conf
lrwxrwxrwx 1 root root 21 May 16 18:44 sleep-interval -> ..data/sleep-interval
~  
❯

# Secrets

❯ kd po fortune-configmap-volume | grep -Ei secret
/var/run/secrets/kubernetes.io/serviceaccount from default-token-9pr9c (ro)
/var/run/secrets/kubernetes.io/serviceaccount from default-token-9pr9c (ro)
Type: Secret (a volume populated by a Secret)
SecretName: default-token-9pr9c
~  
❯

❯ kg secrets
NAME TYPE DATA AGE
default-token-9pr9c kubernetes.io/service-account-token 3 4h6m
~  
❯

❯ kd secrets
Name: default-token-9pr9c
Namespace: default
Labels: <none>
Annotations: kubernetes.io/service-account.name: default
kubernetes.io/service-account.uid: cbed923d-9785-11ea-ab20-42010a80008d

Type: kubernetes.io/service-account-token

# Data

ca.crt: 1115 bytes
namespace: 7 bytes
token: eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZmF1bHQtdG9rZW4tOXByOWMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImNiZWQ5MjNkLTk3ODUtMTFlYS1hYjIwLTQyMDEwYTgwMDA4ZCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.PH4IdPXSJoB9G59nsdvJFO5i8EwOihqmUlopzkuholwEq7y4QkGtz3nvr4dRQX0nBFn4PZa5v2-dH5QoeD4wE-Z2KMyzExjcYR4mleG_vQGaknNcLiJFfWaSWpUlqx4KVfOtlpko6fpQi5GQtg_lwBGkTCvJ3SJFmT4kTP_fXbz3iRW6qjuTkWormcV-4Tgp_Dzxcb1QA0fGa0m-qOUc2dSzJGcxx52yYlW18dqcjXeOnztx9GURc1mAV9Ca0S2n57xJd-ZkIc-Mbi8jHYjn1eUjKW1OiAhc4ppRrdoTm8Rqh81U4MxvAEV2YZEL0R-XsN0_dRTyPAdMXuSEg-MEIg
~  
❯

❯ kd po fortune-configmap-volume  
...
Mounts:
/var/htdocs from html (rw)
/var/run/secrets/kubernetes.io/serviceaccount from default-token-9pr9c (ro)

❯ k exec fortune-configmap-volume ls /var/run/secrets/kubernetes.io/serviceaccount/
Defaulting container name to html-generator.
Use 'kubectl describe pod/fortune-configmap-volume -n default' to see all of the containers in this pod.
ca.crt
namespace
token
~  
❯

# Remember to remove the .key and .cert from ~/

❯ openssl genrsa -out https.key 2048
Generating RSA private key, 2048 bit long modulus
...............................................................+++
................+++
e is 65537 (0x10001)
~  
❯ openssl req -new -x509 -key https.key -out https.cert -days 365 -subj /CN=www.kubia-example.com
~  
❯

❯ echo bar > foo
~ ○ jaykube
❯ k create secret generic fortune-https --from-file=https.key --from-file=https.cert --from-file=foo

secret/fortune-https created
~  
❯

❯ kg secret fortune-https -oyaml
apiVersion: v1
data:
foo: YmFyCg==
https.cert:

kind: Secret

k create configmap fortune-config-ssl --from-file=/home/jeremy/DevStudy/yaml_files/configmap-files/ssl

# launch from this directory - gonna have to scale up nodes or delete existing pods

# ~/DevStudy/yaml_files/configmap-files/ssl

❯ k create -f fortune-pod-configmap-volume.yaml
pod/fortune-configmap-volume-ssl created

<!--
server {
        listen              80;
        listen              443 ssl;
        server_name         www.kubia-example.com;

        ssl_certificate     certs/https.cert;
        ssl_certificate_key certs/https.key;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }
    }
 -->
<!--
apiVersion: v1
kind: Pod
metadata:
  name: fortune-https
spec:
  containers:
  - image: luksa/fortune:env
    name: html-generator
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: fortune-config-ssl
          key: sleep-interval
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    - name: config
      mountPath: /etc/nginx/conf.d
      readOnly: true
    - name: certs
      mountPath: /etc/nginx/certs
      readOnly: true
    ports:
      - containerPort: 80
      - containerPort: 443
        name: http
        protocol: TCP
  volumes:
  - name: html
    emptyDir: {}
  - name: config
    configMap:
      name: fortune-config-ssl
      items:
      - key: my-nginx-config-ssl.conf
        path: https.conf
  - name: certs
    secret:
      secretName: fortune-https

 -->

❯ kg po fortune-https
NAME READY STATUS RESTARTS AGE
fortune-https 2/2 Running 0 50s
~

❯ k port-forward fortune-https 4443:443 &
[2] 11390
~ ≡
❯ Forwarding from 127.0.0.1:4443 -> 443
Forwarding from [::1]:4443 -> 443

❯ curl https://localhost:4443 -k -v

- About to connect() to localhost port 4443 (#0)
- Trying ::1...
- Connected to localhost (::1) port 4443 (#0)
- Initializing NSS with certpath: sql:/etc/pki/nssdb
- skipping SSL peer certificate verification
- SSL connection using TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
- Server certificate:
-     subject: CN=www.kubia-example.com
-     start date: May 16 19:12:01 2020 GMT
-     expire date: May 16 19:12:01 2021 GMT
-     common name: www.kubia-example.com
-     issuer: CN=www.kubia-example.com
  > GET / HTTP/1.1
  > User-Agent: curl/7.29.0
  > Host: localhost:4443
  > Accept: _/_
  >
  > < HTTP/1.1 200 OK
  > < Server: nginx/1.17.10
  > < Date: Sat, 16 May 2020 19:45:35 GMT
  > < Content-Type: text/html
  > < Content-Length: 92
  > < Last-Modified: Sat, 16 May 2020 19:45:20 GMT
  > < Connection: keep-alive
  > < ETag: "5ec042d0-5c"
  > < Accept-Ranges: bytes
  > <
  > Clothes make the man. Naked people have little or no influence on society.
      	-- Mark Twain
- Connection #0 to host localhost left intact
  ~  
  ❯

❯ curl https://localhost:4443 -k  
Habit is habit, and not to be flung out of the window by any man, but coaxed
down-stairs a step at a time.
-- Mark Twain, "Pudd'nhead Wilson's Calendar
~  
❯

❯ k exec fortune-https -c web-server -- mount | grep certs
tmpfs on /etc/nginx/certs type tmpfs (ro,relatime)
~  
❯

# Singl Yaml File Replication Controller and Service

k create -f kubia-rc-and-service-v1.yaml -n default
replicationcontroller/kubia-v1 created
service/kubia created

<!--
apiVersion: v1
kind: ReplicationController
metadata:
  name: kubia-v1
spec:
  replicas: 3
  template:
    metadata:
      name: kubia
      labels:
        app: kubia
    spec:
      containers:
      - image: luksa/kubia:v1
        name: nodejs
---
apiVersion: v1
kind: Service
metadata:
  name: kubia
spec:
  type: LoadBalancer
  selector:
    app: kubia
  ports:
  - port: 80
    targetPort: 8080
     -->

❯ kg svc kubia
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
kubia LoadBalancer 10.51.252.132 104.198.208.184 80:30290/TCP 112s
~  
❯

while true; do curl http://104.198.208.184; done
This is v1 running in pod kubia-v1-8gxhv
This is v1 running in pod kubia-v1-8gxhv
This is v1 running in pod kubia-v1-8gxhv
This is v1 running in pod kubia-v1-6dz87
This is v1 running in pod kubia-v1-4tdpj
This is v1 running in pod kubia-v1-4tdpj
This is v1 running in pod kubia-v1-8gxhv

# keep running while making rolling update to see v1 change to v2

k rolling-update kubia-v1 kubia-v2 --image=luksa/kubia:v2
Command "rolling-update" is deprecated, use "rollout" instead
Created kubia-v2
Scaling up kubia-v2 from 0 to 3, scaling down kubia-v1 from 3 to 0 (keep 3 pods available, don't exceed 4 pods)
Scaling kubia-v2 up to 1
Scaling kubia-v1 down to 2
Scaling kubia-v2 up to 2
Continuing update with existing controller kubia-v2.
Scaling up kubia-v2 from 2 to 3, scaling down kubia-v1 from 2 to 0 (keep 3 pods available, don't exceed 4 pods)
Update succeeded. Deleting kubia-v1
replicationcontroller/kubia-v2 rolling updated to "kubia-v2"

kg po --watch
NAME READY STATUS RESTARTS AGE
kubia-v1-4tdpj 1/1 Running 0 5m26s
kubia-v1-6dz87 1/1 Running 0 5m26s
kubia-v1-8gxhv 1/1 Running 0 5m26s
kubia-v2-ptk7n 1/1 Running 0 44s
NAME AGE
kubia-v1-4tdpj 5m46s
kubia-v2-cl5vn 0s
kubia-v2-cl5vn 0s
kubia-v2-cl5vn 0s
kubia-v2-cl5vn 3s
kubia-v1-4tdpj 6m16s
kubia-v1-4tdpj 6m17s
kubia-v1-4tdpj 6m17s

kd rc kubia-v2
Name: kubia-v2
Namespace: default
Selector: app=kubia,deployment=a8594fc36987b2a46f90be05a7bcee90
Labels: app=kubia
Annotations: kubectl.kubernetes.io/desired-replicas: 3
kubectl.kubernetes.io/update-source-id: kubia-v1:3d96dcc2-9ab9-11ea-ad22-42010a80001c
Replicas: 2 current / 2 desired
Pods Status: 2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
Labels: app=kubia
deployment=a8594fc36987b2a46f90be05a7bcee90
Containers:
nodejs:
Image: luksa/kubia:v2
Port: <none>
Host Port: <none>
Environment: <none>
Mounts: <none>
Volumes: <none>
Events:
Type Reason Age From Message

---

Normal SuccessfulCreate 3m44s replication-controller Created pod: kubia-v2-ptk7n
Normal SuccessfulCreate 2m37s replication-controller Created pod: kubia-v2-cl5vn

kd rc kubia-v1
Name: kubia-v1
Namespace: default
Selector: app=kubia,deployment=c06162b6f9f03c60afc6200a963221be-orig
Labels: app=kubia
Annotations: kubectl.kubernetes.io/next-controller-id: kubia-v2
kubectl.kubernetes.io/original-replicas: 3
Replicas: 1 current / 1 desired
Pods Status: 2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
Labels: app=kubia
deployment=c06162b6f9f03c60afc6200a963221be-orig
Containers:
nodejs:
Image: luksa/kubia:v1
Port: <none>
Host Port: <none>
Environment: <none>
Mounts: <none>
Volumes: <none>
Events:
Type Reason Age From Message

---

Normal SuccessfulCreate 9m23s replication-controller Created pod: kubia-v1-8gxhv
Normal SuccessfulCreate 9m23s replication-controller Created pod: kubia-v1-6dz87
Normal SuccessfulCreate 9m23s replication-controller Created pod: kubia-v1-4tdpj
Normal SuccessfulDelete 3m37s replication-controller Deleted pod: kubia-v1-4tdpj
Normal SuccessfulDelete 23s replication-controller Deleted pod: kubia-v1-8gxhv

kg po --show-labels
NAME READY STATUS RESTARTS AGE LABELS
kubia-v1-6dz87 1/1 Running 0 9m54s app=kubia,deployment=c06162b6f9f03c60afc6200a963221be-orig
kubia-v2-cl5vn 1/1 Running 0 4m5s app=kubia,deployment=a8594fc36987b2a46f90be05a7bcee90
kubia-v2-ptk7n 1/1 Running 0 5m12s app=kubia,deployment=a8594fc36987b2a46f90be05a7bcee90
kubia-v2-zbwsw 1/1 Running 0 51s app=kubia,deployment=a8594fc36987b2a46f90be05a7bcee90

# Roll it back to see rolling update with Verbose logging -v

k rolling-update kubia-v2 kubia-v1 --image=luksa/kubia:v1
Command "rolling-update" is deprecated, use "rollout" instead
Created kubia-v1
Scaling up kubia-v1 from 0 to 3, scaling down kubia-v2 from 3 to 0 (keep 3 pods available, don't exceed 4 pods)
Scaling kubia-v1 up to 1
Scaling kubia-v2 down to 2
Scaling kubia-v1 up to 2
Scaling kubia-v2 down to 1
Scaling kubia-v1 up to 3
Scaling kubia-v2 down to 0
Update succeeded. Deleting kubia-v2
replicationcontroller/kubia-v1 rolling updated to "kubia-v1"
~ 3m 17s
❯

k rolling-update kubia-v1 kubia-v2 --image=luksa/kubia:v2 --v 6
Command "rolling-update" is deprecated, use "rollout" instead
I0520 11:01:33.777799 28918 loader.go:375] Config loaded from file: /home/jeremy/.kube/config
I0520 11:01:33.941768 28918 round_trippers.go:443] GET https://35.193.179.130/api/v1/namespaces/default/replicationcontrollers/kubia-v1 200 OK in 150 milliseconds
I0520 11:01:33.989933 28918 round_trippers.go:443] GET https://35.193.179.130/api/v1/namespaces/default/replicationcontrollers/kubia-v2 404 Not Found in 32 milliseconds
I0520 11:01:34.029987 28918 round_trippers.go:443] GET https://35.193.179.130/api/v1/namespaces/default/replicationcontrollers/kubia-v1 200 OK in 39 milliseconds
I0520 11:01:34.071571 28918 round_trippers.go:443] PUT https://35.193.179.130/api/v1/namespaces/default/replicationcontrollers/kubia-v1 200 OK in 37 milliseconds
I0520 11:01:34.113667 28918 round_trippers.go:443] GET https://35.193.179.130/api/v1/namespaces/default/replicationcontrollers/kubia-v2 404 Not Found in 41 milliseconds
I0520 11:01:34.178822 28918 round_trippers.go:443] POST https://35.193.179.130/api/v1/namespaces/default/replicationcontrollers 201 Created in 65 milliseconds
Created kubia-v2
I0520 11:01:34.213630 28918 round_trippers.go:

..........

# Deployments - First kdel rc --all

k create -f kubia-deployment-v1.yaml -n default -v 6 --record

I0520 11:12:34.178949 7710 loader.go:375] Config loaded from file: /home/jeremy/.kube/config
I0520 11:12:34.336549 7710 round_trippers.go:443] GET https://35.193.179.130/openapi/v2?timeout=32s 200 OK in 157 milliseconds
I0520 11:12:34.592559 7710 round_trippers.go:443] POST https://35.193.179.130/apis/apps/v1beta1/namespaces/default/deployments 201 Created in 74 milliseconds
deployment.apps/kubia created

<!--
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubia
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kubia
  template:
    metadata:
      name: kubia
      labels:
        app: kubia
    spec:
      containers:
      - image: luksa/kubia:v1
        name: nodejs
 -->

k rollout status deployment kubia
deployment "kubia" successfully rolled out
~

kg po
NAME READY STATUS RESTARTS AGE
kubia-5dfcbbfcff-c2v6t 1/1 Running 0 85s
kubia-5dfcbbfcff-hrbxt 1/1 Running 0 85s
kubia-5dfcbbfcff-kdcdw 1/1 Running 0 85s
~

kg rs
NAME DESIRED CURRENT READY AGE
kubia-5dfcbbfcff 3 3 3 100s
~

kg svc
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
kubernetes ClusterIP 10.51.240.1 <none> 443/TCP 4m1s
kubia LoadBalancer 10.51.249.189 35.192.177.56 80:30951/TCP 79s
~

while true; do curl http://35.192.177.56; done  
This is v1 running in pod kubia-5dfcbbfcff-kdcdw
This is v1 running in pod kubia-5dfcbbfcff-hrbxt
This is v1 running in pod kubia-5dfcbbfcff-hrbxt
This is v1 running in pod kubia-5dfcbbfcff-c2v6t
This is v1 running in pod kubia-5dfcb

k patch deployment kubia -p '{"spec": {"minReadySeconds": 10}}'
deployment.extensions/kubia patched
~  
❯

k set image deployment kubia nodejs=luksa/kubia:v2
deployment.extensions/kubia image updated
~  
❯

kg po
NAME READY STATUS RESTARTS AGE
kubia-5dfcbbfcff-c2v6t 1/1 Terminating 0 7m28s
kubia-5dfcbbfcff-hrbxt 1/1 Running 0 7m28s
kubia-5dfcbbfcff-kdcdw 1/1 Running 0 7m28s
kubia-7c699f58dd-rp8xd 1/1 Running 0 18s
kubia-7c699f58dd-spf4m 1/1 Running 0 6s

This is v2 running in pod kubia-7c699f58dd-spf4m
This is v2 running in pod kubia-7c699f58dd-spf4m
This is v2 running in pod kubia-7c699f58dd-spf4m
This is v1 running in pod kubia-5dfcbbfcff-kdcdw
This is v2 running in pod kubia-7c699f58dd-tfjsr
This is v2 running in pod kubia-7c699f58dd-tfjsr
This is v1 running in pod kubia-5dfcbbfcff-kdcdw
This is v1 running in pod kubia-5dfcbbfcff-kdcdw
This is v2 running in pod kubia-7c699f58dd-rp8xd
This is v2 running in pod kubia-7c699f58dd-tfjsr
This is v2 running in pod kubia-7c699f58dd-rp8xd
This is v2 running in pod kubia-7c699f58dd-spf4m
This is v1 running in pod kubia-5dfcbbfcff-kdcdw
This is v1 running in pod kubia-5dfcbbfcff-kdcdw
This is v1 running in pod kubia-5dfcbbfcff-kdcdw
This is v2 running in pod kubia-7c699f58dd-rp8xd
This is v2 running in pod kubia-7c699f58dd-rp8xd
This is v1 running in pod kubia-5dfcbbfcff-kdcdw
This is v1 running in pod kubia-5dfcbbfcff-kdcdw
This is v2 running in pod kubia-7c699f58dd-rp8xd

kg rs
NAME DESIRED CURRENT READY AGE
kubia-5dfcbbfcff 0 0 0 8m21s
kubia-7c699f58dd 3 3 3 71s
~

# Rollback a deployment

k set image deployment kubia nodejs=luksa/kubia:v3
deployment.extensions/kubia image updated
~  
❯

k rollout status deployment kubia
deployment "kubia" successfully rolled out
~

kg po
NAME READY STATUS RESTARTS AGE
kubia-5c98f77977-n6sjc 1/1 Running 0 7s
kubia-5c98f77977-pkfjd 1/1 Running 0 19s
kubia-7c699f58dd-rp8xd 1/1 Running 0 2m44s
kubia-7c699f58dd-spf4m 1/1 Running 0 2m32s
kubia-7c699f58dd-tfjsr 1/1 Terminating 0 2m20s
~/DevStudy/yaml_files/configmap-files/ssl master ?4 ○ jaykube
❯ kg po
NAME READY STATUS RESTARTS AGE
kubia-5c98f77977-n6sjc 1/1 Running 0 16s
kubia-5c98f77977-pkfjd 1/1 Running 0 28s
kubia-5c98f77977-tt99f 1/1 Running 0 3s
kubia-7c699f58dd-rp8xd 1/1 Running 0 2m53s
kubia-7c699f58dd-spf4m 1/1 Terminating 0 2m41s
kubia-7c699f58dd-tfjsr 1/1 Terminating 0 2m29s
~/DevStudy/yaml_files/configmap-files/ssl master ?4 ○ jaykube
❯ kg po
NAME READY STATUS RESTARTS AGE
kubia-5c98f77977-n6sjc 1/1 Running 0 18s
kubia-5c98f77977-pkfjd 1/1 Running 0 30s
kubia-5c98f77977-tt99f 1/1 Running 0 5s
kubia-7c699f58dd-rp8xd 1/1 Running 0 2m55s
kubia-7c699f58dd-spf4m 1/1 Terminating 0 2m43s
kubia-7c699f58dd-tfjsr 1/1 Terminating 0 2m31s

Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
This is v2 running in pod kubia-7c699f58dd-rp8xd
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
This is v2 running in pod kubia-7c699f58dd-rp8xd
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
This is v2 running in pod kubia-7c699f5

k rollout history deployment kubia
deployment.extensions/kubia
REVISION CHANGE-CAUSE
1 kubectl create --filename=kubia-deployment-v1.yaml --namespace=default --v=6 --record=true
2 kubectl create --filename=kubia-deployment-v1.yaml --namespace=default --v=6 --record=true
3 kubectl create --filename=kubia-deployment-v1.yaml --namespace=default --v=6 --record=true

k rollout undo deployment kubia --to-revision=1
deployment.extensions/kubia rolled back
~

                                                                         ○ jaykube

❯ kg po
NAME READY STATUS RESTARTS AGE
kubia-5c98f77977-n6sjc 1/1 Terminating 0 3m12s
kubia-5c98f77977-pkfjd 1/1 Running 0 3m24s
kubia-5c98f77977-tt99f 1/1 Terminating 0 2m59s
kubia-5dfcbbfcff-4czwf 1/1 Running 0 11s
kubia-5dfcbbfcff-9txtn 1/1 Running 0 23s
kubia-5dfcbbfcff-m8zc4 0/1 ContainerCreating 0 0s
~/DevStudy/yaml_files/configmap-files/ssl master ?4 ○ jaykube
❯ kg po
NAME READY STATUS RESTARTS AGE
kubia-5c98f77977-n6sjc 1/1 Terminating 0 3m13s
kubia-5c98f77977-pkfjd 1/1 Running 0 3m25s
kubia-5c98f77977-tt99f 1/1 Terminating 0 3m
kubia-5dfcbbfcff-4czwf 1/1 Running 0 12s
kubia-5dfcbbfcff-9txtn 1/1 Running 0 24s
kubia-5dfcbbfcff-m8zc4 0/1 ContainerCreating 0 1s
~/DevStudy/yaml_files/configmap-files/ssl master ?4 ○ jaykube
❯ kg po
NAME READY STATUS RESTARTS AGE
kubia-5c98f77977-n6sjc 1/1 Terminating 0 3m16s
kubia-5c98f77977-pkfjd 1/1 Running 0 3m28s
kubia-5c98f77977-tt99f 1/1 Terminating 0 3m3s
kubia-5dfcbbfcff-4czwf 1/1 Running 0 15s
kubia-5dfcbbfcff-9txtn 1/1 Running 0 27s
kubia-5dfcbbfcff-m8zc4 1/1 Running 0 4s

e internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
This is v1 running in pod kubia-5dfcbbfcff-9txtn
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
This is v1 running in pod kubia-5dfcbbfcff-9txtn
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-n6sjc
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
Some internal error has occurred! This is pod kubia-5c98f77977-tt99f
This is v1 running in pod kubia-5dfcbbfcff-9txtn
Some internal error has occurred! This is pod kubia-5c98f77977-pkfjd
This is v1 running in pod kubia-5dfcbbfcff-9txtn
Some internal error has oc

This is v1 running in pod kubia-5dfcbbfcff-m8zc4
This is v1 running in pod kubia-5dfcbbfcff-4czwf
This is v1 running in pod kubia-5dfcbbfcff-4czwf
This is v1 running in pod kubia-5dfcbbfcff-4czwf

kg po
NAME READY STATUS RESTARTS AGE
kubia-5dfcbbfcff-4czwf 1/1 Running 0 72s
kubia-5dfcbbfcff-9txtn 1/1 Running 0 84s
kubia-5dfcbbfcff-m8zc4 1/1 Running 0 61s

k set image deployment kubia nodejs=luksa/kubia:v4
deployment.extensions/kubia image updated
~ ○ jaykube
❯
k rollout pause deployment kubia

deployment.extensions/kubia paused
~

kg po
NAME READY STATUS RESTARTS AGE
kubia-5dfcbbfcff-4czwf 1/1 Running 0 3m2s
kubia-5dfcbbfcff-9txtn 1/1 Running 0 3m14s
kubia-5dfcbbfcff-m8zc4 1/1 Running 0 2m51s
kubia-6976f5b8f8-jd866 1/1 Running 0 22s

k rollout resume deployment kubia
deployment.extensions/kubia resumed
~

kg po
NAME READY STATUS RESTARTS AGE
kubia-5dfcbbfcff-4czwf 1/1 Running 0 3m37s
kubia-5dfcbbfcff-9txtn 1/1 Running 0 3m49s
kubia-5dfcbbfcff-m8zc4 1/1 Terminating 0 3m26s
kubia-6976f5b8f8-jd866 1/1 Running 0 57s
kubia-6976f5b8f8-xhvtl 0/1 ContainerCreating 0 2s

This is v4 running in pod kubia-6976f5b8f8-xhvtl
This is v4 running in pod kubia-6976f5b8f8-8lwnl
This is v4 running in pod kubia-6976f5b8f8-xhvtl
This is v4 running in pod kubia-6976f5b8f8-xhvtl
This is v4 running in pod kubia-6976f5b8f8-jd866
This is v4 running in pod kubia-6976f5b8f8-8lwnl
This is v4 running in pod kubia-6976f5b8f8-8lwnl
This is v4 running in pod kubia-6976f5b8f8-xhvtl
This is v4 running in pod kubia-6976f5b8f8-jd866
This is v4 running in pod kubia-6976f5b8f8-jd866
This is v4 running in pod kubia-6976f5b8f8-xhvtl
This is v4 running in pod kubia-6976f5b8f8-8lwnl
This is v4 running in pod kubia-6976f5b8f8-xhvtl
This is v4 running in pod kubia-6976f5b8f8-8lwnl
This is v1 running in pod kubia-5dfcbbfcff-9txtn
This is v4 running in pod kubia-6976f5b8f8-xhvtl

# Readiness probe to prevent a bad Version Rollout

k apply -f kubia-deployment-v3-with-readinesscheck.yaml
deployment.apps/kubia configured

<!--
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: kubia
spec:
  replicas: 3
  minReadySeconds: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      name: kubia
      labels:
        app: kubia
    spec:
      containers:
      - image: luksa/kubia:v3
        name: nodejs
        readinessProbe:
          periodSeconds: 1
          httpGet:
            path: /
            port: 8080 -->

❯ kg po
NAME READY STATUS RESTARTS AGE
kubia-6976f5b8f8-8lwnl 1/1 Running 0 6m38s
kubia-6976f5b8f8-jd866 1/1 Running 0 7m46s
kubia-6976f5b8f8-xhvtl 1/1 Running 0 6m51s
kubia-84b59979b9-qkmqh 0/1 Running 0 13s
~ ○ jaykube
❯ k rollout status deployment kubia
Waiting for deployment "kubia" rollout to finish: 1 out of 3 new replicas have been updated...

kd deploy kubia
Name: kubia
Namespace: default
CreationTimestamp: Wed, 20 May 2020 11:12:34 -0600
Labels: app=kubia
Annotations: deployment.kubernetes.io/revision: 6
kubectl.kubernetes.io/last-applied-configuration:
{"apiVersion":"apps/v1beta1","kind":"Deployment","metadata":{"annotations":{},"name":"kubia","namespace":"default"},"spec":{"minReadySecon...
kubernetes.io/change-cause: kubectl create --filename=kubia-deployment-v1.yaml --namespace=default --v=6 --record=true
Selector: app=kubia
Replicas: 3 desired | 1 updated | 4 total | 3 available | 1 unavailable
StrategyType: RollingUpdate
MinReadySeconds: 10
RollingUpdateStrategy: 0 max unavailable, 1 max surge
Pod Template:
Labels: app=kubia
Containers:
nodejs:
Image: luksa/kubia:v3
Port: <none>
Host Port: <none>
Readiness: http-get http://:8080/ delay=0s timeout=1s period=1s #success=1 #failure=3
Environment: <none>
Mounts: <none>
Volumes: <none>
Conditions:
Type Status Reason

---

Available True MinimumReplicasAvailable
Progressing True ReplicaSetUpdated
OldReplicaSets: kubia-6976f5b8f8 (3/3 replicas created)
NewReplicaSet: kubia-84b59979b9 (1/1 replicas created)
Events:
Type Reason Age From Message

---

Normal ScalingReplicaSet 19m deployment-controller Scaled up replica set kubia-7c699f58dd to 1
Normal ScalingReplicaSet 19m deployment-controller Scaled down replica set kubia-5dfcbbfcff to 2
Normal ScalingReplicaSet 19m deployment-controller Scaled up replica set kubia-7c699f58dd to 2
Normal ScalingReplicaSet 18m deployment-controller Scaled up replica set kubia-7c699f58dd to 3
Normal ScalingReplicaSet 18m deployment-controller Scaled down replica set kubia-5dfcbbfcff to 0
Normal ScalingReplicaSet 16m deployment-controller Scaled up replica set kubia-5c98f77977 to 1
Normal ScalingReplicaSet 16m deployment-controller Scaled down replica set kubia-7c699f58dd to 2
Normal ScalingReplicaSet 13m (x2 over 26m) deployment-controller Scaled up replica set kubia-5dfcbbfcff to 3
Normal ScalingReplicaSet 9m49s (x2 over 18m) deployment-controller Scaled down replica set kubia-5dfcbbfcff to 1
Normal ScalingReplicaSet 3m24s (x15 over 16m) deployment-controller (combined from similar events): Scaled up replica set kubia-84b59979b9 to 1

k rollout undo deployment kubia
deployment.extensions/kubia rolled back

k rollout status deployment kubia
Waiting for deployment "kubia" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment spec update to be observed...
Waiting for deployment spec update to be observed...
Waiting for deployment "kubia" rollout to finish: 1 old replicas are pending termination...
deployment "kubia" successfully rolled out
~

# Stateful Sets

## Now we need to start the headless svc to provide network identity

k apply -f kubia-svc-headless.yaml

❯ kg svc | grep -Ei head
kubia-headless ClusterIP None <none> 80/TCP 78s

## Create the Stateful Set

k create -f kubia-statefulset.yaml

<!--
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kubia
spec:
  selector:
    matchLabels:
      app: kubia
  serviceName: kubia
  replicas: 2
  template:
    metadata:
      labels:
        app: kubia
    spec:
      containers:
      - name: kubia
        image: luksa/kubia-pet
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
        - name: kubia
          mountPath: /var/data

  volumeClaimTemplates:
  - metadata:
      name: kubia
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Mi
           -->

## Scale it up and down with patch and edit

k edit statefulsets kubia

k patch statefulsets kubia -p '{"spec":{"replicas":20}}' just to see what happens, otherwise scale to 10

k apply -f kubia-statefulset.yaml -- sets it back to 2

## if more compute is needed

gcloud container clusters resize kubia --node-pool default-pool --num-nodes 5

kubectl proxy

# ❯ curl 127.0.0.1:8001/api/v1/namespaces/default/pods/kubia-0/proxy/

You've hit kubia-0
Data stored on this pod: No data posted yet
~/DevStudy/yaml_files master !1 ≡ Node system

# ❯ curl -X POST -d "Hey there! This greeting was submitted to kubia-0." 127.0.0.1:8001/api/v1/namespaces/default/pods/kubia-0/proxy/

Data stored on pod kubia-0
~/DevStudy/yaml_files master !1 ≡ Node system

# ❯ curl 127.0.0.1:8001/api/v1/namespaces/default/pods/kubia-0/proxy/

You've hit kubia-0
Data stored on this pod: Hey there! This greeting was submitted to kubia-0.

## Check the other pod

curl 127.0.0.1:8001/api/v1/namespaces/default/pods/kubia-1/proxy/
You've hit kubia-1
Data stored on this pod: No data posted yet

## Delete the kubia-0 pod to test if pv pvc is reattached

❯ kdel po kubia-0
pod "kubia-0" deleted

# ❯ curl 127.0.0.1:8001/api/v1/namespaces/default/pods/kubia-0/proxy/

You've hit kubia-0
Data stored on this pod: Hey there! This greeting was submitted to kubia-0.

k create -f kubia-service-public.yaml
service/kubia-public created
~/DevStudy/yaml_files master !2 ?1 ≡ Node system ○ kubia
❯ kg svc
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
kubernetes ClusterIP 10.55.240.1 <none> 443/TCP 31m
kubia-public ClusterIP 10.55.249.16 <none> 80/TCP 2s

<!-- apiVersion: v1
kind: Service
metadata:
  name: kubia-public
spec:
  selector:
    app: kubia
  ports:
  - port: 80
    targetPort: 8080 -->

# ❯ curl 127.0.0.1:8001/api/v1/namespaces/default/services/kubia-public/proxy/

You've hit kubia-0
Data stored on this pod: Hey there! This greeting was submitted to kubia-0.

k run -it srvlookup --image=tutum/dnsutils --rm --restart=Never -- dig SRV kubia.default.svc.cluster.local

# ❯ k run -it srvlookup --image=tutum/dnsutils --rm --restart=Never -- dig SRV kubia.default.svc.cluster.local

; <<>> DiG 9.9.5-3ubuntu0.2-Ubuntu <<>> SRV kubia.default.svc.cluster.local
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 54812
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;kubia.default.svc.cluster.local. IN SRV

;; AUTHORITY SECTION:
cluster.local. 60 IN SOA ns.dns.cluster.local. hostmaster.cluster.local. 1611799200 28800 7200 604800 60

;; Query time: 3 msec
;; SERVER: 10.55.240.10#53(10.55.240.10)
;; WHEN: Thu Jan 28 02:47:32 UTC 2021
;; MSG SIZE rcvd: 142

pod "srvlookup" deleted

❯ k edit statefulset kubia

## add replicas: 3 and image: kubia-pet-peers

statefulset.apps/kubia edited
~/DevStudy/yaml_files master !2 ?1  
 41s ≡ Node system ○ kubia
❯ kdel po kubia-0 kubia-1
pod "kubia-0" deleted
pod "kubia-1" deleted

❯ curl -X POST -d "The sun is shining" 127.0.0.1:8001/api/v1/namespaces/default/services/kubia-public/proxy/
Data stored on pod kubia-1

~/DevStudy/yaml_files master !2 ?1 ≡ Node system
❯ curl -X POST -d "The weather is sweet" 127.0.0.1:8001/api/v1/namespaces/default/services/kubia-public/proxy/
Data stored on pod kubia-0

❯ gcloud compute ssh gke-kubia-default-pool-7d97e47e-wzhp
Warning: Permanently added 'compute.2459818272875324354' (ED25519) to the list of known hosts.

jeremy@gke-kubia-default-pool-7d97e47e-wzhp ~ $
jeremy@gke-kubia-default-pool-7d97e47e-wzhp ~ $ sudo ifconfig eth0 down

kdel po kubia-1 --force --grace-period 0
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
pod "kubia-1" force deleted

kg po
NAME READY STATUS RESTARTS AGE
kubia-0 1/1 Running 0 18m
kubia-1 0/1 ContainerCreating 0 72s

gcloud compute instances reset gke-kubia-default-pool-7d97e47e-wzhp
