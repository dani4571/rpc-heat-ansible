#!/bin/bash

function exit_failure {
  echo '{"status": "FAILURE", "reason": "'"$@"'"}'
  exit 1
}
function exit_success {
  echo '{"status": "SUCCESS"}'
}

git clone $RPC_STATUS_ENDPOINT -b $RPC_STATUS_RELEASE || exit_failure "Git Clone Failure"
cd $RPC_STATUS_REPO
echo $ALL_IPS > control_plane.json

DATE=`date`

git add control_plane.json
git commit -m "updating control plane $DATE"
git push origin master

cp control_plane.json $WORKSPACE