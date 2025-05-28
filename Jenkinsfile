pipeline {
    agent any

    environment {
        // ECR 정보
        AWS_REGION = "ap-northeast-2"
        ECR_REPO = "521199095756.dkr.ecr.ap-northeast-2.amazonaws.com/ecr-webgoat"
        IMAGE_TAG = "latest"

        // Dependency-Track 정보
        DEP_TRACK_URL = "http://43.203.218.149:8081/api/v1/bom"
        DEP_TRACK_PROJECT_ID = "2acd1e75-76d1-459d-a9d9-ac1df1a7b750"
    }

    stages {
        stage('📦 Checkout') {
            steps {
                git url: 'https://github.com/kara10041/WebGoat.git', branch: 'main', credentialsId: 'github-credentials'
            }
        }

        stage('🧾 Generate SBOM (Syft)') {
            steps {
                sh '''
                which syft || curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
                syft packages . -o cyclonedx-json > sbom.json
                ls -lh sbom.json
                '''
            }
        }

        stage('🐳 Docker Build & Push to ECR') {
            steps {
                withAWS(region: "${AWS_REGION}", credentials: 'aws-ecr-credentials') {
                    sh """
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_REPO

                        docker build -t $ECR_REPO:$IMAGE_TAG .
                        docker push $ECR_REPO:$IMAGE_TAG
                    """
                }
            }
        }

        stage('📤 Upload SBOM to Dependency-Track') {
            steps {
                withCredentials([string(credentialsId: 'dependency-track-api-key', variable: 'DT_API_KEY')]) {
                    sh '''
                    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
                      -H "X-Api-Key: $DT_API_KEY" \
                      -F "project=${DEP_TRACK_PROJECT_ID}" \
                      -F "bom=@sbom.json" \
                      ${DEP_TRACK_URL})

                    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
                      echo "✅ SBOM successfully uploaded (HTTP $HTTP_CODE)"
                    else
                      echo "❌ Failed to upload SBOM (HTTP $HTTP_CODE)"
                      exit 1
                    fi
                    '''
                }
            }
        }
    }
}
