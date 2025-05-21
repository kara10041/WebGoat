pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-northeast-2'
        ECR_REPO = 'test/test-api'
        IMAGE_TAG = "${env.BUILD_ID}"
        ACCOUNT_ID = "521199095756"
        ECR_BASE_URI = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_URI = "${ECR_BASE_URI}/${ECR_REPO}"
    }

    stages {
        stage('Clone from GitHub') {
            steps {
                echo "✅ [Clone] GitHub 저장소에서 코드를 클론합니다"
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/kara10041/WebGoat.git'
            }
        }

        stage('Build with Maven') {
            steps {
                echo "✅ [Build] Maven으로 빌드를 시작합니다"
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "✅ [Docker] Docker 이미지 빌드를 시작합니다"
                sh '''
                    docker build -t webgoat-image .
                    docker tag webgoat-image $ECR_URI:$IMAGE_TAG
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                echo "✅ [ECR Login] AWS ECR에 로그인합니다"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr-credentials'
                ]]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_BASE_URI
                    '''
                }
            }
        }

        stage('Push to ECR') {
            steps {
                echo "✅ [Push] Docker 이미지를 ECR로 푸시합니다"
                sh 'docker push $ECR_URI:$IMAGE_TAG'
            }
        }

        stage('Deploy to ECS') {
            steps {
                echo "✅ [Deploy] ECS 서비스에 새 이미지를 배포합니다"
                sh '''
                    aws ecs update-service \
                        --cluster webgoat-cluster \
                        --service webgoat-service \
                        --force-new-deployment \
                        --region $AWS_REGION
                '''
            }
        }
    }
}
