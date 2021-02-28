pipeline{
    agent any
    tools {
        terraform 'terraform-14'
    }
    stages{
        stage('Terraform Init'){
            steps{
                sh 'terraform init'
            }
        }

        stage('Terraform Plan'){
            steps{
                sh 'terraform plan -lock=false'
            }
        }

        stage('Terraform Apply'){
            steps{
                sh 'terraform apply -lock=false'
            }
        }
    }
}
