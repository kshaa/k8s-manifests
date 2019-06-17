# Base addons
  
Get an Ubuntu workspace pod  
```bash
kubectl run ubuntu-workspace --rm -i --tty --image ubuntu -- bash  
```  

Get an NFS-attached Ubuntu workspace pod
```bash
kubectl apply -f main.yaml
kubectl exec -it $(kubectl get pods -o name | grep -m1 ubuntu-workspace | cut -d'/' -f 2) bash  
kubectl delete -f main.yaml
```  

