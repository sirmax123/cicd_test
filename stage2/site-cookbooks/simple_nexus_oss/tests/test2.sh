NEXUS_USER='admin'
NEXUS_PASS='admin123'
NEXUS_LOCAL='http://127.0.0.1:8081/nexus'

export USER='{ 
"data": {
    "email":"testing@example.com",
    "firstName":"Test",
    "lastName":"Ing",
    "userId":"testing",
    "status": "active",
    "roles":[
	"repository-any-read"
    ],
    "password": "test123"
}
}'

export USERXML='
<?xml version="1.0" encoding="UTF-8"?>
<user-request>
  <data>
	<userId>user1</userId>
	<email>email@domain.tld</email>
	<status>active</status>
	<firstName>User</firstName>
	<resourceURI>http://127.0.0.1:8081/nexus/service/local/users/user1</resourceURI>
	<roles>
	<role>repository-any-read</role>
	<role>repo-all-full</role>
	</roles>
	<lastName>Name</lastName>
	<password>pass123</password>
  </data>
</user-request>'

export REPO='
{
    "data": {
	"id":           "test-repo1-xml",
	"name":         "test-repo",
        "exposed":      "true",
	"repoType":     "hosted",
        "repoPolicy":   "RELEASE",
	"providerRole": "org.sonatype.nexus.proxy.repository.Repository",
        "provider":     "maven2",
	"format":       "maven2"
    }
}'



curl -i -H "Accept: application/xml" -H "Content-Type: application/xml" \
-f -X POST \
-v -d "${USERXML}" \
-u admin:admin123 http://localhost:8081/nexus/service/local/users

curl -i -H "Accept: application/xml" -H "ContentType: application/xml; charset=UTF-8"  -u $NEXUS_USER:$NEXUS_PASS $NEXUS_LOCAL/service/local/users


curl -i -H "Accept: application/xml" -H "ContentType: application/xml; charset=UTF-8"  -u $NEXUS_USER:$NEXUS_PASS $NEXUS_LOCAL/service/local/roles


#echo "${REPO}" | python -m json.tool
#curl -i -H "Accept: application/json" -H "ContentType: application/json; charset=UTF-8"  -d "$REPO" -u $NEXUS_USER:$NEXUS_PASS $NEXUS_LOCAL/service/local/repositories

#curl -i -H "Accept: application/json" -H "ContentType: application/json; charset=UTF-8" -v -d "$USER" -u $NEXUS_USER:$NEXUS_PASS $NEXUS_LOCAL/service/local/users


#curl -i -H "Accept: application/json" -H "ContentType: application/json; charset=UTF-8"  -u $NEXUS_USER:$NEXUS_PASS $NEXUS_LOCAL/service/local/users 
#curl -i -H "Accept: application/json" -H "ContentType: application/json; charset=UTF-8"  -u $NEXUS_USER:$NEXUS_PASS $NEXUS_LOCAL/service/local/repositories
