#!/bin/bash
node=10.13.14.1
echo "enter user name："
read -ep " " USERNAME
echo "enter user passwd："
read -ep " " PASSWORD
curl -f -s -S -k --data-urlencode "username=$USERNAME@pve" --data-urlencode "password=$PASSWORD" "https://$node:8006/api2/json/access/ticket" >/tmp/tk
TICKET=`cat /tmp/tk|jq .data.ticket|tr -d '"'`
CSRF=`cat /tmp/tk|jq .data.CSRFPreventionToken|tr -d '"'`
curl -f -s -S -k -b "PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF" -X GET https:/$node:8006/api2/json/cluster/resources  >/tmp/.resource
vmid=`cat /tmp/.resource|jq .data[0].vmid`
pvenode=`cat /tmp/.resource| jq .data[0].node|sed 's/\"//g'`
vmstate=`curl -f -s -S -k -b "PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF" -X GET "https:/$node:8006/api2/json/nodes/$pvenode/qemu/$vmid/status/current"|jq .data.status|sed 's/\"//g'`
if [ $vmstate == "stopped" ]
then
curl -f -s -S -k -b "PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF" -X POST "https:/$node:8006/api2/json/nodes/$pvenode/qemu/$vmid/status/start" >/dev/null 2>&1
sleep 5s
fi
curl -f -s -S -k -b "PVEAuthCookie=$TICKET" -H "CSRFPreventionToken: $CSRF" "https://$node:8006/api2/spiceconfig/nodes/$pvenode/qemu/$vmid/spiceproxy" -d "proxy=$node" > /tmp/spiceproxy
exec remote-viewer /tmp/spiceproxy 
rm /tmp/spiceproxy /tmp/.resource
exit 0


