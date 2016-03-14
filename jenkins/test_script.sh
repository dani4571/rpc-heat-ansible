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

STACK_NAME='rpc-jenkins-52-install-liberty-12-0-full-net-patched'

export PASSWORD=`heat output-show $STACK_NAME password -F raw`
export PRIVATE_KEY=`heat output-show $STACK_NAME private_key -F raw`
export INFRA_IP=`heat output-show $STACK_NAME server_infra1_ip -F raw`
export ALL_IPS=`heat output-show $STACK_NAME all_ips -F raw`
#export ALL_IPS=`echo "$IPS"`


cat <<EOF | tee OS_Env.txt
Password=$PASSWORD
Private_Key=$PRIVATE_KEY
ALL_IPS=$ALL_IPS
INFRA_IP=$INFRA_IP
DEPLOY_RETRIES=$DEPLOY_RETRIES
APPLY_PATCHES=$APPLY_PATCHES
RPC_RELEASE=$RPC_RELEASE
EOF




