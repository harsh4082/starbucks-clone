pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t harsh601/starbucks-clone:latest .'
      }
    }

    stage('Push Image to DockerHub') {
      steps {
        withDockerRegistry(credentialsId: 'dockerhub-creds') {
          sh 'docker push harsh601/starbucks-clone:latest'
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh 'kubectl apply -f k8s/deployment.yaml'
        sh 'kubectl apply -f k8s/service.yaml'
      }
    }
  }
}
