pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-northeast-2'
        ECR_REPO = '521199095756.dkr.ecr.ap-northeast-2.amazonaws.com/ecr-webgoat'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withAWS(credentials: 'aws-ecr-credentials', region: "${AWS_REGION}") {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push to ECR') {
            steps {
                sh 'docker push $ECR_REPO:$IMAGE_TAG'
            }
        }
    }

    post {
        success {
            echo "✅ ECR에 Docker 이미지가 성공적으로 푸시되었습니다!"
        }
        failure {
            echo "❌ ECR 푸시에 실패했습니다. 로그를 확인하세요."
        }
    }
}
