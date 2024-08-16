node {
  stage("Checkout") {
    def scmVars = checkout scm
//     env.DOCKER_TAG = scmVars.GIT_BRANCH.split('/tags/')[1]
//     currentBuild.description = "Deploy for version ${env.DOCKER_TAG}"
  }

  stage("Build Image") {
    sh "make docker-login"
  }

  stage(name: "Publish Gem") {
    docker.image("ruby:3.3-alpine").inside {
      withCredentials([usernameColonPassword(credentialsId: 'gemserver-credentials', variable: 'GEM_HOST_API_KEY')]) {
        sh "rake publish"
      }
    }
  }
}
