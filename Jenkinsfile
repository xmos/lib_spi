@Library('xmos_jenkins_shared_library@v0.16.2') _

getApproval()

pipeline {
  agent none
  parameters {
    string(
      name: 'TOOLS_VERSION',
      defaultValue: '15.0.2',
      description: 'The tools version to build with (check /projects/tools/ReleasesTools/)'
    )
  }
  stages {
    stage('Standard build and XS1/2 tests') {
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
              xcoreAllAppNotesBuild('examples')
              dir("${REPO}") {
                //runXdoc('doc')
              }
            }
          }
        }
        stage('Build XCOREAI') {
          steps {
            dir("${REPO}") {
              forAllMatch("AN00", "app_*/") { path ->
                runXmake(path, 'clean') //Necessary because we previously built in same path for XS1/2 so we need to remove build files
                runXmake(path, '', 'XCOREAI=1')
                dir(path) {
                  stash name: path.split("/")[-1], includes: 'bin/*, '
                }
              }

              // Build Tests
              dir('tests/') {
                script {
                  tests = [
                    "test_fft_forward_real",
                    "test_fft_inverse_blank_forward"
                  ]
                  tests.each() {
                    dir(it) {
                      runXmake(".", "", "XCOREAI=1")
                      stash name: it, includes: 'bin/*xcoreai/*.xe, '
                    }
                  }
                }
              }
            }
          }
        }
      }//stages
      post {
        cleanup {
          xcoreCleanSandbox()
        }
      }
    }//stage - Standard build and XS1/2 tests

    stage('xcore.ai Verification'){
      agent {
        label 'xcore.ai-explorer'
      }
      environment {
        // '/XMOS/tools' from get_tools.py and rest from tools installers
        TOOLS_PATH = "/XMOS/tools/${params.TOOLS_VERSION}/XMOS/xTIMEcomposer/${params.TOOLS_VERSION}"
      }
      stages{
        stage('Install Dependencies') {
          steps {
            sh '/XMOS/get_tools.py ' + params.TOOLS_VERSION
            installDependencies()
          }
        }
        stage('xrun'){
          steps{
            toolsEnv(TOOLS_PATH) {  // load xmos tools
              forAllMatch("AN00", "app_*/") { path ->
                unstash path.split("/")[-1]
              }

              sh 'tree'

              // // Run all the tests
              // // app_adaptive - expect
              // sh 'xrun --io --id 0 bin/xcoreai/app_adaptive.xe &> app_adaptive_test.txt'
              // sh 'cat app_adaptive_test.txt && diff --ignore-blank-lines --ignore-trailing-space app_adaptive_test.txt tests/adaptive_test.expect'

            }
          }
        }
      }//stages
      post {
        cleanup {
          cleanWs()
        }
      }
    }// xcore.ai

    stage('Update view files') {
      agent {
        label 'x86_64&&brew'
      }
      when {
        expression { return currentBuild.currentResult == "SUCCESS" }
      }
      steps {
        updateViewfiles()
      }
    }
  }//stages
}//pipeline
