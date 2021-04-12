pipeline{
    agent any
    parameters {
        string(name: 'APPNAME', defaultValue: 'demo_app', description: 'App name')
        string(name: 'ENVIRONMENT_NAME', defaultValue: 'dev', description: 'AWS account')
        string(name: 'MANIFEST_FILE_NAME', defaultValue: 'manifest-v1.2.3.yaml', description: 'Manifest file name')
    }
    stages{
        stage('Git Checkout'){
            steps{
                git branch: 'main', credentialsId: '07dad45e-ff36-442b-ba0b-f0927dbc2391', url: 'git@github.com:oluadegun/iac-demo'
            }
        } 
        stage('Upload Deployment Artifact to s3'){
            when {
                expression { env.APPNAME != '' }
            }
            steps{
                sh """
                aws s3 cp ./manifests/${env.ENVIRONMENT_NAME}/* s3://demo-manifests/artefacts/${env.APPNAME}/version/
                aws s3 cp s3://demo-manifests/artefacts/${env.APPNAME}/version/${env.MANIFEST_FILE_NAME} s3://demo-deployment-files/deployments/${env.APPNAME}/${env.ENVIRONMENT_NAME}/manifests/
                """
            }
        }
    }
}

pipeline{
    agent any
    parameters {
        string(name: 'FILENAME', defaultValue: 'hello-v.1.2.3.zip', description: 'Lambda file name')
        string(name: 'ENVIRONMENT_NAME', defaultValue: 'dev', description: 'AWS account')
        string(name: 'APPNAME', defaultValue: 'demo_app', description: 'App name')
        string(name: 'APPVERSION', defaultValue: 'v1.2.3', description: 'App version')
    }
    stages{
        stage('Git Checkout'){
            steps{
                git branch: 'main', credentialsId: '07dad45e-ff36-442b-ba0b-f0927dbc2391', url: 'git@github.com:oluadegun/iac-demo'
            }
        } 
        stage('Upload Application code to s3'){
            when {
                expression { env.FILENAME != '' }
            }
            steps{
                sh """
                aws s3 cp ./files/${env.ENVIRONMENT_NAME}/* s3://demo-deployment-files/deployments/${env.APPNAME}/${env.APPVERSION}/
                """
            }
        }
    }
}

pipeline{
    agent any
    tools {
        terraform 'terraform-14'
    }
    parameters {
        string(name: 'FILENAME', defaultValue: 'hello-v1.2.3.zip', description: 'Lambda file name')
        string(name: 'ENVIRONMENT_NAME', defaultValue: 'dev', description: 'AWS account')
        string(name: 'APPNAME', defaultValue: 'demo_app', description: 'App name')
        string(name: 'MANIFEST_FILE_NAME', defaultValue: 'manifest-v1.2.3.yaml', description: 'Manifest file name')
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
        stage('Fetching Manifest files'){
            steps{
                sh "aws s3 cp s3://demo-deployment-files/deployments/${env.APPNAME}/${env.ENVIRONMENT_NAME}/manifests/${env.MANIFEST_FILE_NAME} ./"
                script {
                    def app_data = readYaml file: 'manifest.yaml'
                    println app_data
                }
            }
        }
        stage('Fetching application from s3'){
            when {
                expression { env.FILENAME != '' }
            }
            steps{
                sh """
                aws s3 cp s3://demo-deployment-files/deployments/${env.APPNAME}/${env.ENVIRONMENT_NAME}/applications/${env.FILENAME} ./
                """
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
                        export TF_VAR_env="${env.ENVIRONMENT_NAME}"
                        export TF_VAR_appversion="${app_data.version}"
                        export TF_VAR_lambda_pkg=s3://demo-deployment-files/deployments/${app_data.appName}/${app_data.version}/${env.FILENAME}-${app_data.version}.zip
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
                        export TF_VAR_appversion="${app_data.version}"
                        export TF_VAR_lambda_pkg=s3://demo-deployment-files/deployments/${app_data.appName}/${app_data.version}/${env.FILENAME}-${app_data.version}.zip
                    fi
                    terraform apply --auto-approve -lock=false tfplan
                """
            }
        }
    }
}