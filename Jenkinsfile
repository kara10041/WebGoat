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

    stage('🤖 Java 버전 추출') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'bedrock-aws-key']]) {
          sh 'python3 components/scripts/pom_to_docker_image.py > java_version.txt'
        }
      }
    }

    stage('🪄 도커 이미지 추천') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'bedrock-aws-key']]) {
          script {
            def javaVersion = readFile('java_version.txt').trim()
            env.JAVA_VERSION = javaVersion
          }
          sh 'python3 components/scripts/bedrock_docker_recommend.py > docker_image.txt'
          script {
            env.DOCKER_IMAGE = readFile('docker_image.txt').trim()
          }
        }
      }
    }

    stage('📑 SBOM 생성 & 업로드') {
      steps {
        script {
          sh "docker run --rm -v \$(pwd):/src ${env.DOCKER_IMAGE} cdxgen analyze -o bom.json"
          sh "./components/scripts/upload_to_dtrack.sh ${env.DTRACK_URL} ${env.DTRACK_UUID} ${env.DTRACK_APIKEY} bom.json"
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
