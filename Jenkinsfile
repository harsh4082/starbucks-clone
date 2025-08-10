pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('cdf2d8a8-0d10-4cc3-b4a4-c4dadaa591c7') // DockerHub Jenkins credential ID
        SONARQUBE_ENV = credentials('sonarqube-token') // SonarQube token credential ID
        SONARQUBE_URL = 'http://localhost:9000' // Change if SonarQube is hosted elsewhere
        IMAGE_NAME = "harsh601/starbucks-clone"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/harsh4082/starbucks-clone'
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    bat 'if not exist reports\\owasp mkdir reports\\owasp'
                    bat '''
                        dependency-check.bat --project "Starbucks Clone" --scan . --format "HTML" --out reports/owasp
                    '''
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'reports/owasp/**', allowEmptyArchive: true
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    withSonarQubeEnv('SonarQube') {
                        bat """
                            sonar-scanner ^
                            -Dsonar.projectKey=starbucks-clone ^
                            -Dsonar.sources=. ^
                            -Dsonar.host.url=${SONARQUBE_URL} ^
                            -Dsonar.login=${SONARQUBE_ENV}
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Trivy Image Scan') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    bat 'if not exist reports mkdir reports'
                    bat """
                        trivy image --format table --output reports/trivy-report.txt ${IMAGE_NAME}:latest
                    """
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'reports/trivy-report.txt', allowEmptyArchive: true
                }
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                bat """
                    echo %DOCKERHUB_CREDENTIALS_PSW% | docker login -u %DOCKERHUB_CREDENTIALS_USR% --password-stdin
                    docker push ${IMAGE_NAME}:latest
                """
            }
        }

        stage('Deploy to Kubernetes on EKS') {
            steps {
                bat 'kubectl create namespace starbucks --dry-run=client -o yaml | kubectl apply -f -'
                bat 'kubectl apply -f k8s/deployment.yaml'
                bat 'kubectl apply -f k8s/service.yaml'
            }
        }
    }

    post {
        always {
            echo "Pipeline completed. Check 'Reports' in Jenkins for OWASP and Trivy results."
        }
    }
}
