NEXUS_USER='admin'
NEXUS_PASS='admin123'
NEXUS_LOCAL='http://127.0.0.1:8081/nexus'



#curl -i -H "Accept: application/xml" -H "ContentType: application/xml; charset=UTF-8"  -u $NEXUS_USER:$NEXUS_PASS $NEXUS_LOCAL/service/local/users


curl -i -H "Accept: application/xml" -H "ContentType: application/xml; charset=UTF-8"  -u $NEXUS_USER:$NEXUS_PASS $NEXUS_LOCAL/service/local/privileges


