pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'Java'
    }

    environment{
        GIT_REPO = 'https://github.com/vinayakakg7/Cyq_demo.git'
        GIT_BRANCH = 'main'
//        EC2_INSTANCE_IP = bat(script: 'terraform output public_ip', returnStdout: true).trim()
    }
    stages {
        stage('Clone Git repository') {
            steps {
                git branch: GIT_BRANCH, url: GIT_REPO
				
				script {
					// Get the list of culprits
					def culprits = currentBuild.changeSets.collect { it.authorEmail }
                    def subject = 'Git checkout ' + (currentBuild.currentResult == 'SUCCESS' ? 'successful' : 'failed')
                    def body = 'The branch main was checked out ' + (currentBuild.currentResult == 'SUCCESS' ? 'successfully' : 'unsuccessfully') + '.\n\nChanges were made by: ' + culprits.join(', ')
                    emailext subject: subject, body: body, to: 'vinayakakg7@gmail.com', attachLog: true
                }
            }
        }
	    stage('Terraform_Plan') {
            steps { 
				 sh 'terraform init'
				 sh 'terraform plan'
				}
			}
		stage('Terraform action') {
			steps {
				script {
      // Get the value of the "terra" parameter
					def terra = params.terra

      // Check if the "terra" parameter is set to "destroy"
					if (terra == 'destroy') {
                      echo 'Destroying infrastructure...'
                      sh "terraform destroy --auto-approve"
                      error "Aborting the pipeline after destroying infrastructure" // Stop the pipeline after the destroy command
                    } else {
                          echo 'Applying infrastructure...'
                          sh "terraform apply --auto-approve"
                        }
                      }
                    }
                  }
        stage('Build and test using Maven') {
            steps {
                sh 'mvn clean install -DskipTests=true'
				
				script {
                    def subject = 'Build ' + (currentBuild.currentResult == 'SUCCESS' ? 'successful' : 'failed')
                    def body = 'Maven Build was done ' + (currentBuild.currentResult == 'SUCCESS' ? 'successfully' : 'unsuccessfully')
                    emailext subject: subject, body: body, to: 'vinayakakg7@gmail.com', attachLog: true
                }
            }
          }
	stage("deploy-dev") {
    steps {
        script {
           def publicIP = sh(returnStdout: true, script: "terraform output public_ip").trim().replace('"', '')
           //env.publicIP = publicIP
          // def publicIP = bat(returnStdout: true, script: "terraform output public_ip | Out-String").trim().replace('\r\n', '')
         // def publicIP = bat(returnStdout: true, script: "terraform output public_ip | findstr /R /C:\"^[0-9].*\"").trim().replace('\r\n', '')


            sshagent(['Deploy_Dev']) {
                sh "ssh -T -o StrictHostKeyChecking=no ec2-user@${publicIP} 'sudo su'"
                sh "ssh -T -o StrictHostKeyChecking=no ec2-user@${publicIP} 'cd /usr/local/tomcat9/webapps/'"
                sh "ssh -T -o StrictHostKeyChecking=no ec2-user@${publicIP} 'sudo su'"
                //sh "ssh -T -o StrictHostKeyChecking=no ec2-user@${publicIP} 'cd webapps'"
                sh "scp -T -o StrictHostKeyChecking=no /var/lib/jenkins/workspace/${env.JOB_NAME}/target/springbootApp.jar ec2-user@${publicIP}:./ "
                sh "ssh -T -o StrictHostKeyChecking=no ec2-user@${publicIP} tomcatup"
                sh "ssh -T -o StrictHostKeyChecking=no ec2-user@${publicIP} tomcatdown"
            }
        }
    }
}
}
post {
     failure {
         
	 emailext (
	     	  to: 'vinayakakg7@gmail.com',
                  subject: "Build failed in ${currentBuild.fullDisplayName}",
                  body: """${env.JOB_NAME} build #${env.BUILD_NUMBER} has failed.
                      Please investigate and fix the issue\n More info at: ${env.BUILD_URL}""",
	    	      attachLog: true,
                  compressLog: true
)
        }
		
     success {
       
	  emailext (
	           to: 'vinayakakg7@gmail.com',
                   subject: "Build successful in ${currentBuild.fullDisplayName}",
                   body: """${env.JOB_NAME} build #${env.BUILD_NUMBER} has succeeded.
                       Congratulations!\n More info at: ${env.BUILD_URL}""",
	  	            attachLog: true,
		            compressLog: true
          )
     }
    }
}
