# Typhoon'ed K8S addons

## Connect to dashboard
```
export POD_NAME=$(kubectl get pods -n kube-system -l "app=kubernetes-dashboard,release=dashy-mc-dash" -o jsonpath="{.items[0].metadata.name}")
echo https://127.0.0.1:8443/
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
kubectl -n kube-system port-forward $POD_NAME 8443:8443
```
