

#curl -u admin:admin123 http://localhost:8081/nexus/service/local/repositories

#curl -i -H "Accept: application/xml" -H "Content-Type: application/xml" \
curl -i  -H "Content-Type: application/xml" \
-f -X POST \
-v -d "@$(pwd)/insert_oss_repository.xml" \
-u admin:admin123 http://localhost:8081/nexus/service/local/repositories
