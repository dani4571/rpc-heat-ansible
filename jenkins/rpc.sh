export HOME="/root"
set -e
set -x
function exit_failure {
  echo '{"status": "FAILURE", "reason": "'"$@"'"}'
  exit 1
}
function exit_success {
  echo '{"status": "SUCCESS"}'
}
function get_rpc_series {
  if [[ "$@" == "juno" ]]; then
      export RPC_SERIES="10.1"
  elif [[ "$@" == "kilo" ]]; then
      export RPC_SERIES="11.1"
  elif [[ "$@" == "liberty-12.0" || "$@" == "master" ]]; then
      export RPC_SERIES="12.0"
  else
      export RPC_SERIES=`echo $@ | sed 's/^r//g' | awk -F '[\.]' '{ print $1 "." $2 }'`
  fi
}
function install_ansible {
  if [[ "$RPC_SERIES" == "10.1" ]]; then
    ANSIBLE_VERSION="1.6.10"
  elif [[ "$RPC_SERIES" == "11.0" || "$RPC_SERIES" == "11.1"  ]]; then
    ANSIBLE_VERSION="1.9.3"
  else
    ANSIBLE_VERSION="1.9.4"
  fi
  /usr/local/bin/pip install ansible==$ANSIBLE_VERSION || exit_failure "PIP Install Ansible Failure"
}

get_rpc_series $RPC_RELEASE
if [ -a /usr/bin/pip ]
  then
  /usr/bin/pip install --upgrade pip || exit_failure "PIP Upgrade PIP Failure"
fi
/usr/local/bin/pip install pip==1.5.6 || exit_failure "PIP Install PIP Failure"
install_ansible
cd /opt/cba
sudo rm -rf $RPC_CI_REPO
git clone $RPC_CI_ENDPOINT -b $RPC_CI_RELEASE || exit_failure "Git Clone Failure"
cd /opt/cba/$RPC_CI_REPO/playbooks
if [[ "$RPC_CI_ENDPOINT" != "https://github.com/cloud-training/rpc-heat-ansible.git" ]]; then
  git remote add upstream https://github.com/cloud-training/rpc-heat-ansible.git
fi
ansible-playbook rpc-$RPC_SERIES-playbook.yml -v --tags $ANSIBLE_TAG || exit_failure "Ansible Playbook Run Failure"

cat <<EOF | tee OS_Env.txt
ALL_IPS=$ALL_IPS
ENV_NAME=$ENV_NAME
EOF

exit_success
