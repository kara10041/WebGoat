pipeline {
  agent any

  environment {
    REGION = "ap-northeast-2"
    FUNCTION_NAME = "cdxgen-sbom"
    IMAGE_TAG = "latest"
    REPO_URL = "https://github.com/WebGoat/WebGoat.git" 
    SCAN_ID = "scan-${new Date().format('yyyyMMddHHmmss')}"
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

    stage('SBOM Scan & Upload') {
      steps {
        sshagent(['sbom_analysis_ssh']) {
          sh '''
            ssh -o StrictHostKeyChecking=no ec2-user@13.125.155.126 "/home/scan/scan_and_upload.sh \
              \\"${REPO_URL}\\" \
              \\"${DTRACK_URL}\\" \
              \\"${DTRACK_UUID}\\" \
              \\"${DTRACK_APIKEY}\\""
          '''
        }
      }
    }
      
  post {
    success {
      echo "🎉 전체 빌드 및 SBOM 업로드까지 완료!"
    }
    failure {
      echo "❌ 파이프라인 실패! 로그 확인 필요"
    }
  }
}
