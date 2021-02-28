pipeline{
    agent any
    tools {
        terraform 'terraform-14'
    }
    stages{
        stage('Git Checkout'){
            steps{
                
            }
        }
        stage('Terraform Init'){
            steps{
                sh 'terraform init'
            }
        }
    }
}
