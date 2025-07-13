pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/your-org/your-repo.git'  // 🔁 실 repo 주소로 수정
        BRANCH = 'main'
        GIT_PREVIOUS_COMMIT = "${env.GIT_PREVIOUS_COMMIT ?: 'HEAD~1'}"
        GIT_COMMIT = "${env.GIT_COMMIT ?: 'HEAD'}"
    }

    stages {
        stage('📦 Checkout') {
            steps {
                echo "🔍 BRANCH: ${env.BRANCH}"
                echo "🔍 REPO_URL: ${env.REPO_URL}"
                echo "🔍 GIT_COMMIT 범위: ${env.GIT_PREVIOUS_COMMIT} → ${env.GIT_COMMIT}"

                deleteDir() // Clean workspace
                git branch: "${env.BRANCH}", url: "${env.REPO_URL}"
            }
        }

        stage('🚀 Generate SBOM for each commit') {
            steps {
                script {
                    sh """
                        rm -rf recent-commits && mkdir recent-commits
                        git clone --quiet --branch ${env.BRANCH} ${env.REPO_URL} recent-commits
                    """

                    dir('recent-commits') {
                        def commits = sh(
                            script: "git log ${env.GIT_PREVIOUS_COMMIT}..${env.GIT_COMMIT} --pretty=format:'%H'",
                            returnStdout: true
                        ).trim().split("\n")

                        echo "📌 변경된 커밋 목록:\n${commits.join('\n')}"

                        if (commits.size() == 0 || commits[0] == "") {
                            echo "✅ 변경된 커밋이 없어 SBOM 작업 생략"
                        } else {
                            def jobs = [:]
                            for (int i = 0; i < commits.size(); i++) {
                                def index = i
                                def commitId = commits[index]
                                def buildId = "${env.BUILD_NUMBER}-${index}"
                                def repoName = env.REPO_URL.tokenize('/').last().replace('.git', '')

                                jobs["SBOM-${index}"] = {
                                    def cid = commitId
                                    def bid = buildId
                                    def rname = repoName
                                    def repoUrl = env.REPO_URL

                                    node('SCA') {
                                        echo "🔧 SBOM 생성 시작: Commit ${cid}, Build ${bid}"
                                        sh """
                                            /home/ec2-user/run_sbom_pipeline.sh '${repoUrl}' '${rname}' '${bid}' '${cid}'
                                        """
                                    }
                                }
                            }

                            parallel jobs
                        }
                    }
                }
            }
        }

        stage('✅ 최종 확인') {
            steps {
                echo "✅ SBOM 병렬 작업 완료"
            }
        }
    }

    post {
        failure {
            echo "❌ 빌드 실패. 로그 확인 필요"
        }
        success {
            echo "🎉 빌드 성공"
        }
    }
}
