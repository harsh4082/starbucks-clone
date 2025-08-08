pipeline {
  agent any
  environment {
    DOCKERHUB_CREDENTIALS = credentials('cdf2d8a8-0d10-4cc3-b4a4-c4dadaa591c7') // replace with your Jenkins credentials ID
  }
  stages {
    stage('Build Docker Image') {
      steps {
        bat 'docker build -t harsh601/starbucks-clone:latest .'
      }
    }
    stage('Push Image to DockerHub') {
      steps {
        // Login securely using echo + docker login --password-stdin
        bat """
          echo %DOCKERHUB_CREDENTIALS_PSW% | docker login -u %DOCKERHUB_CREDENTIALS_USR% --password-stdin
          docker push harsh601/starbucks-clone:latest
        """
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        bat 'kubectl apply -f k8s/deployment.yaml'
        bat 'kubectl apply -f k8s/service.yaml'
      }
    }
  }
}
