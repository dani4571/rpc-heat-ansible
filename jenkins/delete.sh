#!/bin/bash

#set -ex
sudo pip install python-heatclient
sudo pip install oslo.config

# Environment Binding
$PUBLIC_CLOUD_CREDENTIALS

if [[ "$APPLY_PATCHES" == "True" ]]; then
    PATCH_STATUS="patched"
elif [[ "$APPLY_PATCHES" == "False" ]]; then
    PATCH_STATUS="unpatched"
fi


STACK_NAME=rpc-jenkins-$CREATE_BUILD_NUMBER-install-`echo $RPC_RELEASE | sed 's/\./-/g'`-$HEAT_ENVIRONMENT-$PATCH_STATUS

BUILD_DELETED=1
echo "===================================================="
heat stack-delete $STACK_NAME

until [[ $BUILD_DELETED -eq 0 ]]; do
  sleep 30
  STACK_STATUS=`heat stack-list | awk '/ '$STACK_NAME' / { print $6 }'`
  BUILD_DELETED=`heat stack-list | awk '/ '$STACK_NAME' / { print $6 }' | wc -l`
  echo "===================================================="
  echo "Stack Status:        $STACK_STATUS"
  echo "Build Deleted:       $BUILD_DELETED"
  if [[ "$STACK_STATUS" != 'DELETE_IN_PROGRESS' ]]; then
    if [[ "$STACK_STATUS" == 'DELETE_FAILED' ]]; then
      NETWORK_ID=`heat resource-list $STACK_NAME | awk '/ OS::Neutron::Net / { print $4 }'`
      for PORT_ID in `rack networks port list --network-id $NETWORK_ID --fields id --no-header`; do
        rack networks port delete --id $PORT_ID
        sleep 20
      done
    fi
    heat stack-delete $STACK_NAME
  fi
done

exit