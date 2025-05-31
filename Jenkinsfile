pipeline {
  agent any

  environment {
    REGION = "ap-northeast-2"
    FUNCTION_NAME = "trivy-ssm-lambda"
    IMAGE_TAG = "latest"
    REPO_URL = "https://github.com/kara10041/WebGoat.git"
    ECR_REPO = "521199095756.dkr.ecr.ap-northeast-2.amazonaws.com/trivy-test"
    SCAN_ID = "scan-${new Date().format('yyyyMMddHHmmss')}"
  }

  stages {
    stage('📦 Checkout') {
      steps {
        checkout scm
      }
    }

    stage('📤 Upload Trivy Scan Request') {
      steps {
        sh '''
          chmod +x scripts/trivy-scan-request.sh
          ./scripts/trivy-scan-request.sh
        '''
      }
    }

  post {
    success {
      echo "🎉 전체 빌드 및 Trivy 스캔 완료!"
    }
    failure {
      echo "❌ 파이프라인 실패! 로그 확인 필요"
    }
  }
}
