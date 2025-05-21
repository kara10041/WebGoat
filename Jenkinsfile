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
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/kara10041/WebGoat.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t webgoat-image .
                docker tag webgoat-image $ECR_URI:$IMAGE_TAG
                '''
            }
        }

        stage('Login to ECR') {
            steps {
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
                sh 'docker push $ECR_URI:$IMAGE_TAG'
            }
        }

        stage('Deploy to ECS') {
            steps {
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
