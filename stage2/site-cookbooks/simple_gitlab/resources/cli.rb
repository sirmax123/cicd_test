property :root_password, String, default: 'value'

action :configure do
    puts("Configuring gitlab")
    system '/usr/bin/gitlab-ctl reconfigure'

    if root_password.length < 8
	raise 'Password is too short (minimum is 8 characters)'
    end

    cmd = "echo \"u = User.where(id: 1).first
           u.password = '" + root_password + "'
           u.password_confirmation = '" + root_password + "'
           u.password_automatically_set = false
           u.save!\" | /usr/bin/gitlab-rails console production" 
    res = system cmd
end
