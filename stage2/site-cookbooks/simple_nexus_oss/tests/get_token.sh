#!/bin/bash



#
#curl -XPOST  -u admin:admin123  http://localhost:8081/nexus/service/siesta/wonderland/authenticate -d

#curl -H "Accept: application/json" -H "Content-Type: application/json" -H "X-NX-AuthTicket: 


curl -v \
http://localhost:8081/nexus/service/siesta/usertoken/current

T=$(curl -H "Accept: application/json" -H "Content-Type: application/json" --data '{"u":"YWRtaW4=","p":"YWRtaW4xMjM="}' -u admin:admin123 http://localhost:8081/nexus/service/siesta/wonderland/authenticate | grep '"t" :' | awk -F'"' '{ print $4}')
echo ${T}

curl   \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "X-NX-AuthTicket: ${T}" \
-u admin:admin123 http://localhost:8081/nexus/service/siesta/usertoken/current

#{
#    "nameCode" : "8I034iTW",
#    "passCode" : "EraLxqQei3DO9fjcTTAO9fvKU9t7EaliZIzjolDnAv37",
#    "created" : "2014-01-28T17:17:07.701+0000"
#}