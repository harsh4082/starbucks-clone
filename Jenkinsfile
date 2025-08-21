pipeline {
    agent any

    environment {
        DOCKERHUB_CREDS = credentials('dockerhub-credentials') // optional
    }

    stages {

        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/harsh4082/starbucks-clone'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '📦 Installing Node.js dependencies...'
                bat 'npm ci --legacy-peer-deps'
            }
        }

        stage('Prepare Image Tag') {
            steps {
                script {
                    IMAGE_TAG = "harsh601/starbucks-clone:${env.GIT_COMMIT.take(7)}"
                    echo "✔ Docker image will be: ${IMAGE_TAG}"
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    bat 'if not exist reports\\owasp mkdir reports\\owasp'
                    bat 'dependency-check.bat --project "Starbucks Clone" --scan . --format "HTML" --out reports/owasp'
                    archiveArtifacts artifacts: 'reports/owasp/**', allowEmptyArchive: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    timeout(time: 20, unit: 'MINUTES') {
                        bat "docker build --no-cache -t ${IMAGE_TAG} ."
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    bat "trivy image --exit-code 1 --severity HIGH,CRITICAL ${IMAGE_TAG} || echo 'Trivy scan completed'"
                    archiveArtifacts artifacts: 'trivy-report.html', allowEmptyArchive: true
                }
            }
        }

        stage('Push Image to DockerHub (optional)') {
            when {
                expression { return env.DOCKERHUB_CREDS != null }
            }
            steps {
                script {
                    bat "docker login -u %DOCKERHUB_CREDS_USR% -p %DOCKERHUB_CREDS_PSW%"
                    bat "docker push ${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Kubernetes (Minikube)') {
            steps {
                script {
                    bat 'kubectl config use-context minikube'
                    bat 'kubectl create namespace starbucks --dry-run=client -o yaml | kubectl apply -f -'
                    bat 'kubectl apply -f k8s/deployment.yaml -n starbucks'
                    bat 'kubectl apply -f k8s/service.yaml -n starbucks'
                }
            }
        }

    }

    post {
        always {
            echo '🎉 Pipeline finished. Check Jenkins artifacts for OWASP & Trivy reports.'
        }
    }
}
