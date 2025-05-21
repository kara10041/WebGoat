pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-northeast-2'
        ECR_REPO = '521199095756.dkr.ecr.ap-northeast-2.amazonaws.com/test/test-api'
        IMAGE_TAG = "jenkins-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $ECR_REPO:$IMAGE_TAG ."
            }
        }

        stage('Login to ECR') {
            steps {
                sh "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO"
            }
        }

        stage('Push to ECR') {
            steps {
                sh "docker push $ECR_REPO:$IMAGE_TAG"
            }
        }

        stage('Update ECS Service') {
            steps {
                sh '''
                    aws ecs update-service \
                        --cluster webgoat-cluster \
                        --service webgoat-service \
                        --force-new-deployment \
                        --region ap-northeast-2
                '''
            }
        }
    }
}
