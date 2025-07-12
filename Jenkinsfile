pipeline {
    agent any

       environment {
        BUILD_ID = "${env.BUILD_NUMBER}"
        AWS_REGION = 'ap-northeast-2'
        ECR_REPO = 'test/test-api'
        IMAGE_TAG = "${env.BUILD_ID}" 
        ACCOUNT_ID = "521199095756"
        ECR_BASE_URI = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_URI = "${ECR_BASE_URI}/${ECR_REPO}"
    }

    stages {
        stage('🌱 Dummy: Git Checkout') {
            steps {
                echo '📁 Git 클론 더미 처리 중...'
                sh 'sleep 1'
            }
        }

        stage('🧪 Dummy: Build') {
            steps {
                echo '🔨 빌드 더미 처리 중...'
                sh 'sleep 1'
            }
        }

        stage('🚀 Background SCA (SBOM)') {
            steps {
                script {
                    def repoUrl = 'https://github.com/kara10041/WebGoat.git'
                    def repoName = 'WebGoat'
                    def buildId = env.BUILD_NUMBER

                    // 백그라운드 실행
                    sh """
                        setsid /home/ec2-user/run_sbom_pipeline.sh '${repoUrl}' '${repoName}' '${buildId}' > /dev/null 2>&1 &
                    """
                    echo '✅ SCA 백그라운드 실행됨!'
                }
            }
        }

        stage('🎯 Dummy: Deploy') {
            steps {
                echo '🚀 배포 더미 처리 중...'
                sh 'sleep 1'
            }
        }
    }

    post {
        always {
            echo "🎉 파이프라인 종료"
        }
    }
}
