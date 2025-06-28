FROM amazonlinux:2023
RUN dnf install -y git && dnf clean all
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && dnf install -y nodejs

# JDK 바이너리 다운로드 
RUN wget -O /opt/jdk-17.tar.gz https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz
RUN wget -O /opt/jdk-21.tar.gz https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.tar.gz
RUN wget -O /opt/jdk-23.tar.gz https://corretto.aws/downloads/latest/amazon-corretto-23-x64-linux-jdk.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN npm install -g @cyclonedx/cdxgen
WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
