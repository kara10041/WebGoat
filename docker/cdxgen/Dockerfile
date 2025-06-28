FROM openjdk:17-jdk

RUN apt-get update && apt-get install -y curl git

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

RUN npm install -g @cyclonedx/cdxgen

WORKDIR /app

ENTRYPOINT ["cdxgen"]

