# CHANGELOG

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [UNRELEASED]

## [1.2.3] - 2018-09-10
### Updated
- [zmoore@usgs.gov] - Added httpMaxHeaderSize parameter to the SSL Connector in the server.xml template

## [1.2.2] - 2017-08-15
### Updated
- [jmorris@usgs.gov] - Updated metadata.platforms so cookbook could be uploaded to chef server

## [1.2.1] - 2017-08-15
### Updated
- [jmorris@usgs.gov] - Updated kitchen YAML so all test suites can converge
- [jmorris@usgs.gov] - Updated provider to look for certs in Java 10+ location
- [jmorris@usgs.gov] - Updated tomcat ERB file and defaulted endorsed_dirs to empty string
- [jmorris@usgs.gov] - Changed defaults for ...['cors']['allowed']['origins'] to be the empty string and ...['cors']['allowed']['support_credentials'] to be false. This should match the defaults set by tomcat
- [jmorris@usgs.gov] - Changed default tomcat version to be 8.5.32

## [1.2.0] - 2017-05-18
### Updated
- [isuftin@usgs.gov] - Switched changelog format
- [isuftin@usgs.gov] - In the manager client, the "get_deployed_applications"
function now performs retries
- [isuftin@usgs.gov] - Updated mime types in web.xml
- [isuftin@usgs.gov] - tomcat-users template xml header update
- [isuftin@usgs.gov] - Changed server.xml SSL protocol and APR ssl protocol to default
to org.apache.coyote.http11.Http11Nio2Protocol and org.apache.coyote.http11.Http11AprProtocol
respectively
- [isuftin@usgs.gov] - Updated logging.properties to meet 8.0.x installation. No
changes currently needed to work with 8.5.x as changes in 8.5.x are commented out.
- [isuftin@usgs.gov] - Updated catalina.properties template to conform to Tomcat 8.0.x
and update to 8.5.x properties
- [isuftin@usgs.gov] - Updated Catalina.policy template to remove comet and
introduce websockets - http://tomcat.apache.org/migration-85.html#Comet_support_removed
- [isuftin@usgs.gov] - Updated templates to not get key values using dot notation
- [isuftin@usgs.gov] - Now working with latest current Chef client version (14.1.1)
- [isuftin@usgs.gov] - Updated kitchen config to use latest PsiProbe app
- [isuftin@usgs.gov] - Changed calls to wsi_tomcat_instance and WsiTomCatInstance
to use tomcat_instance  

### Added
- [isuftin@usgs.gov] - *BREAKING CHANGE* Created a new recipe "undeploy_application"
 and moved the application undeploy functionality from the "deploy_application"
 recipe to this new recipe. If you previously depended on the "deploy_application"
 to also undeploy applications for you
- [isuftin@usgs.gov] - In the tomcat_application resource, added functionality
 to re-try if the "get deployed applications" function didn't work the first time
- [isuftin@usgs.gov] - For Tomcat 8.0.x, activated CometConnectionManagerValve in
 context.xml. For Tomcat 8.5.x, removed CometConnectionManagerValve entirely
- [isuftin@usgs.gov] - Added "LOGGING MANAGER" option to startup script
- [isuftin@usgs.gov] - Added "org.apache.catalina.security.SecurityListener.UMASK"
switch to Tomcat startup script
- [isuftin@usgs.gov] - Added default server opt in attributes to allow for faster startup time
- [isuftin@usgs.gov] - Added the ability to dictate via attributes how many attempts
to make to check for a running Tomcat server
- [isuftin@usgs.gov] - Added the ability to dictate via attributes how long to wait
for timeout when checking against a running Tomcat instance
- [isuftin@usgs.gov] - Added functionality to the Tomcat instance helper to allow
checking whether or not an instance is installed

### Fixed
- [isuftin@usgs.gov] - Fix version passing into update_context recipe
- [isuftin@usgs.gov] - Fixed the ruby_block in the download_libs recipe to be
compatible with newer versions of chef client

### Removed
- [isuftin@usgs.gov] - Removed minor OS version specifier from kitchen config
- [isuftin@usgs.gov] - Removed ruby block processing from most recipes and helpers
- [isuftin@usgs.gov] - Removed usage of ruby_block from the deploy_application recipe
- [isuftin@usgs.gov] - Removed the usage of the name attribute in resource calls

## [1.0.5]
### Updated
- [mamcderm@usgs.gov] - revert back to older style provisioner
- [mamcderm@usgs.gov] - copy new war file to tomcat for auto deploy
- [isutin@usgs.gov] - Update to metadata.rb to free up chef version
- [isutin@usgs.gov] - Update to allow more defined tomcat logging
- [isutin@usgs.gov] - Rubocop/rspec/etc fixes

