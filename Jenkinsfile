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
        stage('💼 Checkout') {
            steps {
                checkout scm
            }
        }

        stage('🧪 Install Dependency-Check (if needed)') {
            steps {
                echo "🌐 Dependency-Check 설치 확인 및 다운로드 중..."
                sh '''
                    if [ ! -f dependency-check/bin/dependency-check.sh ]; then
                        echo "🔽 dependency-check.sh 없음 → 다운로드 시작"
                        curl -L -o dc.zip https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip
                        unzip -q dc.zip
                        rm dc.zip
                        mv dependency-check* dependency-check
                        echo "✅ Dependency-Check 설치 완료"
                    else
                        echo "✅ 이미 dependency-check.sh 존재함 → 설치 삭제"
                    fi
                '''
            }
        }

        stage('📁 main/java 디렉토리 수도 생성') {
            steps {
                sh '''
                    echo "[📁 /src/main/java 수도 생성 시작]"
                    mkdir -p $WORKSPACE/src/main/java
                    echo "// Dummy Java file for Dependency-Check" > $WORKSPACE/src/main/java/Dummy.java
                    echo "[✅ /src/main/java 생성 완료]"
                '''
            }
        }

        stage('🔍 Dependency Check 실행') {
            steps {
                sh '''
                    echo "[🔍 Dependency Check 실행 시작]"
                            NVD_API_KEY=$NVD_API_KEY ./dependency-check/bin/dependency-check.sh \
                              --project WebGoat \
                              --scan ./src/main/java \
                              --format HTML \
                              --out ./dependency-check-report \
                              --prettyPrint \
                              --disableAssembly \
                              --failOnCVSS 7
                '''
            }
        }

        stage('📄 Publish Dependency Report') {
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

        // 이후 기존 Docker 빌드 및 배포 스테이지 유지
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
