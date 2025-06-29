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
