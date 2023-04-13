pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'Java'
    }

    environment{
        GIT_REPO = 'https://github.com/vinayakakg7/Cyq_demo.git'
        GIT_BRANCH = 'main'
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
				 bat 'terraform init'
				 bat 'terraform plan'
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
                      bat "terraform destroy --auto-approve"
                      error "Aborting the pipeline after destroying infrastructure" // Stop the pipeline after the destroy command
                    } else {
                          echo 'Applying infrastructure...'
                          bat "terraform apply --auto-approve"
                        }
                      }
                    }
                  }
        stage('Build and test using Maven') {
            steps {
                bat 'mvn clean install -DskipTests=true'
				
				script {
                    def subject = 'Build ' + (currentBuild.currentResult == 'SUCCESS' ? 'successful' : 'failed')
                    def body = 'Maven Build was done ' + (currentBuild.currentResult == 'SUCCESS' ? 'successfully' : 'unsuccessfully')
                    emailext subject: subject, body: body, to: 'vinayakakg7@gmail.com', attachLog: true
                }
            }
          }
		stage("deploy-dev"){
			steps {
             script {
                def public_ip = bat(returnStdout: true, script: 'terraform output public_ip').trim()
                withCredentials([sshUserPrivateKey(credentialsId: 'Deploy_Auto', keyFileVariable: 'AWS_Cred', usernameVariable: 'AWS_CRED')])  {
				        public_ip='${(terraform output public_ip)}'

				        bat  "scp -o StrictHostKeyChecking=no C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\${env.JOB_NAME}\\target\\springbootApp.jar ec2-user@public_ip: /usr/local/tomcat9/webapps/ "
				        bat   "ssh -o StrictHostKeyChecking=no ec2-user@public_ip tomcatdown"
				        bat   "ssh -o StrictHostKeyChecking=no ec2-user@public_ip tomcatup"
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
