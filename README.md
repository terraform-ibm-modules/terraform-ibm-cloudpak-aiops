# IBM Cloud Pak for AIOps - Terraform Module

This is a module and example to make it easier to provision Cloud Pak for AIOps on an IBM Cloud Platform OpenShift Cluster provisioned on either Classic or VPC infrastructure.

## Compatibility

This module is meant for use with Terraform 0.13 (and higher).

## Pre-requisites

OpenShift cluster is required that contains at least 4 nodes of size 16x64. If VPC is used on OpenShift 4.6 or earlier, Portworx™ is required to provide necessary storage classes. If VPC is used on OpenShift 4.7 or later, ODF is required to provide necessary storage classes.


### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 (or later)
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm) 1.34 (or later)

For installation instructions, refer [here](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment/#install-terraform)

## Requirements for AIOps

Please ensure your cluster is setup to install AIManager and Eventmanager: `9` nodes.

Current min spec requires:
- 3 nodes for AIManager    @ 16x64
- 6 nodes for EventManager @ 16x64

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md)
customizing these values in the `terraform.tfvars` file:

```hcl
ibmcloud_api_key      = "******************"  // pragma: allowlist secret
resource_group        = "******************"
region                = "******************"
cluster_name_or_id    = "******************"
on_vpc                = "******************"
entitled_registry_key = "******************"
entitled_registry_user_email = "***********"
```

## Usage

A full example is located in the [examples](examples/roks_classic_with_cp4aiops) folder.

e.g:

```hcl
provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key    // pragma: allowlist secret
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_name_or_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = var.cluster_config_path
}


// Module:
module "cp4aiops" {
  source    = "../../."
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = 1         

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // AIOps specific parameters:
  accept_aimanager_license     = var.accept_aimanager_license
  accept_event_manager_license = var.accept_event_manager_license
  namespace            = "aiops"
  enable_aimanager     = true

  //************************************
  // EVENT MANAGER OPTIONS START *******
  //************************************
  enable_event_manager = true

  // Persistence option
  enable_persistence               = var.enable_persistence

  // AIOps - humio
  humio_repo                       = var.humio_repo
  humio_url                        = var.humio_url

  // LDAP options
  ldap_port                        = var.ldap_port
  ldap_mode                        = var.ldap_mode
  ldap_user_filter                 = var.ldap_user_filter
  ldap_bind_dn                     = var.ldap_bind_dn
  ldap_ssl_port                    = var.ldap_ssl_port
  ldap_url                         = var.ldap_url
  ldap_suffix                      = var.ldap_suffix
  ldap_group_filter                = var.ldap_group_filter
  ldap_base_dn                     = var.ldap_base_dn
  ldap_server_type                 = var.ldap_server_type

  // Service Continuity
  continuous_analytics_correlation = var.continuous_analytics_correlation
  backup_deployment                = var.backup_deployment

  // Zen Options
  zen_deploy                       = var.zen_deploy
  zen_ignore_ready                 = var.zen_ignore_ready
  zen_instance_name                = var.zen_instance_name
  zen_instance_id                  = var.zen_instance_id
  zen_namespace                    = var.zen_namespace
  zen_storage                      = var.zen_storage

  // TOPOLOGY OPTIONS:
  // App Discovery -
  enable_app_discovery             = var.enable_app_discovery
  ap_cert_secret                   = var.ap_cert_secret           // pragma: allowlist secret
  ap_db_secret                     = var.ap_db_secret             // pragma: allowlist secret
  ap_db_host_url                   = var.ap_db_host_url
  ap_secure_db                     = var.ap_secure_db
  // Network Discovery
  enable_network_discovery         = var.enable_network_discovery
  // Observers
  obv_docker                       = var.obv_docker
  obv_taddm                        = var.obv_taddm
  obv_servicenow                   = var.obv_servicenow
  obv_ibmcloud                     = var.obv_ibmcloud
  obv_alm                          = var.obv_alm
  obv_contrail                     = var.obv_contrail
  obv_cienablueplanet              = var.obv_cienablueplanet
  obv_kubernetes                   = var.obv_kubernetes
  obv_bigfixinventory              = var.obv_bigfixinventory
  obv_junipercso                   = var.obv_junipercso
  obv_dns                          = var.obv_dns
  obv_itnm                         = var.obv_itnm
  obv_ansibleawx                   = var.obv_ansibleawx
  obv_ciscoaci                     = var.obv_ciscoaci
  obv_azure                        = var.obv_azure
  obv_rancher                      = var.obv_rancher
  obv_newrelic                     = var.obv_newrelic
  obv_vmvcenter                    = var.obv_vmvcenter
  obv_rest                         = var.obv_rest
  obv_appdynamics                  = var.obv_appdynamics
  obv_jenkins                      = var.obv_jenkins
  obv_zabbix                       = var.obv_zabbix
  obv_file                         = var.obv_file
  obv_googlecloud                  = var.obv_googlecloud
  obv_dynatrace                    = var.obv_dynatrace
  obv_aws                          = var.obv_aws
  obv_openstack                    = var.obv_openstack
  obv_vmwarensx                    = var.obv_vmwarensx

  // Backup Restore
  enable_backup_restore            = var.enable_backup_restore
}
```

