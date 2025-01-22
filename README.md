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

```txt
Процесс создания

1 - Парсинг файла: kubectl парсит файл deployment.yaml и извлекает из него информацию о 
    ресурсах Kubernetes, которые необходимо создать или обновить.
2 - Отправка запроса на API-server: kubectl отправляет запрос на создание или обновление
    ресурсов в Kubernetes API-server, который работает на master node.
3 - Валидация и авторизация: Kubernetes API-server проверяет валидность запроса и авторизует 
    его, используя информацию о пользователе и ролях.
4 - Создание или обновление ресурсов: Если запрос валиден и авторизован, Kubernetes API-server
    создает или обновляет ресурсы в соответствии с информацией из файла deployment.yaml.
5 - Обновление etcd: Kubernetes API-server обновляет данные в etcd, который является
    распределенным хранилищем ключ-значение для Kubernetes и работает на master node.
6 - Уведомление контроллера: Kubernetes API-server отправляет уведомление контроллеру (например,
    Deployment контроллеру) о создании или обновлении ресурсов.
7 - Обновление контроллера: Контроллер получает уведомление и начинает обновлять соответствующие
    ресурсы (например, поды).
8 - Распределение задач на worker nodes: Контроллер распределяет задачи на worker nodes, 
    которые выполняют фактическую работу по созданию или обновлению ресурсов.
9 - Выполнение задач на worker nodes: Worker nodes выполняют задачи, которые им были назначены
    контроллером, и создают или обновляют ресурсы в соответствии с информацией из файла 
    deployment.yaml
```

```txt
  Reconciliation loop - это процесс, который происходит в Kubernetes, когда контроллеры
(например, Deployment контроллер) постоянно проверяют текущее состояние ресурсов и сравнивают
его с желаемым состоянием, указанным в конфигурации.

  Если текущее состояние ресурсов не соответствует желаемому состоянию, контроллеры выполняют
действия для приведения ресурсов в соответствие с желаемым состоянием. Этот процесс повторяется
постоянно, чтобы обеспечить, что ресурсы всегда находятся в желаемом состоянии.

Reconciliation loop состоит из следующих шагов:
1 - Чтение текущего состояния: Контроллеры читают текущее состояние ресурсов.
2 - Сравнение с желаемым состоянием: Контроллеры сравнивают текущее состояние ресурсов с
    желаемым состоянием, указанным в конфигурации.
3 - Определение необходимости действий: Если текущее состояние ресурсов не соответствует
    желаемому состоянию, контроллеры определяют необходимость выполнения действий для
    приведения ресурсов в соответствие с желаемым состоянием.
4 - Выполнение действий: Контроллеры выполняют действия для приведения ресурсов в соответствие
    с желаемым состоянием.
5 - Повторение цикла: Контроллеры повторяют цикл, чтобы постоянно проверять текущее состояние
    ресурсов и сравнивать его с желаемым состоянием.

Controller Manager использует следующий способ для реализации reconciliation loop:

- Watch API: Controller Manager использует Watch API для наблюдения за ресурсами и получает
  уведомления о изменениях в ресурсах.
- List-Watch: Controller Manager использует List-Watch для получения списка ресурсов и
  наблюдения за изменениями в ресурсах.
- Event-driven: Controller Manager использует event-driven подход для обработки событий и
  выполнения действий в ответ на изменения в ресурсах.
```

```txt
  Алгоритм Raft - это алгоритм консенсуса, разработанный для управления распределенными 
системами. Он позволяет группе машин (называемых узлами) согласовывать свои действия и 
достигать консенсуса, даже в случае сбоя некоторых узлов.
  
  Количество мастер-нод в кластере etcd, работающем по алгоритму Raft, связано с тем, что для 
достижения консенсуса требуется большинство голосов. Чтобы обеспечить работоспособность
кластера, необходимо иметь нечетное количество мастер-нод, чтобы в случае разделения кластера
на две части, одна из них имела большинство голосов. Обычно рекомендуется использовать 3 или 5
мастер-нод в кластере etcd, чтобы обеспечить высокую доступность и устойчивость к сбоям.
Нечетное количество мастер-нод необходимо для того, чтобы избежать ситуации, когда кластер
разделен на две равные части, и ни одна из них не имеет большинства голосов.

  Если бы количество мастер-нод было четным, например 4, то в случае разделения кластера на
две части, каждая часть бы имела по 2 мастер-ноды. В этом случае ни одна из частей не имела бы
большинства голосов, и кластер не смог бы принять решения. Нечетное количество мастер-нод
гарантирует, что в случае разделения кластера, одна из частей будет иметь большинство голосов,
и кластер сможет продолжать работать.

  Например, если количество мастер-нод равно 3, то в случае разделения кластера на две части,
одна часть будет иметь 2 мастер-ноды, а другая - В этом случае часть с 2 мастер-нодами будет
иметь большинство голосов и сможет продолжать работать. В контексте etcd, алгоритм Raft
используется для управления распределенным ключ-значение хранилищем. Etcd - это распределенное
хранилище ключ-значение, которое позволяет хранить и получать данные в распределенной системе.
```

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
kubectl get pods -o jsonpath='{.items[*].status.podIP}'

#Pods (in Node)
kubectl get pods --field-selector spec.nodeName=... -A -o wide
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
kubectl autoscale deployment <NAME> --min=<NUMBER>
                                    --max=<NUMBER> 
                                    --cpu-percent=<NUMBER>
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
kubectl config get-contexts                                    ---> info
kubectl config current-context
kubectl config use-context <NAME>                              ---> swap
kubectl config set-context <NAME> --cluster=<NAME_CLUSTER> 
                                  --namespace=<NAME_NAMESPACE> ---> create

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

helm install my-release my-chart --dry-run --output-dir ./manifests

helm upgrade <NAME> ./<PATH> --set replicaCount=2
helm template my-release my-chart
helm template my-release my-chart --output-dir ./manifests

helm list -A
helm dependency ls -A
helm rollback my-release 1
helm history my-release
```

### <a id="volume">Volumes</a>

```sh
  1 - emptyDir: {}  ---> allocates space on the node, share space between containers. If there 
  are 2 pods, then the emptyDir inside each is different.
  
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
