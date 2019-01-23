#!/bin/bash
### BEGIN INIT INFO
# Provides:       orsystraining
# Required-Start: \$ALL
# Required-Stop:  
# Default-Start:  2 3 4 5
# Default-Stop:  
# Short-Description: Orsys Training SuiteCRM StartScript
# Description:  Orsys Training SuiteCRM StartScript
### END INIT INFO
 
#
# Patch the SuiteCRM DB configuration file
#
#   - Extract the parameters from the UserData into environment variables
#
curl http://169.254.169.254/latest/user-data > /tmp/currentUserData.txt
if grep -q '<h1>404 - Not Found</h1>' '/tmp/currentUserData.txt'; then
   # There is no UserData in this case
   echo "No UserData"
else
  . /tmp/currentUserData.txt
 
  #
  #   - Patching SuiteCRM DB configuration (with the values extracted from the UserData)
  #
  sed -i.bak -r "s/('db_host_name' => )('.*')/\1'\${RDS_HOSTNAME}'/g" /opt/bitnami/apps/suitecrm/htdocs/config.php
  sed -i -r "s/('db_port' => )('.*')/\1'\${RDS_PORT}'/g" /opt/bitnami/apps/suitecrm/htdocs/config.php
  sed -i -r "s/('db_user_name' => )('.*')/\1'\${RDS_DBMASTERUSER}'/g" /opt/bitnami/apps/suitecrm/htdocs/config.php
  sed -i -r "s/('db_password' => )('.*')/\1'\${RDS_DBMASTERPASSWORD}'/g" /opt/bitnami/apps/suitecrm/htdocs/config.php
 
  # Restart the SuiteCRM application to ensure that the DB configuration changes are taken into account
  service bitnami restart apache
fi