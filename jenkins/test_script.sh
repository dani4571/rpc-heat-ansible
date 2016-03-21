#set -ex
sudo pip install python-heatclient
sudo pip install oslo.config

# Environment Binding
$PUBLIC_CLOUD_CREDENTIALS
$JENKINS_CREDENTIALS

if [[ "$APPLY_PATCHES" == "True" ]]; then
    PATCH_STATUS="patched"
elif [[ "$APPLY_PATCHES" == "False" ]]; then
    PATCH_STATUS="unpatched"
fi

if [[ "$RPC_RELEASE" == "juno" ]]; then
    RPC_SERIES="10.1"
elif [[ "$RPC_RELEASE" == "kilo" ]]; then
    RPC_SERIES="11.1"
elif [[ "$RPC_RELEASE" == "liberty-12.0" || "$RPC_RELEASE" == "master" ]]; then
    RPC_SERIES="12.0"
else
    RPC_SERIES=`echo $RPC_RELEASE | sed 's/^r//g' | awk -F '[\.]' '{ print $1 "." $2 }'`
fi

STACK_NAME='rpc-jenkins-$CREATE_BUILD_NUMBER-install-liberty-12-0-full-net-patched'

export PASSWORD=`heat output-show $STACK_NAME password -F raw`
export PRIVATE_KEY=`heat output-show $STACK_NAME private_key -F raw`
export INFRA_IP=`heat output-show $STACK_NAME server_infra1_ip -F raw`
export ALL_IPS=`heat output-show $STACK_NAME all_ips -F raw`
export STACK_ID=`heat stack-list  | grep $STACK_NAME | awk '{print $2}'`
export STACK_PREFIX=`echo $STACK_ID | sed 's/-/ /' | awk '{print $1}'`
export MAAS_NOTIFICATION_PLAN=`heat resource-list $STACK_NAME | grep Rackspace::CloudMonitoring::NotificationPlan | awk '{print $4}'`




#VARS AFTER RPC_RELEASE WILL GO AWAY
cat <<EOF | tee OS_Env.txt
PRIVATE_KEY=$PRIVATE_KEY
INFRA_IP=$INFRA_IP
ALL_IPS=$ALL_IPS
DEPLOY_RETRIES=$DEPLOY_RETRIES
APPLY_PATCHES=$APPLY_PATCHES
RPC_RELEASE=$RPC_RELEASE
STACK_PREFIX=$STACK_PREFIX
STACK_ID=$STACK_ID
PASSWORD=$PASSWORD
ANSIBLE_TAG=$ANSIBLE_TAG
RPC_CI_REPO=$RPC_CI_REPO
RPC_CI_ENDPOINT=$RPC_CI_ENDPOINT
RPC_CI_RELEASE=$RPC_CI_RELEASE

nodes=$ALL_IPS
deploy_retries=$DEPLOY_RETRIES
apply_patches=$APPLY_PATCHES
rpc_release=$RPC_RELEASE
heat_stack_prefix=$STACK_PREFIX
heat_stack_id=$STACK_ID
heat_stack_name=$STACK_NAME
heat_stack_password=$PASSWORD
rackspace_cloud_auth_url=$OS_AUTH_URL
rackspace_cloud_tenant_id=$OS_TENANT_ID
rackspace_cloud_username=$OS_USERNAME
rackspace_cloud_password=$OS_PASSWORD
rackspace_cloud_api_key=$RS_API_KEY
maas_notification_plan=$MAAS_NOTIFICATION_PLAN
EOF




