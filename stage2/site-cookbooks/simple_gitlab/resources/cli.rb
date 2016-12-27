property :root_password, String, default: 'value'

#load_current_value do
#  puts('load_current_value')
#end


action :create do
    # a mix of built-in Chef resources and Ruby
    puts("action create")
end

action :delete do
    # a mix of built-in Chef resources and Ruby
    puts("action delete")
end


action :install do
    # a mix of built-in Chef resources and Ruby
    puts("action install")
    puts(root_password)
    command = "echo " + root_password
    puts("==========================")
    puts(command)
    puts("==========================")
    a = system 'echo "hello $HOSTNAME"'
    puts("==========================")
    puts(a)
    puts("==========================")

end


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