## Inputs

## Input Variables

Name                             | Type   | Description                                                                                                                                        | Sensitive | Default
-------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ----------------------------
ibmcloud_api_key                 |        | IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey                                                                      | true      | 
region                           |        | Region that cluster resides in                                                                                                                     |           | 
cluster_name_or_id               |        | Id of cluster for AIOps to be installed on                                                                                                         |           | 
resource_group_name              |        | Resource group that cluster resides in                                                                                                             |           | cloud-pak-sandbox-ibm
enable                           |        | If set to true installs Cloud-Pak for Data on the given cluster                                                                                    |           | true
cluster_config_path              |        | Path to the Kubernetes configuration file to access your cluster                                                                                   |           | 
on_vpc                           | bool   | If set to true, lets the module know cluster is using VPC Gen2                                                                                     |           | false
portworx_is_ready                | any    |                                                                                                                                                    |           | null
entitled_registry_key            |        | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary                                                              |           | 
entitled_registry_user_email     |        | Required: Email address of the user owner of the Entitled Registry Key                                                                             |           | 
namespace                        |        | Namespace for Cloud Pak for AIOps                                                                                                                  |           | cpaiops
accept_aiops_license             | bool   | Do you accept the licensing agreement for aiops? `T/F`                                                                                             |           | false
enable_aimanager                 | bool   | Install AIManager? `T/F`                                                                                                                           |           | true
enable_event_manager             | bool   | Install Event Manager? `T/F`                                                                                                                       |           | true

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Watson AIOps Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/cp4aiops).

## Event Manager Options

