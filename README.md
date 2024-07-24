# Table of Contents

* (Kubectl Settings (Cluster Management))(#k8s-settings)
* (Approval Cycle (Const Process))(#approval-cycle)
* (Version/info)(#version)
* (Viewing)(#viewing)
* (Inside)(#inside)
* (Manipulation)(#manipulation)
* (Namespace)(#namespace)
* (Resource Quotas and Limit Ranges)(#resource-quotas)
* (Deployment)(#deployment)
* (Services)(#services)
* (Busybox)(#busybox)
* (Ingress Rules)(#ingress-rules)
* (Context)(#context)
* (Security Capabilities)(#security-capabilities)
* (Helm (package manager))(#helm)

## Kubectl settings (cluster management) {#k8s-settings}

### k8s-master

| Syntax | Description |
| ----------- | ----------- |
| apiserver | -> external server that handles api requests |
| control-manager | -> responsible for deployment |
| etcd | -> database that stores all information about the cluster, nodes, and status |
| scheduler | -> where the pods will be launched (planning)|
| cloud-contorller | -> interaction about the cloud (load balancer, disk volumes)|

### k8s-worker

| Syntax | Description |
| ----------- | ----------- |
| kubelet | -> monitoring the execution of a task on a node |
| proxy | -> network connectivity and load balancer |
| cadvisior | -> information scheduler about the status of the cluster and running processes |
| pod | -> container or containers|

## Approval Cycle (const process) {#approval-cycle}

| Unit | Purpose |
| ----------- | ----------- |
| container | -> app |
| pod | -> object (module) |
| scheduler | -> planning new pod |
| replicaset | -> management pod (modife) |
| deploy | -> control replicas, exe pod-env |
| service | -> web-proxy/loadbalancer |
| etcd | -> all info (cluster/depoloy/resources/logs) |

### Version/info {#version}

```bash
kubectl [command]
                    version 
                    clusster-info
                    delete -f <NAMEFILE>.yml
                    edit <TYPE> <NAME>      ---> rework in txt file
                    diff -f <NAMEFILE>.yml
                    get componentstatus     ---> ComponentStatus is deprecated in v1.19+
                    label <TYPE> <LABELS>=<NAME>
                    annotate <TYPE> <TEXT>=<TEXT>
                    
```

### Viewing {#viewing}

```bash
kubectl [command]
                        namespace 
                        node
                        pods -o wide/yaml/json
                  get   pods --selector (-l) <matchLabels-LABELS>=<NAME> app=test
                        pods --namespace (-n) <TEXT> --show-labels
                        pods -A
                        all
                     
                  logs (-f -> stream, --tail=<NUMBER> -> last process, -c -> --container <NAME>) <NAME>
                  get pods --watch (-w -> stream)
```

### Inside {#inside}

```bash
kubectl [command]   
                    describe pod<--->nodes                ---> all
                    describe pod<--->nodes <NAME> 
                    port-forward <NAME> <LOCAL_PORT>:<CONTAINER_PORT>
                    port-forward <NAME> :<CONTAINER_PORT> ---> add random local port

#Fast IP pods
kubectl get pod -o jsonpath='{.items[*].status.podIP}'
```

### Manipulation {#manipulation}

```sh
kubectl run <NAME> --image=<ISO:TAG> --port=<CONTAINER_PORT> --> deploy --> pod-object
kubectl run <NAME> --image=<ISO:TAG> --dry-run=client -o yaml --> create manifest
kubectl delete pods <NAME>
kubectl delete all --selector <matchLabels-LABELS>=<NAME> (app=test)
kubectl attach <NAME>
kubectl exec -it <NAME> sh (~/bin/bash)
kubectl exec -it <NAME> -c <NAMECONTAINER> sh 
```

### Namespace {#namespace}

```yml
apiVersion: v1
kind: Namespace
metadata:
  name: <NAMESPACE>
```

```sh
kubectl get namespace 
kubectl get pods --namespace=<NAMESPACE>
kubectl -n <NAMESPACE> get pod -o yaml
```

### Recourcequotas && LimitRange --> Namespace {#resource-quotas}

```sh
kubectl get recourcequotas -n <NAMESPACE>
kubectl describe resourcequota <NAME-RSQ> -n <NAMESPACE>
kubectl apply --namespace <NAMESPACE> -f RSQ.yml/LMTRNG.yml
```

### Simple manifest (pod)

```yml
apiVersion: v1
kind: Pod
metadata:
    namespace: my-namespace
    name: testapp
    label:
        author: Dmitry
spec:
    containers:
    - name: default-app
      image:
      ports:
        - containerPort: 666
```

### Demployment {#deployment}

```sh
#Show delpoy
kubectl get deploy (alias deployment)
kubectl get deploy -A
kubectl get deploy -n <NAMESPACE>

#Create deploy
kubectl create deployment <NAME> --image <ISO:TAG>
kubectl apply -f <NAME_DEPLOY>.yml -n <NAMESPACE>

#Detail information
kubectl describe deploy <NAME>

#Scale (replicas) / Show replica set
kubectl scale deployment <NAME> --replicas <NUMBER>
kubectl get rs

#Horizontal scale / Show horizontal set
kuberctl autoscale deployment <NAME> --min=<NUMBER> --max=<NUMBER> --cpu-percent=<NUMBER>
kubectl get hpa

#History / status demploy
kubectl rollout history deployment/<NAME>
kubectl rollout status deployment/<NAME>

#Change version
#CONTAINER_NAME ---> kubectl describe deployment <NAME>
kubectl set image deployment/<NAME> <CONTAINER_NAME>=amizory/k8s-practice:latest --record

#Change-cause
kubectl annotate deployment <NAME> kubernetes.io/change-cause="<TEXT>"

#Back version (default = -1; base save 3 versions)
kubectl rollout undo deployment/<NAME>

kubectl rollout undo deployment/<NAME> --to-revision=<NUMBER>

#Update version
kubectl rollout restart deployment/<NAME>

#Delete/stop all pods/deployments/hpa
kubectl delete deploy --all

kubectl delete hpa --all

kubectl delete deployment <NAME_FILE.yml>

kubectl scale deployment --replicas=0 --all
```

### Services {#services}

```sh
kubectl expose deployment <DEPLOY_NAME> 
                --type 
                       ClusterIP     ---> ip inside k8s cluster 
                       NodePort      ---> port worker nodes
                       ExternalName  ---> dns name
                       LoadBalancer  ---> sum ClusterIP/NodePort "cloud clusters"
                --port <PORT>

#Show service 
kubectl get svc -A
kubectl get svc (alias services)
kubectl get svc <SVC_NAME> -o yaml   ---> more info 

#Delete services
kubectl delete svc <SVC_NAME>

#Port-forward
kubectl port-forward svc/<SVC_NAME> <PORT>:<PORT_CONTAINER> &

#Execution
                            -- curl http://<SVC_NAME>:<PORT_CONTAINER>
kubectl exec -it <POD_NAME>     
                            -- curl http://<ClusterIP>:<PORT_CONTAINER>
```

### Busybox {#busybox}

```sh
kubectl run busybox --image=busybox:latest --rm -it --restart=Never --command
      nslookup <NAME> --->  test
                            Server:         10.X.X.X
                            Address:        10.X.X.X:53
                            Name:   test.default.svc.cluster.local
                            Address: 10.X.X.X
      wget -qO- http://test:80 ---> view content
      sh -> ash
alias krbb
```

### Ingress rules {#ingress-rules}

```sh
  ---> deploy + svc + scale (N times)

kubectl get ing (alias ingress)
kubectl decribe ing (NAME_INGRESS)

  ---> if use localhost 

  kubectl run -i --rm --tty curl-pod --image=curlimages/curl --restart=Never -- sleep infinityleep infinity

  kubectl exec -it curl-pod -- curl -v http://<NAME_SVC>.<NAMESPACE>.svc.cluster.local
```

### Context (cluster + namespace + user) {#context}

```sh
kubectl config get-contexts                                                            ---> info
kubectl config current-context
kubectl config use-context <NAME>                                                      ---> swap
kubectl config set-context <NAME> --cluser=<NAME_CLUSTER> --namespace=<NAME_NAMESPACE> ---> create

---> kubectx 
kubectx -
kubectx <NAME_CONTEXT>
kubectx -> list

---> kubens
kubens -
kubens <NAME_NAMESPACE>
kubens -> list
```

### Security capabilities {#security-capabilities}

```yml
apiVersion: v1
kind: Pod
metadata:
    namespace: 
    name: 
spec:
    containers:
    - name: 
      image:
      securityContext:
        drop: ["CHOWN", "NET_RAW", "SETFCAP"]
        #drop: ["all"]
        add: ["NET_ADMIT"] #capabilities which are not granted by default and may be added
      ports:
        - containerPort: 
```

| Capabilities | Definition |
| ----------- | ----------- |
| CHOWN | -> Make arbitrary changes to file UIDs and GIDs |
| DAC_OVERRIDE | -> Bypassing file read, write, and execute permission checks |
| FSETID | ->  Save SUID and SGID bits when changing files |
| FOWNER | ->  It is necessary to provide access to files for processes that are not the owners of the files |
| MKNOD | ->  Create special files using mknod(2) |
| NET_RAW | -> Use RAW (IP, ICMP) and PACKET (app -> network) sockets; bind to any address for transparent proxying. |
| SETGID | -> Make arbitrary manipulations of process GIDs and supplementary GID list |
| SETUID | -> Make arbitrary manipulations of process UIDs |
| SETFCAP | -> Set file capabilities |
| SETPCAP | -> Фllows a process to manipulate the allowed set of capabilities of another process |
| NET_BIND_SERVICE | -> Bind a socket to Internet domain privileged ports (port numbers less than 1024) |
| SYS_CHROOT | -> This feature allows a process to use the chroot(2) system call to change the root directory |
| KILL | -> Bypass permission checks for sending signals |
| AUDIT_WRITE | -> This feature allows the process to write entries to the kernel audit log |

```yml
spec:
  serviceAccountName: amizory        #definitive user
  #POD LEVEL
  #securityContext:                  #CONTAINER LEVEL
        #runAsUser: 1000                 
        #runAsNonRoot: false                  
        #allowPrivilegeEscalation: false 
  containers:
    - name: test
      image: amizory/k8s-practice:latest
      securityContext:                  #CONTAINER LEVEL
        runAsUser: 1000                 #run without root access
        runAsNonRoot: true              #cancel if app use root permission
        readOnlyRootFilesystem: true    #overwriting the file system
        allowPrivilegeEscalation: false #off privilege enhancement
```

### Helm (package manager) {#helm}

```sh
helm [command] 
              version
              package <PATH> ---> .tgz
              search hub <NAMECHART>
              search repo (example - 'bitnami')

helm install <NAME> ./<PATH> 
helm install <NAME> ./<PATH> -f some-values.yaml

helm upgrade <NAME> ./<PATH> --set replicaCount=2
```
