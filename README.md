# Kubectl settings (cluster management)

## Enviroment

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

### Version/info

```bash
kubectl [command]
                    version 
                    clusster-info
                    get componentstatus                   ---> ComponentStatus is deprecated in v1.19+
```

### Viewing

```bash
kubectl [command]
                    get node
                    get pods
                    logs (-f -> stream) <NAME>
```

### Inside

```bash
kubectl [command]
                    describe pod/nodes                    ---> all
                    describe pod/nodes <NAME> 
                    port-forward <NAME> <LOCAL_PORT>:<CONTAINER_PORT>
                    port-forward <NAME> :<CONTAINER_PORT> ---> add random local port

#Fast IP pods
kubectl get pod -o jsonpath='{.items[*].status.podIP}'
```

### Manipulation

```sh
kubectl run <NAME> --image=<ISO:TAG> --port=<CONTAINER_PORT>
kubectl delete pods <NAME>
kubectl exec -it <NAME> sh (~/bin/bash)
```

### Simple manifest (pod)

```yml
apiVersion: v1
kind: Pod
metadata:
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

### Demployment

```sh
#Show delpoy
kubectl get deploy

#Create deploy
kubectl create deployment <NAME> --image <ISO:TAG>

#Detail information
kubectl describe deployments <NAME>

#Scale (replicas)
kubectl scale deployment <NAME> --replicas <NUMBER>

#Stop all replicas
kubectl scale deployment --replicas=0 --all

#Show replica set
kubectl get rs

#Horizontal scale
kuberctl autoscale deployment <NAME> --min=<NUMBER> --max=<NUMBER> --cpu-percent=<NUMBER>

#Show horizontal set
kubectl get hpa

#History / status demploy
kubectl rollout history deployment/<NAME>

kubectl rollout status deployment/<NAME>

#Change version
#CONTAINER_NAME ---> kubectl describe deployment <NAME>
kubectl set image deployment/<NAME> <CONTAINER_NAME>=<amizory/k8s-practice:latest> --record

#Change-cause
kubectl annotate deployment <NAME> kubernetes.io/change-cause="<TEXT>"

#Back version (default = -1; base save 3 versions)
kubectl rollout undo deployment/<NAME>

kubectl rollout undo deployment/<NAME> --to-revision=<NUMBER>

#Update version
kubectl rollout restart deployment/<NAME>

#Delete all pods/deployments/hpa
kubectl delete deploy --all

kubectl delete hpa --all

kubectl delete deployment <NAME_FILE.yml>

kubectl scale deployment --replicas=0 --all
```

### Services

```sh
kubectl expose deployment <DEPLOY_NAME> 
                --type 
                       ClusterIP     ---> ip inside k8s cluster 
                       NodePort      ---> port worker nodes
                       ExternalName  ---> dns name
                       LoadBalancer  ---> sum ClusterIP/NodePort "cloud clusters"
                --port <PORT>

#Show service 
kubectl get svc (allias services)

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