## [1.0.4]
### Updated
- [isuftin@usgs.gov] - If there are new libs downloaded, Tomcat will restart immediately
- [isuftin@usgs.gov] - If the context.xml gets updates, Tomcat will restart immediately

## [1.0.3]
### Updated
- [isuftin@usgs.gov] - Updated method for delayed check for a running Tomcat

## [1.0.2]
### Added
- [isuftin@usgs.gov] - Created a new function (Helper::TomcatInstance.ready?) to
allow testing whether or not Tomcat is accepting connections. This is used internally
to verify if it is safe yet to begin deploying/undeploying applications.

## [1.0.1]
### Added
- [isuftin@usgs.gov] - Use the third party Java cookbook's java_home attribtue to
dictate JAVA_HOME for this cookbook. The Java cookbook version 1.47.0 introduced
breaking changes for this

## [1.0.0]
### Added
- [isuftin@usgs.gov] - Created a Tomcat application resource which provides the
ability to deploy and undeploy applications

## [0.2.5]
### Added
- [isuftin@usgs.gov] - Created a Tomcat Manager communication library

### Fixed
- [isuftin@usgs.gov] - Fixed a bug with application undeploying

## [0.2.4]
### Added
- [isuftin@usgs.gov] - Added recipe to update catalinaopts on a running server

### Fixed
- [isuftin@usgs.gov] - Fixed majority of Rubocop complaints

## [0.2.3]
### Updated
- [isuftin@usgs.gov] - Update Tomcat trust store

## [0.2.2]
### Fixed
- [isuftin@usgs.gov] - Quick fix for SSL configuration breaking

## [0.2.1]
### Fixed
- [isuftin@usgs.gov] - Fixing APR implementation.
- [isuftin@usgs.gov] - Fixing a breaking bug when some attributes were not included in server definitions

### Added
- [isuftin@usgs.gov] - Adding ability to add options to setenv
- [isuftin@usgs.gov] - Fleshing out server.xml options

## [0.2.0]
### Added
- [isuftin@usgs.gov] - Major switch to how context.xml resource parameters are set. Allowing cookbooks to pass parameters directly instead of translating. This saves me having to deal with what is probably useless maintenance.
- [isuftin@usgs.gov] - Added database testing to Kitchen suite
- [isuftin@usgs.gov] - Moved Java cookbook dependency version to Berksfile
- [isuftin@usgs.gov] - Set JAVA_HOME in .bashrc
- [isuftin@usgs.gov] - Adding more context.xml attributes
- [isuftin@usgs.gov] - Added APR installation recipe

### Fixed
- [isuftin@usgs.gov] - Fix how JAVA_HOME gets persisted to Tomcat scripts

## [0.1.13]
### Added
- [isuftin@usgs.gov] - Moved java installation out of dependencies cookbook. Should be done
	at a higher level outside of this cookbook
- [isuftin@usgs.gov] - Added DOI SSL helper cookbook to Berksfile. Only needs to exist in tests when
	testing on DOI network

## [0.1.13]
### Updated
- [isuftin@usgs.gov] - Updated to version 8.0.36 default for Tomcat.

### Added
- [isuftin@usgs.gov] - Added some documentation for getting SHA256 for binary

## [0.1.12]
### Updated
- [isuftin@usgs.gov] - Updated to version 8.0.36 default for Tomcat.

### Added
- [isuftin@usgs.gov] - Added some documentation for getting SHA256 for binary

## [0.1.11]
### Added
- [isuftin@usgs.gov] - Parameterized more context.xml templating

### Updated
- [isuftin@usgs.gov] - Updated CORS attribute parsing (Ruby hash entity vs string keys)

## [0.1.10]
### Added
- [isuftin@usgs.gov] - Added Tomcat resource action to undeploy an application
- [isuftin@usgs.gov] - Added Tomcat resource action to remove instances not in configuration

## [0.1.9]
### Added
- [isuftin@usgs.gov] - Added sensitivity to templates
- [isuftin@usgs.gov] - Added more attributes to put into context.xml and server.xml

### Fixed
- [isuftin@usgs.gov] - Fixed server opts updating

### Removed
- [isuftin@usgs.gov] - Removed the `application_name` attribute

### Updated
- [isuftin@usgs.gov] - Updated how encrypted data bags are accessed

## [0.1.8]
### Removed
- Removed requirement for specifying key location. Using default key location as according to Chef
- No longer taking certificates baked into encrypted data bag. Certificates are now either created on the fly or provided on the file system

## [0.1.7]
### Updated
- Updated default Tomcat version to install
- Updated Test Kitchen CentOS boxes to use mainly Bento box versions
- Moved default Java installation options to be defined outside of attributes (like in Test Kitchen)
- Moved some passwords into an encrypted data bag (and included documentation)

### Added
- Added more CentOS options to Test Kitchen
- Added STIG testing option to Test Kitchen
- Added more Serverspec testing
