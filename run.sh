#!/bin/bash
#
# Based on https://github.com/tutumcloud/tutum-docker-tomcat
#

pushd /tmp/ROOT
jar xvf ./ROOT.war
jar -xf ./WEB-INF/lib/usergrid-config-1.0.0.jar

# make changes

if [[ ! -z "$CASSANDRA_URL" ]]; then
   sed "s/cassandra.url=.*/aaa=$CASSANDRA_URL/g" usergrid-default.properties
fi

# make jar of updated usergrid properties
jar cf usergrid-config-1.0.0.jar usergrid-default.properties

cp usergrid-config-1.0.0.jar ./WEB-INF/lib/
rm usergrid-config-1.0.0.jar usergrid-default.properties
cd ../

# make war
jar -cvf ROOT.war ROOT/*

rm -R ROOT/*
rmdir ROOT
cp ROOT.war /usr/share/tomcat7/webapps/ROOT.war

popd

if [ ! -f ${TOMCAT_CONFIGURATION_FLAG} ]; then
    /usergrid/create_tomcat_admin_user.sh
fi

exec /usr/share/tomcat7/bin/catalina.sh run
