
# STAGE 2.
Create release infrastructure using local Vagrant/Chef.
Repository in GitLab as well as base jobs in Jenkins should be pre-created.
Sources must be pushed manually to pre-created repository.


## Getting Started

### Prerequisites

You need Oracle VirtualBox  and Vagrant with  vagrant-vbguest vagrant-hosts plugins installed.

You can install plugins from CLI with commands:
```
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hosts
```

Host system with vagrant also will be configured as Jenkins slave node to be able to create 
dynamic jenkins slave nodes.

So it should be enabled ssh access and user should be pre-created.

Default user is defined in Vagrantfile:
```

vagrant_user = {
  username: 'jenkins',
  password: 'jenkins123'
}
```
So you should pre-create this user on your host system. 
(Vagrant host tested on Mac OS X only, 16Gb RAM is recomended)


### Install Env.


```
git clone https://github.com/sirmax123/cicd_test.git
```

```
cd cicd_test
```
``` 
vagrant up
```

For deployment we need 3 infrastructure nodes:
- GitLab Node (git server)
- Nexus (Artifact storage)
- Jenkins

Vagrant file and chef cookbooks are designet to install and configure all
infrastrucure nodes.

As result we'll have all nodes installed and configured, all items like
git repos, nexus repos, jenkins jobs, users, groups, plugins, permissions etc.

All usernames/passwords can be found in Vagrantfile

ToBeFixed: some names/password are hardcoded in cookbooks, will fix in next version.

Note:
Some plugins are rebuild during installation to add Pipeline plugin support.

### Verify installation:

- jenkins: http://10.0.1.10:8080/ (login: root, password: r00tme)
- nexus: http://10.0.1.12:8081/nexus/ (admin user: admin/admin123, upload user: chucknorris/chucknorris)
- GitLab: http://http://10.0.1.11 (admin user: root/r00tme123, other user details can be found in Vagrantfile `gitlab: users: [ ... ]` )




## How to work with env

### Known issues and limitations
Env. is created for demo, so there are some known limitations

1. Only one petclinic env can be created simultaneously. This will be fixed in next version, but to do this need to create jobs which will provide IP addresses managenet like assign/release IP addresses, configure IP routing etc. So it is not implemented now.

2.  Env name ('dynamic-node') is hardcoded now (because we are support now only one application env., see 1.)

3. Some usernames/password are still hardcoded (work is in progress)

4. ????


### Deploy Java Petclinic demo app with Jenkins jon

Repository with petclinic app. is pre-created and populated so it is possible to start deploy in 2 ways:

1. Run manually job with name 'trigger'. It will trigger all workflow and in case of success petclinic app will be accessable at: ??

2. `git push`  to git@10.0.1.11:cicd/petclinic.git repo  on pre-installed GitLab server. Job will be triggered automatically. 


###  Verify deployment:

Open petclininc:

 - http://10.0.10.200/petclinic/




## Jobs explanation



```
+---------+
| trigger |      Can be started manually or triggerd by commit
+---------+       (all parameters are hardcoded)
     |
     |
     |
+---------+ <--- Job which is in fact just wrapper for other jobs
|  all    |
|         |                      +------------------+                                                                   
|         | => build artifact => | build_petclinic  |----+                                                                                                     
|         |                      +------------------+    |                                                  
|         |                                              |                                      
|         |                                              |                                      
|         | <=  return build object ---------------------+                                      
|         |                                                                                                                                                          
|         |                                                                  +---------------+                   
|         | => publish artifact (from object reurned by build_petclinic ) => | up (publish)  |--+                                                                    
|         |                                                                  +---------------+  |                                                                
|         | <= return build object (artifact: link to nexus)  ----------------------------------+
|         |        
|         |    +----------------------------+                                                                        
|         | => | create_all_in_one_env      |-+    <- Create new node using Vagrant Slave                                                                        
|         |    +----------------------------+ |                 
|         | <---------------------------------+
|  - - - - -TRY BLOCK - - - - - - - - - - - - - - - - - - - - - 
|              
|             +-------------------+                                                                      
|          => | add_dynamic_slave |-+  Register created node as new Jenkins slave
|             +-------------------+ |                                                            
|          <= ----------------------+                                                            
|                                                                                               
|             +-------------+                                                                               
|          => |test_slave   |  Do sanity tests of slave
|             +-------------+                                                                                  
|                                                                                                                     
|             +---------------+                                   +------------+                                              
|          => | deploy_tomcat |---if tomcat was not built before? |build_tomcat|-+                                                                               
|             |               |                                   +------------+ |              
|             |               | < ----return tomcat RPM--------------------------+              
|             +---------------+                                                                                  
|                                                                                               
|             +------------------+      
|          => | deploy_petclininc|-+                                                                                 
|             +------------------+ |                                                                                 
|          <= ---------------------+                                                                                      
|  stage("Do Tests")                                                                                             
|                                                                                               
|  - - - - -CATCH BLOCK - - - - - - - - - - - - - - - - - - - - -                                                                                              
|      Here: calculate do we need to destroy env if deployment fail                                                                                         
|                                                                                               
|  - - - - -FINALLY BLOCK - - - - - - - - - - - - - - - - - - - -                                                                                             
|                                                                                               
|     Destroy or keep env (depends on status of deployment and settings)                                                                                         
|          |
|          |
+----------+
```













                                                                                               