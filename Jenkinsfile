pipeline {
  agent any
  stages {
    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQube-Local') {
          tool name: 'SonarScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
          bat 'sonar-scanner'
        }
      }
    }
  }
}
