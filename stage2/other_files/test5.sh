
export GITLAB_API_ENDPOINT='http://127.0.0.1/api/v3'
export GITLAB_API_PRIVATE_TOKEN='qDQ_X4Wx6EgMCiDLxpJx'
export GITLAB_API_HTTPARTY_OPTIONS="{verify: false}"

gitlab groups


#exit 0

set -x

#curl --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx"  -H "Content-Type: application/json"    -XGET http://127.0.0.1/api/v3/users/2/keys


#curl -v --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx"  -H "Content-Type: application/json"    -XPOST http://127.0.0.1/api/v3/users/2/keys -d \
#'
#{
#    "title": "mm",
#    "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5EIrDnnxNBQavZcxiaHCzt0tjtfW0nNuFAz9f+fs4dL0/3wTbDCWO1l2tahTlupM8r/Tm4Sq20Gsrndl37zEFoqFZG42m1COuEMBgppl4er0cetlZV0qeKfcKQ0xXlZUE1LMJwQoBqAFl4QJ6g25PSPESJxd3wQ1RUfjvJ9kvW8c4sLHD0MjLAmX+VjFlbqNtM1l3uAIMc17RP4B2u4s2FqoyCjg9IxcGlL364FOWJZdHjFaBJvg1k4zo+WzSA2YtOgFxI0CWHUTIcjLD6d3np534zONNxjxsrUz5MBROPUQYOT9y3m9RDBXJVhdvk7V7lTzFYsrTrsJy+gu0pTCL root@mmaxur-pc"
#}
#'


curl --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx" -XPOST \
--data "user_id=2&access_level=30" http://127.0.0.1/api/v3/groups/2/members


#curl --request POST --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" --data "user_id=2&access_level=30" https://gitlab.example.com/api/v3/projects/:id/members



curl --request PUT --header "PRIVATE-TOKEN: qDQ_X4Wx6EgMCiDLxpJx"  \
http://127.0.0.1/api/v3/groups/2/members/2 -d \
"access_level=50"
