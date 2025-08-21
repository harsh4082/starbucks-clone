pipeline {
    agent any

    environment {
        DOCKERHUB_CREDS    = credentials('cdf2d8a8-0d10-4cc3-b4a4-c4dadaa591c7')
        SONARQUBE_TOKEN    = credentials('sonarqube-token')
        SONARQUBE_URL      = 'http://localhost:9000'
        IMAGE_NAME         = "harsh601/starbucks-clone"
        PUSH_TO_DOCKERHUB  = "false"
    }

    stages {
        stage('Clean Workspace') {
            steps { deleteDir() }
        }

        stage('Checkout') {
            steps { git branch: 'main', url: 'https://github.com/harsh4082/starbucks-clone' }
        }

        stage('Install Dependencies') {
            steps {
                echo "📦 Installing Node.js dependencies..."
                bat 'npm ci --legacy-peer-deps'
            }
        }

        stage('Prepare image tag') {
            steps {
                script {
                    def shortCommit = bat(script: 'git rev-parse --short=7 HEAD', returnStdout: true)
                                        .trim()
                                        .split("\r?\n")
                                        .last()
                    env.IMAGE_TAG = shortCommit
                    env.FULL_IMAGE = "${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                    echo "✅ Docker image will be: ${env.FULL_IMAGE}"
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    bat 'if not exist reports\\owasp mkdir reports\\owasp'
                    bat 'dependency-check.bat --project "Starbucks Clone" --scan . --format "HTML" --out reports/owasp'
                }
            }
            post { always { archiveArtifacts artifacts: 'reports/owasp/**', allowEmptyArchive: true } }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def sonarReachable = true
                    try {
                        bat "curl -m 5 ${SONARQUBE_URL} || exit 1"
                    } catch (err) {
                        echo "⚠️ SonarQube not reachable, skipping analysis."
                        sonarReachable = false
                    }

                    if (sonarReachable) {
                        catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                            withSonarQubeEnv('SonarQube') {
                                bat """
                                    sonar-scanner ^
                                        -Dsonar.projectKey=starbucks-clone ^
                                        -Dsonar.sources=. ^
                                        -Dsonar.host.url=${SONARQUBE_URL} ^
                                        -Dsonar.login=${SONARQUBE_TOKEN}
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        try {
                            def qg = waitForQualityGate abortPipeline: false
                            echo "🔎 Quality Gate status: ${qg.status} — continuing regardless."
                        } catch (err) {
                            echo "⚠️ Skipping Quality Gate check, SonarQube not reachable."
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    timeout(time: 20, unit: 'MINUTES') {
                        bat "docker build --no-cache -t \"${env.FULL_IMAGE}\" ."
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    bat 'if not exist reports mkdir reports'
                    bat "trivy image --format table --output reports/trivy-report.txt ${env.FULL_IMAGE}"
                }
            }
            post { always { archiveArtifacts artifacts: 'reports/trivy-report.txt', allowEmptyArchive: true } }
        }

        stage('Push Image to DockerHub (optional)') {
            when { expression { return env.PUSH_TO_DOCKERHUB == 'true' } }
            steps {
                bat "echo %DOCKERHUB_CREDS_PSW% | docker login -u %DOCKERHUB_CREDS_USR% --password-stdin"
                bat "docker push ${env.FULL_IMAGE}"
            }
        }

        stage('Deploy to Kubernetes (Docker Desktop)') {
            steps {
                script {
                    bat 'kubectl create namespace starbucks --dry-run=client -o yaml | kubectl apply -f -'
                    bat 'kubectl apply -f k8s/service.yaml -n starbucks || exit 0'

                    def setImageStatus = bat(returnStatus: true, script: "kubectl -n starbucks set image deployment/starbucks-app starbucks-app=${env.FULL_IMAGE}")
                    if (setImageStatus != 0) {
                        bat "kubectl apply -f k8s/deployment.yaml -n starbucks"
                        bat "kubectl -n starbucks set image deployment/starbucks-app starbucks-app=${env.FULL_IMAGE}"
                    }

                    bat "kubectl rollout status deployment/starbucks-app -n starbucks --timeout=120s"
                }
            }
        }
    }

    post {
        always { echo "🎉 Pipeline finished. Check Jenkins artifacts for OWASP & Trivy reports." }
    }
}
