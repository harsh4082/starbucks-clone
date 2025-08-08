pipeline {
  agent any
  stages {
    stage('Build Docker Image') {
      steps {
        bat 'docker build -t harsh601/starbucks-clone:latest .'
      }
    }
    stage('Push Image to DockerHub') {
      steps {
        bat 'docker login -u harsh -p Harsh@2345'
        bat 'docker push harsh601/starbucks-clone:latest'
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
