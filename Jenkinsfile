pipeline{
    agent any
    tools {
        terraform 'terraform-14'
    }
    parameters {
        password (name: 'AWS_ACCESS_KEY_ID', defaultValue: 'ASIAQLVLVRP4KPN733ON')
        password (name: 'AWS_SECRET_ACCESS_KEY', defaultValue: 'bhEVizbh4BdETUj33DyAoS89tc3hIDdR6ajE84NC')
    }
    environment {
        TF_WORKSPACE = 'default' //Sets the Terraform Workspace
        TF_IN_AUTOMATION = 'true'
        TF_VAR_AWS_ACCESS_KEY_ID = "${params.AWS_ACCESS_KEY_ID}"
        TF_VAR_AWS_SECRET_ACCESS_KEY = "${params.AWS_SECRET_ACCESS_KEY}"
    }
    stages{
        stage('Git Checkout'){
            steps{
                git branch: 'master', credentialsId: '07dad45e-ff36-442b-ba0b-f0927dbc2391', url: 'git@github.com:oluadegun/iac-demo'
            }
        }
        stage('Terraform Init'){
            steps{
                sh 'terraform init'
            }
        }
        stage('Terraform Apply'){
            steps{
                sh 'terraform apply --auto-approve'
            }
        }
    }
}