pipeline {
    agent any

    environment {
        ECR_REPO = "521199095756.dkr.ecr.ap-northeast-2.amazonaws.com/ecr-webgoat" 
        IMAGE_TAG = "latest"
        JAVA_HOME = "/usr/lib/jvm/java-17-amazon-corretto.x86_64"
        PATH = "${env.JAVA_HOME}/bin:${env.PATH}"
        S3_BUCKET = "webgoat-bucket0225"
        DEPLOY_APP = "webgoat-app2"
        DEPLOY_GROUP = "webgoat-bluegreen"
        REGION = "ap-northeast-2"
        BUNDLE = "webgoat-deploy-bundle.zip"
        NVD_API_KEY = credentials('nvd-api-key')
    }

    stages {
        stage('📦 Checkout') {
            steps {
                checkout scm
            }
        }

    stage('🧪 디버깅: Docker 쓰기 권한 확인') {
                steps {
                    sh '''
                    docker run --rm \
                      -v $PWD:/src \
                      ubuntu bash -c "touch /src/testfile && echo '[✅ SUCCESS]' || echo '[❌ FAIL]'"
                    '''
                }
            }
        

        stage('🔍 Dependency Check') {
            steps {
                sh '''
                mkdir -p dependency-check-report
        
                docker run --rm \
                  -u 1000:1000 \
                  -v $PWD:/src \
                  -e NVD_API_KEY=$NVD_API_KEY \
                  owasp/dependency-check:latest \
                  --scan /src/src/main/java \
                  --format HTML \
                  --out /src/dependency-check-report \
                  --exclude .mvn \
                  --exclude .git \
                  --exclude target \
                  --disableCentral \
                  --log level debug
                '''
            }
        }

        stage('🧪 디버깅: 리포트 디렉토리/파일 존재 여부') {
        steps {
            sh '''
            docker run --rm -v $PWD:/src ubuntu \
            bash -c "
            echo '[📂 /src 폴더 리스트]';
            ls -l /src;
            echo '[📂 /src/dependency-check-report 디렉토리 리스트]';
            ls -l /src/dependency-check-report || echo '[❌ 디렉토리 없음]';
            "
            '''
        }
    }

        
        stage('🔨 Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('🐳 Docker Build') {
            steps {
                sh '''
                docker build -t $ECR_REPO:$IMAGE_TAG .
                '''
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

        stage('📑 Publish Dependency Report') {
            steps {
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'dependency-check-report',
                    reportFiles: 'dependency-check-report.html',
                    reportName: 'Dependency Check Report'
                ])
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

