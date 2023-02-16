set -x

#install jq
curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq
chmod +x jq

#fetch nodes from terraform.tfstate
./jq -r '.resources[] | select(.name=="ocp_node") | .instances[].attributes.name' terraform.tfstate > /tmp/res

for node in `cat /tmp/res`; do 
  # fetch ip from terraform.tfstate
  ip=`./jq -r '.resources[] | select(.name=="ocp_node") | .instances[] | select(.attributes.name=="'$node'") | .attributes.guest_ip_addresses[]' terraform.tfstate | grep 10.6.82`
  if [[ "$ip" == "" ]]; then
     echo "ip not found for node $node"
     exit 1
  fi
  found="no"
  while [[ "$found" == "no" ]]; do
    #fetch agents in baremetal infra env
    oc get agent -n baremetal -o=jsonpath='{range .items[*]}{.metadata.name}{";"}{.status.inventory.interfaces[*].ipV4Addresses}{";"}{.spec.clusterDeploymentName.name}{";"}{.spec.approved}{";"}{.spec.hostname}{"\n"}{end}' > /tmp/agents
    #example output
    #1be53442-30c1-fd84-50ff-6c41dfc2ddd5;["10.6.82.204/24"];test1;true;ocp-node-4
    #42943442-01c1-8b1a-6ae8-d6a10607186a;["10.6.82.73/24"];;false;
    cat /tmp/agents
  
    #fetch agent by ip
    used=`grep $ip /tmp/agents | awk -F\; '{if ($3!="") print "yes";}'`
    if [[ "$used" == "yes" ]]; then
       echo "agent found but already used in cluster"
       exit 1
    fi
    agent=`grep $ip /tmp/agents | awk -F\; '{print $1;}'`
    if [[ "$agent" != "" ]]; then
     found="yes"
    fi
  done
  #update agent :  approved and set hostname
  oc patch agent $agent -n baremetal -p '{"spec":{"approved":true, "hostname":"'$node'"}}' --type=merge
done
