# Table of Contents

* [Kubectl Settings (Cluster Management)](#k8s-settings)
* [Approval Cycle (Const Process)](#approval-cycle)
* [Version/info](#version)
* [Viewing](#viewing)
* [Inside](#inside)
* [Manipulation](#manipulation)
* [Namespace](#namespace)
* [Resource Quotas and Limit Ranges](#resource-quotas)
* [Deployment](#deployment)
* [Services](#services)
* [Busybox](#busybox)
* [Ingress Rules](#ingress-rules)
* [Context](#context)
* [Security Capabilities](#security-capabilities)
* [Helm (package manager)](#helm)
* [Volumes](#volume)

## <a id="k8s-settings">Kubectl settings (cluster management)</a>

### k8s-master

| Syntax | Description |
| ----------- | ----------- |
| api-server | -> external server that handles api requests |
| control-manager | -> responsible for deployment |
| etcd | -> database that stores all information about the cluster, nodes, and status |
| scheduler | -> where the pods will be launched (planning)|
| cloud-controller | -> interaction about the cloud (load balancer, disk volumes)|

### k8s-worker

| Syntax | Description |
| ----------- | ----------- |
| kubelet | -> monitoring the execution of a task on a node |
| proxy | -> network connectivity and load balancer |
| cadvisior | -> information scheduler about the status of the cluster and running processes |
| pod | -> container or containers|

## <a id="approval-cycle">Approval Cycle (const process)</a>

| Unit | Purpose |
| ----------- | ----------- |
| container | -> app |
| pod | -> object (module) |
| scheduler | -> planning new pod |
| replicaset | -> management pod (modify) |
| deploy | -> control replicas, exe pod-env |
| service | -> web-proxy/loadbalancer |
| etcd | -> all info (cluster/deploy/resources/logs) |

### <a id="version">Version/info</a>

```bash
kubectl [command]
                    version 
                    cluster-info
                    delete -f <NAMEFILE>.yml
                    edit <TYPE> <NAME>      ---> rework in txt file
                    diff -f <NAMEFILE>.yml
                    get componentstatus     ---> ComponentStatus is deprecated in v1.19+
                    label <TYPE> <LABELS>=<NAME>
                    annotate <TYPE> <TEXT>=<TEXT>
                    
```

### <a id="viewing">Viewing</a>

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

### <a id="inside">Inside</a>

```bash
kubectl [command]   
                    describe pod<--->nodes                ---> all
                    describe pod<--->nodes <NAME> 
                    port-forward <NAME> <LOCAL_PORT>:<CONTAINER_PORT>
                    port-forward <NAME> :<CONTAINER_PORT> ---> add random local port

#Fast IP pods
kubectl get pod -o jsonpath='{.items[*].status.podIP}'
```

### <a id="manipulation">Manipulation</a>

```sh
kubectl run <NAME> --image=<ISO:TAG> --port=<CONTAINER_PORT> --> deploy --> pod-object
kubectl run <NAME> --image=<ISO:TAG> --dry-run=client -o yaml --> create manifest
kubectl delete pods <NAME>
kubectl delete all --selector <matchLabels-LABELS>=<NAME> (app=test)
kubectl attach <NAME>
kubectl exec -it <NAME> -- [COMMAND] 
kubectl exec -it <NAME> -c <NAMECONTAINER> -- sh (~/bin/bash) 
```

### <a id="namespace">Namespace</a>

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

### <a id="resource-quotas">Recourcequotas && LimitRange --> Namespace </a>

```sh
kubectl get resourcequotas -n <NAMESPACE>
kubectl describe resourcequotas <NAME-RSQ> -n <NAMESPACE>
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

### <a id="deployment">Deployment</a>

```sh
#Show deploy
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
kubectl autoscale deployment <NAME> --min=<NUMBER> --max=<NUMBER> --cpu-percent=<NUMBER>
kubectl get hpa

#History / status deploy
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

### <a id="services">Services</a>

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

### <a id="busybox">Busybox</a>

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

### <a id="ingress-rules">Ingress rules</a>

```sh
  ---> deploy + svc + scale (N times)

kubectl get ing (alias ingress)
kubectl describe ing (NAME_INGRESS)

  ---> if use localhost 

  kubectl run -i --rm --tty curl-pod --image=curlimages/curl --restart=Never -- sleep infinityleep infinity

  kubectl exec -it curl-pod -- curl -v http://<NAME_SVC>.<NAMESPACE>.svc.cluster.local
```

### <a id="context">Context (cluster + namespace + user)</a>

```sh
kubectl config get-contexts                                                            ---> info
kubectl config current-context
kubectl config use-context <NAME>                                                      ---> swap
kubectl config set-context <NAME> --cluster=<NAME_CLUSTER> --namespace=<NAME_NAMESPACE> ---> create

---> kubectx 
kubectx -
kubectx <NAME_CONTEXT>
kubectx -> list

---> kubens
kubens -
kubens <NAME_NAMESPACE>
kubens -> list
```

### <a id="security-capabilities">Security capabilities</a>

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
| NET_RAW | -> Use RAW (IP, ICMP) and PACKET (app -> network) sockets; bind to any address for transparent proxying |
| SETGID | -> Make arbitrary manipulations of process GIDs and supplementary GID list |
| SETUID | -> Make arbitrary manipulations of process UIDs |
| SETFCAP | -> Set file capabilities |
| SETPCAP | -> Allows a process to manipulate the allowed set of capabilities of another process |
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

### <a id="helm">Helm (package manager)</a>

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

### <a id="volume">Volumes</a>

```sh
  1 - emptyDir: {}  ---> allocates space on the node, share space between containers. If there are 2 pods, then the emptyDir inside each is different.
  
  kubectl exec -it <POD> -n <NAMESPACE> -- df -h

  2 - hostPath: 
        path: <exist-path-on-host> --> not recommended

  3 - Persistent Volume (PV) & Persistent Volume Claim (PVC)
    
    ---> hostPath:        
          path: /mnt/data
          type: Directory, DirectoryOrCreate, FileOrCreate, File, ‌""

      For single node testing only
      WILL NOT WORK in a multi-node cluster

    ---> local:
          path: /run/desktop/mnt/host/c/test
          
    ---> other: csi, iscsi, fc, nfs 
  
  4 - StorageClass ---> need provisioner (~NFS, AWS EBS)

      local -> don't work -> provisioner: kubernetes.io/no-provisioner 
      
```
