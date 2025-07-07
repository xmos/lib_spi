// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.39.0') _

getApproval()

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
      defaultValue: 'v2.1.0',
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
                runLibraryChecks("${WORKSPACE}/${REPO_NAME}", "${params.INFR_APPS_VERSION}")
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


    //stage('Tests')
    //{
    //  steps {
    //      withTools(params.TOOLS_VERSION) {
    //        dir("${REPO}/tests") {
    //          createVenv(reqFile: "requirements.txt")
    //          withVenv{
    //            runPytest("--numprocesses=8 --testlevel=${params.TEST_LEVEL})
    //          }
    //        } // dir
    //      } // withTools
    //  } // steps
    //  post
    //  {
    //    failure
    //    {
    //      //archiveArtifacts artifacts: "${REPO}/tests/logs/*.txt", fingerprint: true, allowEmptyArchive: true
    //    }
    //  }
    //}

    stage("Archive")
    {
        steps
        {
            archiveSandbox(REPO_NAME)
        }
    }
  }
  post {
    cleanup {
      xcoreCleanSandbox()
    }
  }
}
