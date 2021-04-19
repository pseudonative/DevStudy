#!/bin/bash

#SCRIPT="/home/jeremy/DevStudy/sops/sops_github.yaml"
other_scrypt="other_sh/cool/cool.sh"
# decrypt file with gcp-kms key
#sops --decrypt sops_github.yaml > $cypress_env_file
# run other script
(exec $other_scrypt)

#cat $SCRIPT

echo "all  scripts have run"