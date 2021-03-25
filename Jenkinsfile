pipeline{
    agent any
    tools {
        terraform 'terraform-14'
    }
    parameters {
        string(name: 'FILENAME', defaultValue: '', description: 'Lambda file name')
        string(name: 'ENVIRONMENT_NAME', defaultValue: 'dev', description: 'AWS account')
    }
    environment {
        TF_WORKSPACE = 'default' //Sets the Terraform Workspace
        TF_IN_AUTOMATION = 'true'
    }
    stages{
        stage('Git Checkout'){
            steps{
                git branch: 'main', credentialsId: '07dad45e-ff36-442b-ba0b-f0927dbc2391', url: 'git@github.com:oluadegun/iac-demo'
            }
        } 
        stage('Fetch Deployment Artifact'){
            when {
                expression { env.FILENAME != '' }
            }
            steps{
                sh """
                aws s3 cp s3://tf-state-1993/${env.FILENAME} ./
                """
            }
        }
        stage('Fetch Manifest files'){
            steps{
                sh "aws s3 cp s3://tf-state-1993/${env.ENVIRONMENT_NAME}/manifest.yaml ./"
                app_data=readYaml file: 'manifest.yaml'
            }
        }
        stage('Terraform Init'){
            steps{
                sh "terraform init"
            }
        }  
        stage('Terraform Plan') {
            steps {
                sh """
                    echo "${env.FILENAME}"
                    if [[ "" != "${env.FILENAME}" ]]; then
                        export  TF_VAR_filename="${env.FILENAME}"
                        export TF_VAR_appname="${app_data.appName}"
                    fi
                    terraform plan -out=tfplan -input=false
                """
            }
        }
        stage('Terraform Apply'){
            steps{
                sh """
                    echo "${env.FILENAME}"
                    if [[ "" != "${env.FILENAME}" ]]; then
                        export  TF_VAR_filename="${env.FILENAME}"
                        export TF_VAR_appname="${app_data.appName}"
                    fi
                    terraform apply --auto-approve -lock=false tfplan
                """
            }
        }
    }
}