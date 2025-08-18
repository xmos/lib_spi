// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.41.0') _

getApproval()

pipeline {
  agent none

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

  options {
    buildDiscarder(xmosDiscardBuildSettings())
    skipDefaultCheckout()
    timestamps()
  }

  stages {
    stage('🏗️ Build and test') {
      agent {
        label 'x86_64 && linux && documentation'
      }

      stages {
        stage('Checkout') {
          steps {
            println "Stage running on ${env.NODE_NAME}"
            script {
              def (server, user, repo) = extractFromScmUrl()
              env.REPO_NAME = repo
            }

            dir(REPO_NAME){
              checkoutScmShallow()
            }
          }
        }

        stage('Examples build') {
          steps {
            dir("${REPO_NAME}/examples") {
              xcoreBuild()
            }
          }
        }

        stage('Repo checks') {
          steps {
            warnError("Repo checks failed")
            {
              runRepoChecks("${WORKSPACE}/${REPO_NAME}")
            }
          }
        }

        stage('Doc build') {
          steps {
            dir(REPO_NAME) {
              buildDocs()
            }
          }
        }
        
        stage('Tests') {
          steps {
            withTools(params.TOOLS_VERSION) {
              dir("${REPO_NAME}/tests") {
                createVenv(reqFile: "requirements.txt")
                xcoreBuild()
                withVenv{
                  runPytest("--numprocesses=auto --testlevel=${params.TEST_LEVEL}")
                }
              } // dir
            } // withTools
          } // steps
          post {
            always {
              archiveArtifacts artifacts: "${REPO_NAME}/tests/logs/*.txt", fingerprint: true, allowEmptyArchive: true
            }
          }
        }

        stage("Archive sandbox") {
          steps {
            archiveSandbox(REPO_NAME)
          }
        }
      } // stages
  
      post {
        cleanup {
          xcoreCleanSandbox()
        }
      }
    } // stage build and test

    stage('🚀 Release') {
      steps {
        triggerRelease()
      }
    }
  } // stages
} // pipeline
