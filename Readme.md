# CICD test task

## STAGE 1.
Create infrastructure for Petclinic application using local Vagrant/Chef.
Infrastructure should consist of one MySQL, one Tomcat, one Apache nodes.

## STAGE 2.
Create release infrastructure using local Vagrant/Chef.
Repository in GitLab as well as base jobs in Jenkins should be pre-created.
Sources must be pushed manually to pre-created repository.

## STAGE 3.
Migrate both infrastructures to Tonomi/AWS.

## STAGE 4.1.
Make application infrastructure more universal, creating independent components which are driven by external commands.

## STAGE 4.2.
Add reconfiguration capabilities to application environment, by dynamically reacting on artifact changes and number of application nodes changes.


## Getting Started

### Prerequisites

You need Oracle VirtualBox  and Vagrant with  vagrant-vbguest vagrant-hosts plugins installed.

You can install plugins from CLI with commands:
```
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hosts
```

### Installing


```
git clone https://github.com/sirmax123/cicd_test.git
```

```
cd cicd_test
```


## Running

### Stage1
#### Run application

Befor you start, please pay your attention: running  env will take a long 
time because petclinic and tomcat server will be build from source code as 
many times as many backends configured in Vagrantfile

It is done in this way because there are no artifact storage in this configuration. 

Check Vagrantfile and configure your own IP addreses for nodes if you need it.
By-default will be deployed 4 nodes
- 1 DB node with MySQL
- 2 Backend nodes (Tomcat/Petclinic)
- 1 Frontend node (Apache in proxy mode)

```
cd  stage1
```

```
vagrant up
```
For demo reason will be created 2 MySQL databases (First is used for Petclinic, second is created but not used)

You can create any number of backend instances, just configure additional nodes in  `nodes = { ... }` and section in `app_config = { ... }`


e.g you can add tomcat3, with correct ip (see `tomcat3[:ip]`): and custom configuration differs from tomcat1 and 2. Or just copy tomcat1 and change ip.
```
nodes = {
  db: {
    ...
  },
  tomcat1: {
    ...
  },
  tomcat2: {
     ...
  }
  tomcat3: {
    instance_type: 'backend',
    box: 'centos/6',
    ip: 'FIX_IP_HERE',
    roles: [
      'misc',
      'petclinic_pre_configure'
    ],
    'shell_scripts_pre_chef': [
      {
        'inline': 'echo PRE_CHEF_TEST_SCRIPT'
      }
    ],  
    'shell_scripts_post_chef': [
      {
        'inline': 'whoami;  id; pwd'
      },
      {
        'path': '01_add_maven_repo_and_install_maven.sh' 
      },
      {
        'path': '02_build_and_install_or_update_tomcat.sh' 
      },
      {
        'path': '03_build_and_deploy_petclinic.sh'
      }      
    ]
    ... 
  },
```

```
app_config = {
  tomcat1: {
    ...
  },
  tomcat2: {
    ...
  },
  tomcat3: {
    chef_json: {
      misc: {
        packages_to_install: [
          ...
        ],
      },
      database_creds: sql_databases[:petclinic],
      database_host: nodes[:db][:ip]
    }
  },
  ...
```
All nodes marked as `instance_type: 'backend'` will be added to frontend load balancer.
#### Check deployment
By-default apache is configured on ip 10.0.1.5 and port 80
You can check PetClinic installation with you faivorite browser or with `curl`  cli tool

```
curl http://10.0.1.5/petclinic/owners.html?lastName=
```
#### stage1 know issues
* used cookbooks from SuperMarket, only wrappers are added
* need to check dependencies, looks like some unused cookbooks are added
* vm.cpu and vm.memory configuration are non supported  (added in stage2)
* add-some-more-issues-here



### Stage2

https://github.com/sirmax123/cicd_test/blob/master/stage2/ReadMe.md


### Stage3
Not implemented

### Stage4
Not implemented
