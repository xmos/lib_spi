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
        // VIEW = "${env.JOB_NAME.contains('PR-') ? REPO+'_'+env.CHANGE_TARGET : REPO+'_'+env.BRANCH_NAME}"
        VIEW = "lib_spi_feature_xs3_support"
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
                // installPipfile(true)
                // runPython("./runtests.py --junit-output=${REPO}_tests.xml")
              }
            }
          }
        }

        stage('Build XCOREAI') {
          steps {
            dir("${REPO}") {
              forAllMatch("examples", "AN*/") { path ->
                runXmake(path, '', 'XCOREAI=1')
                dir(path) {
                  stash name: path.split("/")[-1], includes: 'bin/*, '
                }
              }

              // Build Tests
              dir('legacy_tests/') {
                script {
                  tests = [
                    "spi_master_async_multi_client",
                    "spi_master_async_multi_device",
                    "spi_master_async_rx_tx",
                    "spi_master_async_shutdown",
                    "spi_master_sync_benchmark",
                    "spi_master_sync_clock_port_sharing",
                    "spi_master_sync_multi_client",
                    "spi_master_sync_multi_device",
                    "spi_master_sync_rx_tx",
                    "spi_slave_benchmark",
                    "spi_slave_rx_tx"
                  ]
                  tests.each() {
                    dir(it) {
                      runXmake(".", "", "XCOREAI=1")
                      stash name: it, includes: 'bin/*/*.xe, '
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

    stage('Documentation'){
      agent{
        label 'x86_64&&brew&&macOS'
      }
      stages{
        stage('Builds') {
          steps {
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
              sh 'tree'

              forAllMatch("AN00", "app_*/") { path ->
                unstash path.split("/")[-1]
              }

              sh 'tree'

              // Run the tests and look for what we expect
              sh 'xrun --io --id 0 bin/app_name.xe &> app_name.txt'
              // Look for config register 0 value from wifi module
              sh 'grep 2005400 app_name.txt'

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
