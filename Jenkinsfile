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


                    stage('🔍 Dependency Check (안전 실행)') {
                        steps {
                            writeFile file: 'run-depcheck.sh', text: '''#!/bin/bash
                    set -e
                    
                    echo "[📂 실제 Java 소스 파일 개수 확인]"
                    JAVA_COUNT=$(find ./src/main/java -type f -name "*.java" | wc -l)
                    echo "[ℹ️ 총 Java 파일 개수: $JAVA_COUNT]"
                    
                    if [ "$JAVA_COUNT" -eq 0 ]; then
                      echo "[⚠️ 경고: 분석할 .java 파일이 없습니다. Dependency-Check 실행 스킵]"
                      exit 0
                    fi
                    
                    echo "[✅ 파일 존재 확인 완료 - Dependency Check 실행 시작]"
                    mkdir -p ./dependency-check-report
                    
                    ./dependency-check/bin/dependency-check.sh \
                      --project WebGoat \
                      --scan ./src/main/java \
                      --format HTML \
                      --out ./dependency-check-report \
                      --prettyPrint \
                      --disableAssembly \
                      --failOnCVSS 7
                    '''
                    
                            sh 'chmod +x run-depcheck.sh'
                            sh './run-depcheck.sh'
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
