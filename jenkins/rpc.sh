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
/usr/bin/pip install --upgrade pip || exit_failure "PIP Upgrade PIP Failure"
/usr/local/bin/pip install pip==1.5.6 || exit_failure "PIP Install PIP Failure"
install_ansible
cd /opt/cba
# BEGIN - Terrible Chicken Egg Hack
export MY_PUBLIC_IP=`curl -s http://ipv4.icanhazip.com/`
sed -i "s/ansible_connection=local/ansible_ssh_host=$MY_PUBLIC_IP/" inventory
# END - Terrible Chicken Egg Hack
git clone $RPC_HEAT_ANSIBLE_REPO -b $RPC_HEAT_ANSIBLE_RELEASE || exit_failure "Git Clone Failure"
cd /opt/cba/rpc-heat-ansible/playbooks
if [[ "$RPC_HEAT_ANSIBLE_REPO" != "https://github.com/cloud-training/rpc-heat-ansible.git" ]]; then
  git remote add upstream https://github.com/cloud-training/rpc-heat-ansible.git
fi
ansible-playbook rpc-$RPC_SERIES-playbook.yml -v --tags $ANSIBLE_TAG || exit_failure "Ansible Playbook Run Failure"
exit_success
