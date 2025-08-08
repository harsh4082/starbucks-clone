pipeline {
  agent any
  stages {
    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQube-Local') {
          bat 'sonar-scanner'
        }
      }
    }
  }
}
