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
                        build job: 'engineerx-aws-deployment', parameters: [
                            string(name: "ACTION", value: "destroy")
                        ]
                        sh('terraform refresh')
                        sh('terraform destroy --auto-approve')
                    }
                    if (env.ACTION == 'apply') {
                        sh('terraform refresh')
                        sh('terraform apply --auto-approve')
                    }
                    if (env.ACTION == 'create') {
                        sh('terraform apply --auto-approve')
                        sh('aws eks --region us-east-2 update-kubeconfig --name test-eks-irsa')

                        // TODO: User terraform Helm Provider instead of these
                        sh('helm repo add autoscaler https://kubernetes.github.io/autoscaler')
                        sh('helm repo update')
                        sh("helm install cluster-autoscaler --namespace kube-system autoscaler/cluster-autoscaler --values=cluster-autoscaler-chart-values.yaml --set 'rbac.ServiceAccount.annotations.eks\\.amazonaws\\.com/role-arn=arn:aws:iam::$ROLE_ARN:role/cluster-autoscaler'")
                    }
                }
            }
        }
    }
}
