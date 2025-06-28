pipeline {
  agent any

  environment {
    REGION = "ap-northeast-2"
    REPO_URL = "https://github.com/WebGoat/WebGoat.git"
    DTRACK_URL = "http://172.31.4.194:8081"
    DTRACK_UUID = "2acd1e75-76d1-459d-a9d9-ac1df1a7b750"
    DTRACK_APIKEY = "odt_S7E3bsCU_FRvF9D0e5Iq7JSGDfbzwIVPLOp7ieZzt"
  }

  stages {
    stage('📦 Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build CDXGEN Docker Image') {
      steps {
        sh 'docker build -t custom-cdxgen-java17:latest ./docker/cdxgen'
      }
    }

    stage('🤖 Java 버전 및 도커 이미지 추천') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'bedrock-aws-key']]) {
          sh 'python3 ./components/scripts/pom_to_docker_image.py ./pom.xml > output.txt'
          script {
            def lines = readFile('output.txt').split("\n")
            env.JAVA_VERSION = lines[0].trim()
            env.DOCKER_IMAGE = lines[1].trim()
            echo "Java Version: ${env.JAVA_VERSION}"
            echo "Docker Image: ${env.DOCKER_IMAGE}"
          }
        }
      }
    }

    stage('📑 SBOM 생성 & 업로드') {
      steps {
        script {
          // cdxgen 생성 시 방금 빌드한 커스텀 이미지 사용
          sh "docker run --rm -v \$(pwd):/app custom-cdxgen-java17:latest analyze -o sbom.json"
          sh "./components/scripts/upload_to_dtrack.sh ${env.DTRACK_URL} ${env.DTRACK_UUID} ${env.DTRACK_APIKEY} sbom.json"
        }
      }
    }
  }

  post {
    success {
      echo "✅ SBOM 생성 및 업로드 완료!"
    }
    failure {
      echo "❌ SBOM 생성 또는 업로드 실패. 로그 확인 필요."
    }
  }
}
