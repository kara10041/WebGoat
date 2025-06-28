#!/bin/bash
if [ -f /app/pom.xml ]; then
  JAVA_VERSION=$(grep -oPm1 '(?<=<java.version>)[^<]+' /app/pom.xml)
elif [ -f /app/build.gradle ]; then
  JAVA_VERSION=$(grep -oPm1 '(?<=sourceCompatibility\s*=\s*[\'\"])[0-9]+' /app/build.gradle)
fi
JAVA_VERSION=${JAVA_VERSION:-17}
JDK_TAR="jdk-${JAVA_VERSION}.tar.gz"
if [ -f "/opt/${JDK_TAR}" ]; then
  tar -xzf "/opt/${JDK_TAR}" -C /opt/
  ln -s /opt/jdk-${JAVA_VERSION}* /opt/jdk
  export JAVA_HOME=/opt/jdk
  export PATH=$JAVA_HOME/bin:$PATH
else
  echo "지원하지 않는 JDK 버전: $JAVA_VERSION (파일 없음)"
  exit 1
fi
exec cdxgen "$@"
