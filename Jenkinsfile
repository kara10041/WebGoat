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

  
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t webgoat-image . '
                sh 'docker tag webgoat-image ${ECR_URI}:${IMAGE_TAG}'
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr-credentials'
                ]]) {
                    sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI'
                }
            }
        }

        stage('Push to ECR') {
            steps {
                sh 'docker push ${ECR_URI}:${IMAGE_TAG}'
            }
        }

        stage('Deploy to ECS via CodeDeploy') {
            steps {
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr-credentials'
                ]]) {
                    script {
                        def appspecContent = '''\
        version: 1
        Resources:
          - TargetService:
              Type: AWS::ECS::Service
              Properties:
                TaskDefinition: webgoat-task1
                LoadBalancerInfo:
                  ContainerName: webgoat
                  ContainerPort: 8080
                PlatformVersion: "LATEST"
        '''
                        writeFile file: 'appspec.yaml', text: appspecContent
                    }

                    sh '''
        echo "==== appspec.yaml 출력 ===="
        cat appspec.yaml
        echo "==========================="
        '''

                    sh 'aws s3 cp appspec.yaml s3://webgoat-codedeploy-bucket/appspec.yaml'

                    sh '''
        aws deploy create-deployment \
          --application-name webgoat-codedeploy \
          --deployment-group-name webgoat-deploy-group \
          --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
          --region ap-northeast-2 \
          --revision "revisionType=S3,s3Location={bucket=webgoat-codedeploy-bucket,key=appspec.yaml,bundleType=YAML}"
        '''
                }
            }
        }

    }
}
