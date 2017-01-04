#!/bin/bash

export GITLAB_API_ENDPOINT='http://127.0.0.1/api/v3'
export GITLAB_API_PRIVATE_TOKEN='qDQ_X4Wx6EgMCiDLxpJx'
export GITLAB_API_HTTPARTY_OPTIONS="{verify: false}"

gitlab users

set -x

curl --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx"  -H "Content-Type: application/json"    -XPOST http://127.0.0.1/api/v3/users/ -d \
'{
    "email":    "email@domain.tld",
    "password": "password",
    "username": "username",
    "name":     "name_of_user"
}
'
