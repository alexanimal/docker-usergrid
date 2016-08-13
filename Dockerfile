############################################################
# Dockerfile to run Apache usergrid_
# Based on Ubuntu Image
############################################################

# Set the base image to use to Ubuntu
FROM ubuntu

MAINTAINER Gabor Wnuk <gabor.wnuk@me.com>

ENV TOMCAT_CONFIGURATION_FLAG /usergrid/.tomcat_admin_created
ENV DEBIAN_FRONTEND noninteractive
RUN mkdir /usergrid
WORKDIR /usergrid
RUN apt-get update
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:openjdk-r/ppa

###### UNCOMMENT IF YOU NEED ORACLE JAVA 8
#RUN add-apt-repository ppa:webupd8team/java
#RUN apt-get update
#RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
#RUN apt-get install -y oracle-java8-installer

RUN apt-get update; apt-get install -y wget pwgen openjdk-7-jdk tomcat7;

#
# Configure basic stuff, nothing important.
#
ADD create_tomcat_admin_user.sh /usergrid/create_tomcat_admin_user.sh
ADD run.sh /usergrid/run.sh
RUN chmod +x /usergrid/*.sh
RUN ln -s /etc/tomcat7/ /usr/share/tomcat7/conf
 
#
# Just to suppress tomcat warnings.
#
RUN mkdir -p /usr/share/tomcat7/common/classes; \
mkdir -p /usr/share/tomcat7/server/classes; \
mkdir -p /usr/share/tomcat7/shared/classes; \
mkdir -p /usr/share/tomcat7/webapps; \
mkdir -p /usr/share/tomcat7/temp

#
# Deploy WAR

RUN mkdir /usergrid/ROOT
ADD ROOT.war /usergrid/ROOT/ROOT.war

# ADD ROOT.war /usr/share/tomcat7/webapps/ROOT.war

#
# Port to expose (default for tomcat: 8080)
#
EXPOSE 8080

ENTRYPOINT ./run.sh
