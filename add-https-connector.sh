#!/bin/bash

# Wait until log file is created

function wait_until_wildfly_started {
    while [ ! -f $JBOSS_HOME/standalone/log/server.log ]
    do
        sleep 1
    done
    while read LOGLINE
    do
        if [[ "${LOGLINE}" == *"WildFly Web Lite 9.0.0.Beta1 (WildFly Core 1.0.0.Beta2) started"* ]]
        then
            break
        fi
    done < <(tail -1f $JBOSS_HOME/standalone/log/server.log)
}

wait_until_wildfly_started

function cli {
    ./bin/jboss-cli.sh -u=admin -p=admin -c "$1"
}

echo "Adding HTTPS connector..."
cli "--command=/core-service=management/security-realm=https:add()"
cli "--command=/core-service=management/security-realm=https/authentication=truststore:add(keystore-path=server.truststore, keystore-password=password, keystore-relative-to=jboss.server.config.dir)"
cli "--command=/core-service=management/security-realm=https/server-identity=ssl:add(keystore-path=server.keystore, keystore-password=password, keystore-relative-to=jboss.server.config.dir)"
cli "--command=/subsystem=undertow/server=default-server/https-listener=https:add(socket-binding=https, security-realm=https, enable-http2=true)"
cli "--command=/interface=public/:write-attribute(name=inet-address,value=0.0.0.0)"
cli "--command=/:reload"

wait_until_wildfly_started
echo HTTPS connector started on port 8443
