pipeline {
  agent none   // 전체 agent는 지정하지 않고, stage별로 지정

  environment {
    REGION = "ap-northeast-2"
    REPO_URL = "https://github.com/WebGoat/WebGoat.git"
    DTRACK_URL = "http://172.31.4.194:8081"
    DTRACK_APIKEY = "odt_S7E3bsCU_FRvF9D0e5Iq7JSGDfbzwIVPLOp7ieZzt"
  }

  stages {
    stage('📦 Checkout') {
      agent any   // master or 아무 agent에서 체크아웃
      steps {
        checkout scm
      }
    }

    stage('SCA 병렬 실행 (Throttle 적용)') {
      agent { label 'SCA' }    // SCA label을 가진 slave에서 실행
      steps {
        script {
          def targets = sh(
            script: "ls -d */ | sed 's#/##'",
            returnStdout: true
          ).trim().split('\n')

          def jobs = targets.collectEntries { target ->
            ["${target}" : {
              throttle(['sca-category']) {
                stage("SCA for ${target}") {
                  sh "/home/ec2-user/run_sbom_pipeline.sh '${target}'"
                }
              }
            }]
          }
          parallel jobs
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
