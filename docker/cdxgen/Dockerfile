FROM amazonlinux:2023

RUN dnf install -y java-17-amazon-corretto curl git

RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - \
    && dnf install -y nodejs
    
RUN npm install -g @cyclonedx/cdxgen

WORKDIR /app

ENTRYPOINT ["cdxgen"]


