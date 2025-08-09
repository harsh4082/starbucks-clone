pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('cdf2d8a8-0d10-4cc3-b4a4-c4dadaa591c7') // Your Docker Hub credentials ID
        SONARQUBE_ENV = credentials('sonarqube-token') // Jenkins credential for SonarQube token
    }
    stages {
        stage('Build Docker Image') {
            steps {
                bat 'docker build -t harsh601/starbucks-clone:latest .'
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                bat 'dependency-check.bat --project "Starbucks Clone" --scan . --format "HTML" --out reports'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'reports/dependency-check-report.html', fingerprint: true
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                bat 'trivy image --severity HIGH,CRITICAL --exit-code 0 --no-progress harsh601/starbucks-clone:latest > trivy-report.txt'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.txt', fingerprint: true
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Local') { // Name from Jenkins SonarQube config
                    bat """
                        sonar-scanner.bat ^
                        -Dsonar.projectKey=starbucks-clone ^
                        -Dsonar.sources=src ^
                        -Dsonar.host.url=http://localhost:9000 ^
                        -Dsonar.login=%SONARQUBE_ENV%
                    """
                }
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                bat """
                    echo %DOCKERHUB_CREDENTIALS_PSW% | docker login -u %DOCKERHUB_CREDENTIALS_USR% --password-stdin
                    docker push harsh601/starbucks-clone:latest
                """
            }
        }
    }
}
