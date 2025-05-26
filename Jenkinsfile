pipeline {
    agent any

    environment {
        ECR_REPO     = "521199095756.dkr.ecr.ap-northeast-2.amazonaws.com/ecr-webgoat"
        IMAGE_TAG    = "latest"
        S3_BUCKET    = "webgoat-bucket0225"
        DEPLOY_APP   = "webgoat-app2"
        DEPLOY_GROUP = "webgoat-bluegreen"
        REGION       = "ap-northeast-2"
        BUNDLE       = "webgoat-deploy-bundle.zip"
    }

    stages {
        stage('📦 Checkout') {
            steps {
                checkout scm
            }
        }

        stage('⚙️ Build') {
            steps {
                sh './mvnw clean install -DskipTests -Dexec.skip=true'
            }
        }


        stage('🔍 Snyk Dependency Scan (Plugin)') {
    steps {
        withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
            snykSecurity(
                snykInstallation: 'snyk-default',
                snykTokenId: 'snyk-token'    
                targetFile: 'pom.xml',
                failOnIssues: true
            )
        }
    }
}


        stage('🐳 Docker Build & Tag') {
            steps {
                sh '''
                docker build -t $ECR_REPO:$IMAGE_TAG .
                '''
            }
        }

        stage('🔍 Snyk Image Scan (Docker CLI)') {
            steps {
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh '''
                    docker run --rm \
                      -e SNYK_TOKEN=$SNYK_TOKEN \
                      snyk/snyk-cli:docker test $ECR_REPO:$IMAGE_TAG
                    '''
                }
            }
        }
        
        stage('🔐 ECR Login') {
            steps {
                withAWS(credentials: 'aws-ecr-credentials', region: "${REGION}") {
                    sh '''
                    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('🚀 Push to ECR') {
            steps {
                sh 'docker push $ECR_REPO:$IMAGE_TAG'
            }
        }

        stage('🧩 Generate taskdef.json') {
            steps {
                script {
                    def taskdef = """{
  "family": "webgoat-taskdef",
  "networkMode": "awsvpc",
  "containerDefinitions": [
    {
      "name": "webgoat",
      "image": "${ECR_REPO}:${IMAGE_TAG}",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ]
    }
  ],
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::521199095756:role/ecsTaskExecutionRole"
}"""
                    writeFile file: 'taskdef.json', text: taskdef
                }
            }
        }

        stage('📄 Generate appspec.yaml') {
            steps {
                script {
                    def taskDefArn = sh(
                        script: "aws ecs register-task-definition --cli-input-json file://taskdef.json --query 'taskDefinition.taskDefinitionArn' --region $REGION --output text",
                        returnStdout: true
                    ).trim()

                    def appspec = """version: 1
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "${taskDefArn}"
        LoadBalancerInfo:
          ContainerName: "webgoat"
          ContainerPort: 8080
"""
                    writeFile file: 'appspec.yaml', text: appspec
                }
            }
        }

        stage('📦 Bundle for CodeDeploy') {
            steps {
                sh 'zip -r $BUNDLE appspec.yaml Dockerfile taskdef.json'
            }
        }

        stage('🚀 Deploy via CodeDeploy') {
            steps {
                sh '''
                aws s3 cp $BUNDLE s3://$S3_BUCKET/$BUNDLE --region $REGION

                aws deploy create-deployment \
                  --application-name $DEPLOY_APP \
                  --deployment-group-name $DEPLOY_GROUP \
                  --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
                  --s3-location bucket=$S3_BUCKET,bundleType=zip,key=$BUNDLE \
                  --region $REGION
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Successfully built, scanned, pushed, and deployed!"
        }
        failure {
            echo "❌ Build or deployment failed. Check logs!"
        }
    }
}
