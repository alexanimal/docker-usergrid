#!/bin/bash
#
# Based on https://github.com/tutumcloud/tutum-docker-tomcat
#


echo "Adding ROOT.war to /usergrid"
pushd /usergrid/ROOT
jar xvf ./ROOT.war
rm ROOT.war
jar -xf ./WEB-INF/lib/usergrid-config-1.0.0.jar

# make changes

if [[ ! -z "$CASSANDRA_URL" ]]; then
   echo "Setting Cassandra host"
   sed -i "s/cassandra.url=.*/cassandra.url=$CASSANDRA_URL/g" ./usergrid-default.properties
fi

# make jar of updated usergrid properties
jar cf usergrid-config-1.0.0.jar usergrid-default.properties

cp usergrid-config-1.0.0.jar ./WEB-INF/lib/
rm usergrid-config-1.0.0.jar usergrid-default.properties

# make war
echo "Making ROOT.war"
jar -cvf ROOT.war .
mv ROOT.war ../
cd ../

rm -R ROOT/*
rmdir ROOT

echo "Adding ROOT.war to tomcat webapps"
cp ROOT.war /usr/share/tomcat7/webapps

popd

ln -s /usr/share/tomcat7/webapps/ /etc/tomcat7/webapps

if [ ! -f ${TOMCAT_CONFIGURATION_FLAG} ]; then
    /usergrid/create_tomcat_admin_user.sh
fi

exec /usr/share/tomcat7/bin/catalina.sh run