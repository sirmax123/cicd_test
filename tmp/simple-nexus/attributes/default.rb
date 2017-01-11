default['nexus']['download_url'] = 'http://download.sonatype.com/nexus/oss/nexus-2.11.2-06-bundle.tar.gz'
default['nexus']['checksum'] = 'e3fe7811d932ef449fafc4287a27fae62127154297d073f594ca5cba4721f59e'
default['nexus']['version'] = '2.11.2-06'

default['nexus']['user'] = 'nexus'
default['nexus']['group'] = 'nexus'
default['nexus']['dir'] = '/opt'
default['nexus']['lock'] = '/var/lib/nexus/nexus.lock'

# Nexus properties
default['nexus']['conf']['application-port'] = '8081'
default['nexus']['conf']['application-host'] = '0.0.0.0'
default['nexus']['conf']['nexus-webapp'] = '${bundleBasedir}/nexus'
default['nexus']['conf']['runtime'] = '${bundleBasedir}/nexus/WEB-INF'
default['nexus']['conf']['nexus-webapp-context-path'] = '/'
default['nexus']['conf']['nexus-work'] = '/var/lib/nexus'

# Wrapper properties
default['nexus']['wrapper']['init_mem'] = '256'
default['nexus']['wrapper']['max_mem'] = '768'
