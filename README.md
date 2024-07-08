# Kubectl settings (cluster management)

## Basic command

### Version/info

```bash
kubectl [command]
                    version 
                    clusster-info
                    get componentstatus                                 ---> ComponentStatus is deprecated in v1.19+
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
                    describe pod/nodes                                  ---> all
                    describe pod/nodes <NAME> 
                    port-forward <NAME> <LOCAL_PORT>:<CONTAINER_PORT>
                    port-forward <NAME> :<CONTAINER_PORT>               ---> add random local port
```

### Manipulation

```bash
kubectl run <NAME> --image=<ISO:TAG> --port=<CONTAINER_PORT>
kubectl delete pods <NAME>
kubectl exec -it <NAME> sh (~/bin/bash)
```

### Simple manifest

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
