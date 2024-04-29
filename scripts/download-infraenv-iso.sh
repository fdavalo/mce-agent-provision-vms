set -x

cluster=$1

#install jq
curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq
chmod +x jq

#fetch url
url=`oc get infraenv ${cluster} -n hcp-config -o=json | ./jq .status.isoDownloadURL`

#download iso
curl -k -o iso/infraenv.iso "$url"
