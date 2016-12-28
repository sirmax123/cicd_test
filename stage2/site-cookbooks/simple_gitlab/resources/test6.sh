
export GITLAB_API_ENDPOINT='http://127.0.0.1/api/v3'
export GITLAB_API_PRIVATE_TOKEN='qDQ_X4Wx6EgMCiDLxpJx'
export GITLAB_API_HTTPARTY_OPTIONS="{verify: false}"

gitlab groups



curl --request PUT --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx"  \
http://127.0.0.1/api/v3/groups/2/members/2 -d \
"access_level=50"
