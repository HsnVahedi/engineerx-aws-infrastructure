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
    }
    stages {
        stage('Providing Access Keys') {
            steps {
                sh('aws configure set aws_access_key_id $ACCESS_KEY_ID')
                sh('aws configure set aws_secret_access_key $SECRET_KEY')
                sh('aws configure set default.region us-east-2')
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
                        sh('terraform destroy --auto-approve')
                    }
                    if (env.ACTION == 'apply') {
                        sh('terraform apply --auto-approve')
                        sh('aws eks --region us-east-2 update-kubeconfig --name test-eks-irsa')

                        sh('helm repo add autoscaler https://kubernetes.github.io/autoscaler')
                        sh('helm repo update')
                        sh('helm install cluster-autoscaler --namespace kube-system autoscaler/cluster-autoscaler --values=cluster-autoscaler-chart-values.yaml')

                        sh('helm repo add eks https://aws.github.io/eks-charts')
                        sh('kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"')
                        sh('helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=test-eks-irsa')
                    }
                }
            }
        }
    }
}
