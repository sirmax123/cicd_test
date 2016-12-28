#!/bin/bash

export GITLAB_API_ENDPOINT='http://127.0.0.1/api/v3'
export GITLAB_API_PRIVATE_TOKEN='qDQ_X4Wx6EgMCiDLxpJx'
export GITLAB_API_HTTPARTY_OPTIONS="{verify: false}"

gitlab users


gitlab create_group cicd private
gitlab create_project "test2" "{namespace_id: '2'}"

gitlab create_group "cicd_test" "{path: 'private'}"




curl --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx" http://127.0.0.1/api/v3/namespaces


curl --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx" http://127.0.0.1/api/v3/groups | python -m  json.tool
curl --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx" http://127.0.0.1/api/v3/groups/owned | python -m  json.tool
curl --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx" http://127.0.0.1/api/v3/groups/2/projects | python -m  json.tool


curl --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx"  -H "Content-Type: application/json" -d '{"name":"group_name","path":"group_path"}' http://127.0.0.1/api/v3/groups/




curl --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx"  -H "Content-Type: application/json"  -XPOST http://127.0.0.1/api/v3/users/ -d \
'{
    "email":    "email@domain.tld"
    "password": "password"
    "username": "username"
    "name":     "name_of_user"
}'
