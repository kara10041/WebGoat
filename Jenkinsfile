pipeline {
  agent any

  environment {
    REGION = "ap-northeast-2"
    REPO_URL = "https://github.com/WebGoat/WebGoat.git"
    DTRACK_URL = "http://172.31.39.159:8080"
    DTRACK_APIKEY = "odt_3lLEAJkO_hI2Ywy5gM2NvhTLNwi8aOTupPKpaV45o"
  }

  stages {
    stage('📦 Checkout') {
      steps {
        checkout scm
      }
    }

    stage('도커 이미지 태그 결정') {
      steps {
        script {
          env.JAVA_VERSION = sh(
            script: "python3 components/scripts/pom_to_docker_image.py pom.xml",
            returnStdout: true
          ).trim()
            echo "[+] 사용 자바 버전: ${env.JAVA_VERSION}"
            
          env.IMAGE_TAG = sh(
            script: "python3 components/scripts/docker_tag.py ${env.JAVA_VERSION}",
            returnStdout: true
          ).trim()
        }
      }
    }

    stage('SBOM 생성&업로드') {
      steps {
        script {
          sh "bash components/scripts/run_cdxgen_test.sh ${env.IMAGE_TAG}"
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
