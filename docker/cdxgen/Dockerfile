FROM amazonlinux:2023
RUN dnf install -y git curl && dnf clean all
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && dnf install -y nodejs
COPY jdk-17.tar.gz /opt/
COPY jdk-21.tar.gz /opt/
COPY jdk-23.tar.gz /opt/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN npm install -g @cyclonedx/cdxgen
WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
