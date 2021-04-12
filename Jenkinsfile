///////Build Pipeline(software dep pipeline)///////
pipeline{
    agent any
    parameters {
        string(name: 'ENVIRONMENT_NAME', defaultValue: 'dev', description: 'AWS account')
        string(name: 'APPNAME', defaultValue: 'demo_app', description: 'App name')
        string(name: 'APPVERSION', defaultValue: 'v1.2.3', description: 'App version')
    }
    stages{
        stage('Git Checkout'){
            steps{
                cleanWs()
                git branch: 'main', credentialsId: '07dad45e-ff36-442b-ba0b-f0927dbc2391', url: 'git@github.com:oluadegun/iac-demo'
            }
        } 
        stage('Upload Application/manifests code to s3'){
            steps{
                //Run Some steps that execute the build process before this upload and generate version number which would replace hard coded variable version number
                sh """
                for f in ./files/*; do
                    aws s3 cp "\$f" s3://demo-deployment-files/artefacts/${env.APPNAME}/${env.APPVERSION}/
                done
                """
            }
        }
    }
}

////////promotion pipeline(artifacts_pipeline)/////
pipeline{
    agent any
    parameters {
        string(name: 'APPNAME', defaultValue: 'demo_app', description: 'App name')
        string(name: 'ENVIRONMENT_NAME', defaultValue: 'dev', description: 'AWS account')
        string(name: 'APPVERSION', defaultValue: '', description: 'App version')
    }
    stages{
        stage('Promote to Dev'){
            steps{
                sh "aws s3 cp s3://demo-deployment-files/artefacts/${env.APPNAME}/${env.APPVERSION}//manifest.yaml s3://demo-deployment-files/deployments/${env.APPNAME}/${env.ENVIRONMENT_NAME}/manifests/"
            }
        }
        stage('Deploy to Dev'){
            steps{
                //invoke infra pipeline with env name=Dev and App name=Demo-app
                build job: 'infra_pipeline', parameters: [string(name: 'ENVIRONMENT_NAME', value: 'dev'), string(name: 'APPNAME', value: 'demo_app')]
            }
        }
    }
}


/////////////Infra pipeline////////
pipeline{
    agent any
    tools {
        terraform 'terraform-14'
    }
    parameters {
        string(name: 'ENVIRONMENT_NAME', defaultValue: 'dev', description: 'AWS account')
        string(name: 'APPNAME', defaultValue: 'demo_app', description: 'App name')
    }
    environment {
        TF_WORKSPACE = 'default' //Sets the Terraform Workspace
        TF_IN_AUTOMATION = 'true'
    }
    stages{
        stage('Git Checkout'){
            steps{
                cleanWs()
                git branch: 'main', credentialsId: '07dad45e-ff36-442b-ba0b-f0927dbc2391', url: 'git@github.com:oluadegun/iac-demo'
            }
        } 
        stage('Fetching Manifest files'){
            steps{
                sh "aws s3 cp s3://demo-deployment-files/deployments/${env.APPNAME}/${env.ENVIRONMENT_NAME}/manifests/manifest.yaml ./"
                script {
                    app_data = readYaml file: 'manifest.yaml'
                    println app_data
                }
            }
        }
        stage('Terraform Init'){
            steps{
                sh """
                    terraform init -backend-config="key=global/s3/${env.ENVIRONMENT_NAME}/terraform.tfstate"
                """
            }
        }  
        stage('Terraform Plan') {
            steps {
                sh """
                    echo "${env.FILENAME}"
                    if [[ "" != "${env.FILENAME}" ]]; then
                        export  TF_VAR_filename="${env.FILENAME}"
                        export TF_VAR_appname="${app_data.appName}"
                        export TF_VAR_env_name="${env.ENVIRONMENT_NAME}"
                        export TF_VAR_appversion="${app_data.versionId}"
                        export TF_VAR_lambda_pkg=deployments/${app_data.appName}/${app_data.versionId}/${app_data.appName}-${app_data.versionId}.zip
                    fi
                    terraform plan -out=tfplan -input=false
                """
            }
        }
        stage('Terraform Apply'){
            steps{
                sh "terraform apply --auto-approve -lock=false tfplan"
            }
        }
    }
}