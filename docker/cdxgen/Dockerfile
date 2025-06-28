FROM amazonlinux:2023   

# OpenJDK 17, git만 설치 (curl 설치 제외)
RUN dnf install -y java-17-amazon-corretto git && dnf clean all


RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - \
    && dnf install -y nodejs


RUN npm install -g @cyclonedx/cdxgen

WORKDIR /app

ENTRYPOINT ["cdxgen"]
