#!/bin/bash
usage() {
   echo "$*"
   cat <<EOF
Usage:
   $(basename $0) <config file>.txt

   The config file has two lines
   <username>
   <pubkey string>

   example:
   stevo
   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEsnf4jSedtsVpAtB82eabAMWRPLmpL4YTYgwCy+O3zP shollingsworth@shollingsworth-lnx
EOF
   exit -1
}

config_file="${1}"
test -f "${config_file}" || usage "Missing config file"
user="$(head -n1 "${config_file}")"
key="$(tail -n1 "${config_file}")"
test -z "${user}" && usage "Invalid user / user blank"
test -z "${key}" && usage "public key is missing or blank"
if ssh-keygen -l -f <(echo "${key}"); then
   ssh_dir="/home/${user}/.ssh"
   echo "${user}"
   useradd -m ${user}
   mkdir -v ${ssh_dir}
   chown -v ${user}:${user} ${ssh_dir}
   chmod -v 700 ${ssh_dir}
   echo "${key}" > ${ssh_dir}/authorized_keys
   echo "${user} addition complete"
else
   usage "Invalid key :\\"
fi
