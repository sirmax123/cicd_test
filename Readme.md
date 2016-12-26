# CICD test task

STAGE 1.
Create infrastructure for Petclinic application using local Vagrant/Chef.
Infrastructure should consist of one MySQL, one Tomcat, one Apache nodes.

STAGE 2.
Create release infrastructure using local Vagrant/Chef.
Repository in GitLab as well as base jobs in Jenkins should be pre-created.
Sources must be pushed manually to pre-created repository.

STAGE 3.
Migrate both infrastructures to Tonomi/AWS.

STAGE 4.1.
Make application infrastructure more universal, creating independent components which are driven by external commands.

STAGE 4.2.
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


e.g you can add tomcat3:
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
    ip: '10.0.1.3',
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
    ],
    'port_pars': [
      {
        'guest': '8080',
        'host':  '8080',
      }
    ]
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
          'mc', 
          'telnet',
          'traceroute',
          'git',
          'ant',
          'redhat-lsb-core', 
          'java-1.8.0-openjdk-debug',
          'java-1.8.0-openjdk-src-debug',
          'java-1.8.0-openjdk-javadoc-debug',
          'java-1.8.0-openjdk-headless',
          'java-1.8.0-openjdk-headless-debug',
          'java-1.8.0-openjdk-devel-debug',
          'java-1.8.0-openjdk-demo-debug',
          'java-1.8.0-openjdk-demo',
          'java-1.8.0-openjdk-javadoc',
          'java-1.8.0-openjdk',
          'java-1.8.0-openjdk-devel',
          'java-1.8.0-openjdk-src',
          'rpmdevtools'
        ],
      },
      database_creds: sql_databases[:petclinic],
      database_host: nodes[:db][:ip]
    }
  },
  ...
```




### Stage2

### Stage3

### Stage4

