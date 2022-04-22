#!/bin/bash

set -euo pipefail

eval JAVA_OPTS=\"${JAVA_OPTS}\"
eval CLASSPATH=\"${CLASSPATH}\"

if [ -n "${CLASSPATH}" ]; then
  export CLASSPATH="${CLASSPATH_DEFAULT}:${CLASSPATH}"
else
  export CLASSPATH="${CLASSPATH_DEFAULT}"
fi

if [ -n "${JAVA_OPTS}" ]; then
  export JAVA_OPTS="${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}"
else
  export JAVA_OPTS="${JAVA_OPTS_DEFAULT}"
fi

if [ -n "${PROMETHEUS_PORT}" ]; then
  export JAVA_OPTS="-javaagent:${HZ_HOME}/lib/jmx_prometheus_javaagent.jar=${PROMETHEUS_PORT}:${PROMETHEUS_CONFIG} ${JAVA_OPTS}"
fi

if [ -z "${LOGGING_LEVEL}" ]; then
  export LOGGING_LEVEL=INFO
fi

if [ "$(arch)" == "s390x" ]; then
  export LOGGING_PATTERN="%d [%highlight{%5p}{FATAL=red, ERROR=red, WARN=yellow, INFO=green, DEBUG=magenta}][%style{%t{1.}}{cyan}] [%style{%-10c}{blue}]: %m%n"
else
  export LOGGING_PATTERN="%d [%highlight{%5p}{FATAL=red, ERROR=red, WARN=yellow, INFO=green, DEBUG=magenta}] [%style{%t{1.}}{cyan}] [%style{%c{1.}}{blue}]: %m%n"
fi

# for 4.0.x backward compatibility
set +u
if [ -n "${HZ_LICENSE_KEY}" ]; then
  export HZ_LICENSEKEY="${HZ_LICENSE_KEY}"
fi

if [ -n "${TLS_ENABLED}" ]; then
  export HZ_NETWORK_SSL_ENABLED=${TLS_ENABLED}
fi
set -u

export JAVA_OPTS="${JAVA_OPTS}"

echo "########################################"
echo "# JAVA_OPTS=${JAVA_OPTS}"
echo "# CLASSPATH=${CLASSPATH}"
echo "# starting now...."
echo "########################################"
set -x
exec java -server ${JAVA_OPTS} com.hazelcast.core.server.HazelcastMemberStarter
