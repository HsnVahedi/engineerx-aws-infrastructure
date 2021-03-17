pipeline {
    agent {
        docker {
            image 'hsndocker/aws-cli:latest'
            args '-u root:root'
        }
    }
    parameters {
        string(name: 'ACTION', defaultValue: 'apply')
    }
    environment {
        ACCESS_KEY_ID = credentials('aws-access-key-id')
        SECRET_KEY = credentials('aws-secret-key')
        ACTION = "${params.ACTION}"
        AWS_ACCOUNT_ID = credentials('aws-account-id') 
        REGION = "us-east-2"
        CLUSTER_NAME = "engineerx"
    }
    stages {
        stage('Providing Access Keys') {
            steps {
                sh('aws configure set aws_access_key_id $ACCESS_KEY_ID')
                sh('aws configure set aws_secret_access_key $SECRET_KEY')
                sh('aws configure set default.region $REGION')
            }
        }
        stage('Terraform Initialization') {
            steps {
                sh('terraform init')
            }
        }
        stage('Apply Changes') {
            steps {
                script {
                    if (env.ACTION == 'destroy') {
                        build job: 'engineerx-aws-deployment', parameters: [
                            string(name: "ACTION", value: "destroy")
                        ]
                        sh('terraform refresh')
                        sh('terraform destroy --auto-approve --var region=$REGION --var cluster_name=$CLUSTER_NAME')
                    }
                    if (env.ACTION == 'destroy-infra') {
                        sh('terraform refresh')
                        sh('terraform destroy --auto-approve --var region=$REGION --var cluster_name=$CLUSTER_NAME')
                    }
                    if (env.ACTION == 'apply') {
                        sh('terraform refresh')
                        sh('terraform apply --auto-approve --var region=$REGION --var cluster_name=$CLUSTER_NAME')
                    }
                    if (env.ACTION == 'create') {
                        sh('terraform apply --auto-approve --var region=$REGION --var cluster_name=$CLUSTER_NAME')
                        sh('aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME')

                        // TODO: Use terraform Helm Provider instead of these.
                        sh("sed -i 's/AWS_ACCOUNT_ID/$AWS_ACCOUNT_ID/g' cluster-autoscaler-chart-values.yaml")
                        sh('helm repo add autoscaler https://kubernetes.github.io/autoscaler')
                        sh('helm repo update')
                        sh('kubectl get deployment -n kube-system')
                        sh("helm install cluster-autoscaler --namespace kube-system autoscaler/cluster-autoscaler --values=cluster-autoscaler-chart-values.yaml")
                    }
                }
            }
        }
    }
}
