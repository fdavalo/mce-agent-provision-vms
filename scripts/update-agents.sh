#install jq
curl https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq
chmod +x jq

#fetch nodes from terraform.tfstate
./jq -r '.resources[] | select(.name=="ocp_node") | .instances[].attributes.name' terraform.tfstate > /tmp/res

#fetch agents in baremetal infra env
oc get agent -n baremetal -o=jsonpath='{range .items[*]}{.metadata.name}{";"}{.status.inventory.interfaces[*].ipV4Addresses}{";"}{.spec.clusterDeploymentName.name}{";"}{.spec.approved}{";"}{.spec.hostname}{"\n"}{end}' > /tmp/agents
#example output
#1be53442-30c1-fd84-50ff-6c41dfc2ddd5;["10.6.82.204/24"];test1;true;ocp-node-4
#28f03442-7e64-98f8-4f1c-02355cf6d5b0;["10.6.82.216/24"];hycl1;true;ocp-node-1
#42943442-01c1-8b1a-6ae8-d6a10607186a;["10.6.82.73/24"];;false;
#58953442-89ed-f730-230a-e8eb41a7eac6;["10.6.82.76/24"];;false;
#c67f3442-ada3-e6c3-7abf-7d07c312c8d5;["10.6.82.237/24"];hycl1;true;ocp-node-2

for node in `cat /tmp/res`; do 
  # fetch ip from terraform.tfstate
  ip=`./jq -r '.resources[] | select(.name=="ocp_node") | .instances[] | select(.attributes.name=="'$node'") | .attributes.guest_ip_addresses[]' terraform.tfstate; done | grep 10.6.82`
  if [[ "$ip" == "" ]]; then
     echo "ip not found for node $node"
     exit 1
  fi
  #fetch agent by ip
  agent=`grep $ip /tmp/agents | awk -F; '{if ($3=="") print $1;}'`
  if [[ "$agent" == "" ]]; then
     echo "agent not found or already paired with a cluster for node $node"
     exit 1
  fi
  #update agent :  approved and set hostname
  oc patch agent $agent -n baremetal -p '{"spec":{"approved":true, "hostname":"'$node'"}}'
done
