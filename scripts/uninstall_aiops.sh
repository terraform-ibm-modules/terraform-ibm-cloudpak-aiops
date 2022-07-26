
eval "$(jq -r '@sh "export KUBECONFIG=\(.KUBECONFIG) AIOPS_PROJECT_NAME=\(.AIOPS_PROJECT_NAME)"')"

echo "*********************************************************************************"
echo "******************** Uninstalling AIOPS from the Cluster ... **********************"
echo "*********************************************************************************"


echo
echo

echo "Setting project ${AIOPS_PROJECT_NAME} ..."
kubectl get ns "${AIOPS_PROJECT_NAME}"
echo


for resource in subscription deployments deploymentconfigs configmaps OperatorGroup statefulset EventStreams csv scc jobs pods secrets services roles rolebindings pvc pv namespaces ;
do
  echo " => Deleting the ${resource} ...";
  resources=$(kubectl get "${resource}" -n "${AIOPS_PROJECT_NAME}" | grep aiops | awk '{print $1}'); # '
  eval "elements=($resources)"
  for element in "${elements[@]}"; do
      check_resource=true
      while ( $check_resource )
      do
        cmd=$(kubectl delete "${resource}"/"${element}" -n "${AIOPS_PROJECT_NAME}")
        sleep 10
        get_resource=$(kubectl get "${resource}" -n "${AIOPS_PROJECT_NAME}" | grep aiops | awk '{print $1}')
        if [ "${get_resource}" == "${resource}" ]
        then
          continue
        elif [ "${get_resource}" == "NotFound" ]; then
          check_resource=false
          break
        else
          check_resource=false
          break
        fi
      done
  done
  echo "******************************************************************************************************************"
done

echo
echo
echo "*********************************************************************************"
echo "**************** Uninstallation of AIOPS completed successfully!!! ****************"
echo "*********************************************************************************"