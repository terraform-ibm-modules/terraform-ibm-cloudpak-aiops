#!/bin/sh

#IC_API_KEY="dyIU5_WR5BPKGoyyofy4KukU3z6MqFkXDaArRlJjGzGL"
#REGION="us-south"
#RESOURCE_GROUP="joel-rg-ibm"
#ENTITLEMENT_KEY="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2NTU0NzM5MjIsImp0aSI6ImQxY2ZkNGE0OTg1ZjQ0NzlhZjM1NjkyZTIzY2MzZWU0In0.0QT4hyM-5fMhnqiMTMQUVROm8KkrkBZchG0LQeRNthw"
#CLUSTER_ID="cb8nnp1d0jhjspqi58d0"
#NAMESPACE="cp4aiops"


#ibmcloud login -r "${REGION}" -g "${RESOURCE_GROUP}" --apikey "${IC_API_KEY}" > /dev/null
#ibmcloud config --check-version=false > /dev/null
#ibmcloud ks cluster config -c "${CLUSTER_ID}" --admin > /dev/null
#sleep 3
#echo


echo "=== Creating noi-registry-key secret ==="
kubectl create secret docker-registry noi-registry-secret  \
    --docker-username=cp\
    --docker-password=${ENTITLEMENT_KEY} \
    --docker-server=cp.icr.io \
    --namespace=${NAMESPACE}


echo "=== Checking route for Event Manager ==="
if [ "`kubectl get ingresscontroller default -n openshift-ingress-operator -o json | jq -c -r '.spec.endpointPublishingStrategy.type'`" == "HostNetwork" ]; then
    echo "Updating to allow network policies to function correctly"
    kubectl patch namespace default --type=json -p '[{"op":"add","path":"/metadata/labels","value":{"network.openshift.io/policy-group":"ingress"}}]'
fi

echo "=== Creating NOI Service Account ==="
kubectl create serviceaccount noi-service-account -n $NAMESPACE 

kubectl patch serviceaccount noi-service-account -p '{"imagePullSecrets": [{"name": "noi-registry-secret"}]}' -n $NAMESPACE

