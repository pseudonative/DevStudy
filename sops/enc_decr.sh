#!/bin/bash
cypress_env_file='decrpyted.yaml'
other_script='other_sh/other.sh'
# decrypt file with gcp-kms key
sops --decrypt sops_github.yaml > $cypress_env_file
# run other script
(exec $other_script)

# check and delete the decrypted file
if [ -f $cypress_env_file ]; then
   rm decrpyted.yaml
   if [ -f $cypress_env_file ]; then
      echo "$cypress_env_file not removed"
   else
      echo "$cypress_env_file removed"
   fi
fi

echo "done"
