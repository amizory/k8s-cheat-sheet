alias k='kubectl'
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgd='kubectl get deploy'
alias kgs='kubectl get svc'
alias kgi='kubectl get ingress'
alias kgns='kubectl get namespace'
alias kpf='kubectl port-forward'
alias kr='kubectl run'
alias ka='kubectl apply'
alias ke='kubectl edit'
alias kl='kubectl logs'
alias kcd='kubectl create deploy'
alias kcns='kubectl create namespace'
alias ked='kubectl expose deploy'
alias kd='kubectl describe'
alias kdp='kubectl describe pods'
alias kdn='kubectl discribe nodes'
alias kdd='kubectl describe deploy'
alias kds='kubectl describe svc'
alias kdi='kubectl describe ingress'
alias kdns='kubectl describe namespace'
alias kdelp='kubectl delete pods'
alias kdeld='kubectl delete deployment'
alias kdels='kubectl delete svc'
alias kdelns='kubectl delete namespace'
source <(kubectl completion bash)