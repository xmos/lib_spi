// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.41.0') _

getApproval()

def clone_test_deps() {
  dir("${WORKSPACE}") {
    sh "git clone git@github.com:xmos/test_support"
    sh "git -C test_support checkout v2.0.0"
  }
}

pipeline {
  agent {
    label 'x86_64 && linux'
  }
  options {
    buildDiscarder(xmosDiscardBuildSettings())
    skipDefaultCheckout()
    timestamps()
  }
  parameters {
    choice(name: 'TEST_LEVEL', choices: ['smoke', 'default', 'extended'],
            description: 'The level of test coverage to run'
    )
    string(
      name: 'TOOLS_VERSION',
      defaultValue: '15.3.1',
      description: 'The XTC tools version'
    )
    string(
      name: 'XMOSDOC_VERSION',
      defaultValue: 'v7.3.0',
      description: 'The xmosdoc version'
    )
    string(
      name: 'INFR_APPS_VERSION',
      defaultValue: 'v3.1.1',
      description: 'The infr_apps version'
    )
  }

  stages {
    stage('Checkout & build examples') {
      steps {
        println "Stage running on ${env.NODE_NAME}"

        script {
            def (server, user, repo) = extractFromScmUrl()
            env.REPO_NAME = repo
        }

        dir("${REPO_NAME}") {
          checkoutScmShallow()

          dir("examples") {
            withTools(params.TOOLS_VERSION) {
              xcoreBuild()
            }
          }
        }
      }
    }

    stage('Library checks') {
      steps {
        warnError("Library checks failed")
        {
          runRepoChecks("${WORKSPACE}/${REPO_NAME}")
        }
      }
    }

    stage('Documentation') {
      steps {
        dir(REPO_NAME) {
          buildDocs()
        }
      }
    }


    stage('Tests')
    {
      steps {
        withTools(params.TOOLS_VERSION) {
          clone_test_deps()
          dir("${REPO_NAME}/tests") {
            createVenv(reqFile: "requirements.txt")
            xcoreBuild()
            withVenv{
              runPytest("--numprocesses=auto --testlevel=${params.TEST_LEVEL}")
            }
          } // dir
        } // withTools
      } // steps
      post
      {
        always{
          archiveArtifacts artifacts: "${REPO_NAME}/tests/logs/*.txt", fingerprint: true, allowEmptyArchive: true
        }
      }
    }

    stage("Archive")
    {
      steps
      {
        archiveSandbox(REPO_NAME)
      }
    }

    stage('🚀 Release') {
      steps {
        triggerRelease()
      }
    }
  } // stages
  post {
    cleanup {
      xcoreCleanSandbox()
    }
  }
}
