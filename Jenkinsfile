@Library('xmos_jenkins_shared_library@v0.16.2') _

getApproval()

pipeline {
  agent {
    label 'x86_64&&brew'
  }
  environment {
    REPO = 'lib_spi'
    VIEW = "${env.JOB_NAME.contains('PR-') ? REPO+'_'+env.CHANGE_TARGET : REPO+'_'+env.BRANCH_NAME}"
  }
  options {
    skipDefaultCheckout()
  }
  stages {
    stage('Get view') {
      steps {
        xcorePrepareSandbox("${VIEW}", "${REPO}")
      }
    }
    stage('Library checks') {
      steps {
        xcoreLibraryChecks("${REPO}")
      }
    }
    stage('Legacy tests') {
      steps {
        dir("${REPO}/legacy_tests") {
          viewEnv() {
            // Use Pipfile in legacy_tests, not lib_spi/Pipfile
            installPipfile(true)
            runPython("./runtests.py --junit-output=${REPO}_tests.xml")
          }
        }
      }
    }
    stage('Builds') {
      steps {
        dir("${REPO}") {
          forAllMatch("${REPO}/examples", "AN*/") { path ->
            runXdoc("${path}/doc")
          }
          runXdoc("${REPO}/${REPO}/doc")

          // Archive all the generated .pdf docs
          archiveArtifacts artifacts: "${REPO}/**/pdf/*.pdf", fingerprint: true, allowEmptyArchive: true
        }
      }
    }
  }
  post {
    success {
      updateViewfiles()
    }
    cleanup {
      xcoreCleanSandbox()
    }
  }
}
