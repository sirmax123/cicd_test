# Description

This cookbook installs only nexus and provides few typical configurations.
It doesn't install or depends on java, apache, nginx, etc...

## Usage

Default recipe only creates user/group and arks nexus.
You are free to do anything with installation.

It better to you to wrap this cookbook in yours' company cookbook.


# HWRP

TODO: Currently this cookbook doesn't contain any HWRPs, but I hope if will be ever fixed

# Examples

You can visit fixture cookbook [test-nexus](test/fixtures/cookbooks/test-nexus)

# Requirements

## Platform:

* debian
* ubuntu
* centos

## Cookbooks:

* ark

# Attributes

* `node['nexus']['download_url']` -  Defaults to `http://download.sonatype.com/nexus/oss/nexus-2.11.2-06-bundle.tar.gz`.
* `node['nexus']['checksum']` -  Defaults to `e3fe7811d932ef449fafc4287a27fae62127154297d073f594ca5cba4721f59e`.
* `node['nexus']['version']` -  Defaults to `2.11.2-06`.
* `node['nexus']['user']` -  Defaults to `nexus`.
* `node['nexus']['group']` -  Defaults to `nexus`.
* `node['nexus']['dir']` -  Defaults to `/opt`.
* `node['nexus']['lock']` -  Defaults to `/var/lib/nexus/nexus.lock`.
* `node['nexus']['conf']['application-port']` -  Defaults to `8081`.
* `node['nexus']['conf']['application-host']` -  Defaults to `0.0.0.0`.
* `node['nexus']['conf']['nexus-webapp']` -  Defaults to `${bundleBasedir}/nexus`.
* `node['nexus']['conf']['runtime']` -  Defaults to `${bundleBasedir}/nexus/WEB-INF`.
* `node['nexus']['conf']['nexus-webapp-context-path']` -  Defaults to `/`.
* `node['nexus']['conf']['nexus-work']` -  Defaults to `/var/lib/nexus`.
* `node['nexus']['wrapper']['init_mem']` -  Defaults to `256`.
* `node['nexus']['wrapper']['max_mem']` -  Defaults to `768`.

# Recipes

* simple-nexus::default

# License and Maintainer

Maintainer:: Yauhen Artsiukhou (<jsirex@gmail.com>)
Source:: https://github.com/jsirex/simple-nexus-cookbook
Issues:: https://github.com/jsirex/simple-nexus-cookbook/issues

License:: Apache
