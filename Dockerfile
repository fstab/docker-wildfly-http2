FROM java:openjdk-8u40
MAINTAINER Fabian Stäber, fabian@fstab.de

#############
# http://undertow.io/blog/2015/03/26/HTTP2-In-Wildfly.html
#############

EXPOSE 8443

# Pin JDK version, because the current Wildfly HTTP/2 beta support needs JDK 1.8.0u40
RUN \
    echo "Package: openjdk-8-jdk"          >> /etc/apt/preferences && \
    echo "Pin: version 8u40-b27-1"         >> /etc/apt/preferences && \
    echo "Pin-Priority: 1001"              >> /etc/apt/preferences && \
    echo                                   >> /etc/apt/preferences && \
    echo "Package: openjdk-8-jre"          >> /etc/apt/preferences && \
    echo "Pin: version 8u40-b27-1"         >> /etc/apt/preferences && \
    echo "Pin-Priority: 1001"              >> /etc/apt/preferences && \
    echo                                   >> /etc/apt/preferences && \
    echo "Package: openjdk-8-jre-headless" >> /etc/apt/preferences && \
    echo "Pin: version 8u40-b27-1"         >> /etc/apt/preferences && \
    echo "Pin-Priority: 1001"              >> /etc/apt/preferences

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get -y install vim

# Set the locale (I want to use UTF-8 characters)
RUN apt-get install -y locales && \
    echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the timezone (change this to your local timezone)
RUN echo "Europe/Berlin" | tee /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Configure JDK
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV PATH "$JAVA_HOME/bin:$PATH"

# Create user wildfly
RUN adduser --disabled-login --gecos '' wildfly

# Install Wildfly in /home/wildfly
WORKDIR /home/wildfly
RUN wget http://download.jboss.org/wildfly/9.0.0.Beta1/wildfly-9.0.0.Beta1.tar.gz && \
    tar xfz wildfly-9.0.0.Beta1.tar.gz
ENV JBOSS_HOME=/home/wildfly/wildfly-9.0.0.Beta1

# fake certification for testing
WORKDIR /home/wildfly/wildfly-9.0.0.Beta1/standalone/configuration
RUN \
    wget https://raw.githubusercontent.com/undertow-io/undertow/master/core/src/test/resources/server.keystore && \
    wget https://raw.githubusercontent.com/undertow-io/undertow/master/core/src/test/resources/server.truststore

# alpn
WORKDIR /home/wildfly/wildfly-9.0.0.Beta1/bin
RUN \
    wget http://central.maven.org/maven2/org/mortbay/jetty/alpn/alpn-boot/8.1.3.v20150130/alpn-boot-8.1.3.v20150130.jar && \
    echo 'JAVA_OPTS="$JAVA_OPTS' " -Xbootclasspath/p:$JBOSS_HOME/bin/alpn-boot-8.1.3.v20150130.jar" '"' >> /home/wildfly/wildfly-9.0.0.Beta1/bin/standalone.conf

# configure management user
WORKDIR /home/wildfly/wildfly-9.0.0.Beta1/standalone/configuration
RUN \
    echo                                          >> mgmt-users.properties && \
    echo '# username: admin, password: admin'     >> mgmt-users.properties && \
    echo 'admin=c22052286cd5d72239a90fe193737253' >> mgmt-users.properties

# Finalize installation

ADD add-https-connector.sh /home/wildfly/add-https-connector.sh
RUN \
    chown -R wildfly.wildfly /home/wildfly/wildfly-9.0.0.Beta1 && \
    chown wildfly.wildfly /home/wildfly/add-https-connector.sh
USER wildfly
WORKDIR /home/wildfly/wildfly-9.0.0.Beta1
ENTRYPOINT bash -c '/home/wildfly/add-https-connector.sh & ./bin/standalone.sh ; ./bin/standalone.sh'
