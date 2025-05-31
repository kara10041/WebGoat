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

    stage('🚀 Run Trivy Deployment Script') {
      steps {
        sh '''
          chmod +x scripts/trivy-deploy.sh
          bash scripts/trivy-deploy.sh \
            "$ECR_REPO" \
            "$IMAGE_TAG" \
            "$REPO_URL" \
            "$REGION" \
            "$FUNCTION_NAME" \
            "$SCAN_ID"
        '''
      }
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
