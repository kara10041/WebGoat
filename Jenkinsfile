pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/kara10041/WebGoat.git'
        REPO_NAME = 'WebGoat'
    }

    stages {
        stage('📦 Dummy Build') {
            steps {
                echo '🔧 빌드 단계 진행 중...'
                sh 'sleep 2'
            }
        }

        stage('🔍 Dummy Test') {
            steps {
                echo '🧪 테스트 단계 진행 중...'
                sh 'sleep 2'
            }
        }

        stage('🚀 Background SCA (SBOM)') {
            steps {
                script {
                    def buildId = env.BUILD_NUMBER
                    def logFile = "/home/ec2-user/logs/sbom_${buildId}.log"

                    sh """
                        chmod +x /home/ec2-user/run_sbom_pipeline.sh
                        chmod -R u+rwX /tmp/${REPO_NAME} || true
                        nohup /home/ec2-user/run_sbom_pipeline.sh '${REPO_URL}' '${REPO_NAME}' '${buildId}' > '${logFile}' 2>&1 || echo '[❌] SCA 실행 실패' >> /home/ec2-user/logs/debug.log &
                    """

                    echo "✅ SCA 백그라운드 실행됨! 로그 경로: ${logFile}"
                }
            }
        }

        stage('🗃️ Dummy Archive') {
            steps {
                echo '📁 아티팩트 저장 중...'
                sh 'sleep 1'
            }
        }
    }

    post {
        success {
            echo '🎉 파이프라인 완료!'
        }
        failure {
            echo '💥 실패: 로그 확인 필요'
        }
    }
}