Name                             | Type   | Description                                                                                                                                        | Sensitive | Default
-------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ----------------------------
enable_persistence               | bool   | Enables persistence storage for kafka, cassandra, couchdb, and others. Default is `true`                                                           |           | true
humio_repo                       | string | To enable Humio search AIOps, provide the Humio Repository for your Humio instance                                                          |           | 
humio_url                        | string | To enable Humio search AIOps, provide the Humio Base URL of your Humio instance (on-prem/cloud)                                             |           | 
ldap_port                        | number | Configure the port of your organization's LDAP server.                                                                                             |           | 3389
ldap_mode                        | string | Choose `standalone` for a built-in LDAP server or `proxy` and connect to an external organization LDAP server. See http://ibm.biz/install_noi_icp. |           | standalone
ldap_storage_class               | string | LDAP Storage class - note: only needed for `standalone` mode                                                                                       |           | 
ldap_user_filter                 | string | LDAP User Filter                                                                                                                                   |           | uid=%s,ou=users
ldap_bind_dn                     | string | Configure LDAP bind user identity by specifying the bind distinguished name (bind DN).                                                             |           | cn=admin,dc=mycluster,dc=icp
ldap_ssl_port                    | number | Configure the SSL port of your organization's LDAP server.                                                                                         |           | 3636
ldap_url                         | string | Configure the URL of your organization's LDAP server.                                                                                              |           | ldap://localhost:3389
ldap_suffix                      | string | Configure the top entry in the LDAP directory information tree (DIT).                                                                              |           | dc=mycluster,dc=icp
ldap_group_filter                | string | LDAP Group Filter                                                                                                                                  |           | cn=%s,ou=groups
ldap_base_dn                     | string | Configure the LDAP base entry by specifying the base distinguished name (DN).                                                                      |           | dc=mycluster,dc=icp
ldap_server_type                 | string | LDAP Server Type. Set to `CUSTOM` for non Active Directory servers. Set to `AD` for Active Directory                                               |           | CUSTOM
continuous_analytics_correlation | bool   | Enable Continuous Analytics Correlation                                                                                                            |           | false
backup_deployment                | bool   | Is this a backup deployment?                                                                                                                       |           | false
zen_deploy                       | bool   | Flag to deploy NOI cpd in the same namespace as aimanager                                                                                          |           | false
zen_ignore_ready                 | bool   | Flag to deploy zen customization even if not in ready state                                                                                        |           | false
zen_instance_name                | string | Application Discovery Certificate Secret (If Application Discovery is enabled)                                                                     |           | iaf-zen-cpdservice
zen_instance_id                  | string | ID of Zen Service Instance                                                                                                                         |           | 
zen_namespace                    | string | Namespace of the ZenService Instance                                                                                                               |           | 
zen_storage                      | string | The Storage Class Name                                                                                                                             |           | 
enable_app_discovery             | bool   | Enable Application Discovery and Application Discovery Observer                                                                                    |           | false
ap_cert_secret                   | string | Application Discovery Certificate Secret (If Application Discovery is enabled)                                                                     |           | 
ap_db_secret                     | string | Application Discovery DB2 secret (If Application Discovery is enabled)                                                                             |           | 
ap_db_host_url                   | string | Application Discovery DB2 host to connect (If Application Discovery is enabled)                                                                    |           | 
ap_secure_db                     | bool   | Application Discovery Secure DB connection (If Application Discovery is enabled)                                                                   |           | false
enable_network_discovery         | bool   | Enable Network Discovery and Network Discovery Observer                                                                                            |           | false
obv_alm                          | bool   | Enable ALM Topology Observer                                                                                                                       |           | false
obv_ansibleawx                   | bool   | Enable Ansible AWX Topology Observer                                                                                                               |           | false
obv_appdynamics                  | bool   | Enable AppDynamics Topology Observer                                                                                                               |           | false
obv_aws                          | bool   | Enable AWS Topology Observer                                                                                                                       |           | false
obv_azure                        | bool   | Enable Azure Topology Observer                                                                                                                     |           | false
obv_bigfixinventory              | bool   | Enable BigFixInventory Topology Observer                                                                                                           |           | false
obv_cienablueplanet              | bool   | Enable CienaBluePlanet Topology Observer                                                                                                           |           | false
obv_ciscoaci                     | bool   | Enable CiscoAci Topology Observer                                                                                                                  |           | false
obv_contrail                     | bool   | Enable Contrail Topology Observer                                                                                                                  |           | false
obv_dns                          | bool   | Enable DNS Topology Observer                                                                                                                       |           | false
obv_docker                       | bool   | Enable Docker Topology Observer                                                                                                                    |           | false
obv_dynatrace                    | bool   | Enable Dynatrace Topology Observer                                                                                                                 |           | false
obv_file                         | bool   | Enable File Topology Observer                                                                                                                      |           | true
obv_googlecloud                  | bool   | Enable GoogleCloud Topology Observer                                                                                                               |           | false
obv_ibmcloud                     | bool   | Enable IBMCloud Topology Observer                                                                                                                  |           | false
obv_itnm                         | bool   | Enable ITNM Topology Observer                                                                                                                      |           | false
obv_jenkins                      | bool   | Enable Jenkins Topology Observer                                                                                                                   |           | false
obv_junipercso                   | bool   | Enable JuniperCSO Topology Observer                                                                                                                |           | false
obv_kubernetes                   | bool   | Enable Kubernetes Topology Observer                                                                                                                |           | true
obv_newrelic                     | bool   | Enable NewRelic Topology Observer                                                                                                                  |           | false
obv_openstack                    | bool   | Enable OpenStack Topology Observer                                                                                                                 |           | false
obv_rancher                      | bool   | Enable Rancher Topology Observer                                                                                                                   |           | false
obv_rest                         | bool   | Enable Rest Topology Observer                                                                                                                      |           | true
obv_servicenow                   | bool   | Enable ServiceNow Topology Observer                                                                                                                |           | true
obv_taddm                        | bool   | Enable TADDM Topology Observer                                                                                                                     |           | false
obv_vmvcenter                    | bool   | Enable VMVcenter Topology Observer                                                                                                                 |           | true
obv_vmwarensx                    | bool   | Enable VMWareNSX Topology Observer                                                                                                                 |           | false
obv_zabbix                       | bool   | Enable Zabbix Topology Observer                                                                                                                    |           | false
enable_backup_restore            | bool   | Enable Analytics Backups                                                                                                                           |           | false


