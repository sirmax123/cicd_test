action :configure do
    puts("Configuring GitLAB")
    system '/usr/bin/gitlab-ctl reconfigure'
end

action :nothing do
    puts("Nothibg to do")
end


