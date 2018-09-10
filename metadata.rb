name             'wsi_tomcat'
maintainer       'Ivan Suftin'
maintainer_email 'isuftin@usgs.gov'
license          'CPL-1.0'
description      'Installs and configures the Apache Tomcat servlet container '
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          '1.2.3'
supports         'centos', '>= 6.0'
supports         'centos', '>= 7.0'
chef_version     '>= 12.0.0'
depends 'java'

source_url 'https://github.com/USGS-CIDA/cookbook-tomcat'
issues_url 'https://github.com/USGS-CIDA/cookbook-tomcat/issues'