## Outputs

| Name                               | Description                                                         |
| ---------------------------------- | --------------------------------------------------------------------|
| `cp4aiops_aiman_url`               | Access your Cloud Pak for AIOPS AIManager deployment at this URL.   |
| `cp4aiops_aiman_user`              | Username for your Cloud Pak for AIOPS AIManager deployment.         |
| `cp4aiops_aiman_password`          | Password for your Cloud Pak for AIOPSAIManager  deployment.         |
| `cp4aiops_evtman_url`              | Access your Cloud Pak for AIOP EventManager deployment at this URL. |
| `cp4aiops_evtman_user`             | Username for your Cloud Pak for AIOPS EventManager deployment.      |
| `cp4aiops_evtman_password`         | Password for your Cloud Pak for AIOPS EventManager deployment.      |


## Install


### Pre-commit hooks

Run the following command to execute the pre-commit hooks defined in .pre-commit-config.yaml file

```bash
pre-commit run -a
```

You can install pre-commit tool using

```bash
pip install pre-commit
```

or

```bash
pip3 install pre-commit
```

### Detect Secret hook

Used to detect secrets within a code base.

To create a secret baseline file run following command

```bash
detect-secrets scan --update .secrets.baseline
```

While running the pre-commit hook, if you encounter an error like

```console
WARNING: You are running an outdated version of detect-secrets.
Your version: 0.13.1+ibm.27.dss
Latest version: 0.13.1+ibm.46.dss
See upgrade guide at https://ibm.biz/detect-secrets-how-to-upgrade
```

run below command

```bash
pre-commit autoupdate
```

which upgrades all the pre-commit hooks present in .pre-commit.yaml file.

## How to input variable values through a file

To review the plan for the configuration defined (no resources actually provisioned)

```bash
terraform plan -var-file=./input.tfvars
```

To execute and start building the configuration defined in the plan (provisions resources)

```bash
terraform apply -var-file=./input.tfvars
```

To destroy all related resources

```bash
terraform destroy -var-file=./input.tfvars
```

## Executing the Terraform Script
Run the following commands to execute the TF script (containing the modules to create/use ROKS and Portworx). Execution may take about 5-15 minutes:

```
terraform init
terraform plan
terraform apply -auto-approve
```
All optional parameters by default will be set to null in respective example's variable.tf file. If user wants to configure any optional parameters he has overwrite the default value in the input.tfvars file.

## Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud oc cluster config -c <cluster-name> --admin
oc get route -n ${NAMESPACE} cpd -o jsonpath=‘{.spec.host}’ && echo
```

To get default login id:

```bash
oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 -d && echo
```

To get default Password:

```bash
oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo
```

## Post Installation Instructions

This section is _REQUIRED_ if you install AIManager and EventManager. 

Please follow the documentation starting at `step 3` to `step 9` [here](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=installing-ai-manager-event-manager) for further info.


## Cleanup

To uninstall Cloud Pak for AIOps, an API KEY to the account running the cluster is required as is the cluster id. Once these are set, you can run the uninstall_cp4aiops.sh script to remove all resources and the namespace.

```
export API_KEY="******************" // pragma: allowlist secret
export CLUSTER_ID="****************"
export NAMESPACE="cp4aiops"
./scripts/uninstall_cp4aiops.sh
```
Once all resources have been removed from the cluster, run:
```bash
terraform destroy
```

## Note

All optional parameters, by default, will be set to `null` in respective example's variable.tf file. You can also override these optional parameters.
