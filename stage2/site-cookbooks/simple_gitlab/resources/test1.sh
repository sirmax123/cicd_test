
echo "u = User.where(id: 1).first
u.password = 'secret_pass'
u.password_confirmation = 'secret_pass'
u.password_automatically_set = false
u.save!" | gitlab-rails console production


exit


 #<User id: 1, email: "admin@example.com", 
 created_at: "2016-12-27 14:10:57", 
 updated_at: "2016-12-27 15:54:23", 
 name: "Administrator", 
 admin: true, 
 projects_limit: 10, 
 skype: "", 
 linkedin: "", 
 twitter: "", 
 authentication_token: "qDQ_X4Wx6EgMCiDLxpJx", 
 theme_id: 2, 
 bio: nil, 
 username: "root", 
 can_create_group: true, c
 an_create_team: false, 
 state: "active", 
 color_scheme_id: 1, 
 password_expires_at: nil, 
 created_by_id: nil, l
 ast_credential_check_at: nil, 
 avatar: nil, 
 hide_no_ssh_key: false, 
 website_url: "", 
 notification_email: "admin@example.com", 
 hide_no_password: false, 
 password_automatically_set: true, 
 location: nil, 
 encrypted_otp_secret: nil, 
 encrypted_otp_secret_iv: nil, 
 encrypted_otp_secret_salt: nil, 
 otp_required_for_login: false, 
 otp_backup_codes: nil, 
 public_email: "", 
 dashboard: 0, project_view: 0, 
 consumed_timestep: nil, layout: 0, 
 hide_project_limit: false, 
 otp_grace_period_started_at: nil, 
 ldap_email: false, 
 external: false, 
 organization: nil, 
 incoming_email_token: "88vfpcfgjd9mwvou4e5g8og0l", authorized_projects_populated: nil