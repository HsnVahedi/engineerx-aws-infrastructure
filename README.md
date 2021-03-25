<p align="center">

  <h3 align="center">EngineerX AWS Infrastructure</h3>

  <p align="center">
    <a href="https://github.com/HsnVahedi/engineerx-aws-infrastructure/issues/new">Report bug</a>
    ·
    <a href="https://github.com/HsnVahedi/engineerx-aws-infrastructure/issues/new">Request feature</a>
  </p>
</p>


## Table of contents

- [Introduction to EngineerX project](#introduction-to-engineerx-project)
- [Requirements](#requirements)
- [Create AWS Infrastructure](#create-aws-infrastructure)
- [Deploy EngineerX project](#deploy-engineerx-project)
- [Destroy](#destroy)
- [EngineerX code repositories](#engineerx-code-repositories)





## Introduction to EngineerX project

EngineerX is an open source web application designed for engineers and specialists. It lets them share their ideas, create tutorials, represent themselves, employ other specialists and ...

Currently, The project is at it's first steps and includes a simple but awesome [Content Management System (CMS)](https://en.wikipedia.org/wiki/Content_management_system) that lets content providers to create and manage blog posts.

Key features of the project:

- It's [cloud native](https://en.wikipedia.org/wiki/Cloud_native_computing) and can easily get deployed on popular cloud providers like (AWS, Azure and ...)
- It benefits from microservices architectural best practices. It uses technologies like [docker](https://www.docker.com/) and [kubernetes](https://kubernetes.io/) to provide a horizontally scalable infrastructure with high availability.
- It includes a wide range of popular development frameworks and libraries like: [django](https://www.djangoproject.com/), [reactjs](https://reactjs.org/), [nextjs](https://nextjs.org/), [wagtail](https://wagtail.io/) and ...
- It benefits from [TDD](https://en.wikipedia.org/wiki/Test-driven_development) best practices and uses [unittest](https://docs.python.org/3/library/unittest.html#module-unittest), [jest](https://jestjs.io/), [react-testing-library](https://testing-library.com/docs/react-testing-library/intro/) and [cypress](https://www.cypress.io/) for different kinds of tests.
- It uses [Jenkins](https://www.jenkins.io/) declarative pipeline syntax to implement [CI/CD](https://en.wikipedia.org/wiki/CI/CD) pipelines. (Pipeline as code)
- Developers are able to write different kinds of tests and run them in a parallelized and non-blocking manner. In other words, testing environment is also elastic and scalable.
- It uses [Terraform](https://www.terraform.io/) to provision the required cloud infrastructure so it's really easy to deploy the whole project and destroy it whenever it's not needed any more. (Infrastructure as code)
- It's built on top of wagtail. Wagtail enables django developers to have a professional headless CMS which can be customized for many types of businesses.



## Requirements

To deploy this project on AWS, the only thing you need to have installed is [Docker](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwj3s9KT68vvAhX0SRUIHfQmAMcQFjAAegQIAxAE&url=https%3A%2F%2Fwww.docker.com%2F&usg=AOvVaw3p9e1qPvdfjCrUwPYAhUlS).

## Create AWS Infrastructure
First of all, you will need an AWS account with the IAM permissions listed on the [EKS module documentation](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md).

Then you have to create Access Keys (`access key ID` and `secret access key`) for that account. With these access keys, you can programmatically connect to aws and manage your infrastructure.

Now we are going to connect to AWS using [EngineerX's aws-cli](https://github.com/HsnVahedi/engineerx-aws-cli). run the aws-cli:

     docker run --rm -it --entrypoint bash hsndocker/aws-cli:latest
     
Then run these commands in aws-cli container:

#### 1. SET Required Environment variables

     REGION=<your-preferred-region>
     CLUSTER_NAME=<your-eks-cluster-name>
     ACCESS_KEY_ID=<your-aws-access-key-id>
     SECRET_KEY=<your-aws-secret-key>
     
#### 2. Authenticate with your access keys
      
     aws configure set aws_access_key_id $ACCESS_KEY_ID
     aws configure set aws_secret_access_key $SECRET_KEY
     aws configure set default.region $REGION
     
#### 3. Clone required repositories

     git clone https://github.com/HsnVahedi/engineerx-aws-infrastructure
     git clone https://github.com/HsnVahedi/engineerx-aws-deployment
     git clone https://github.com/HsnVahedi/engineerx-efs-pv
     git clone https://github.com/HsnVahedi/engineerx-efs-pvc
     
#### 5. Set POSTGRES_PASSWORD
Postgres will create the database with this password. Make sure to provide a valid postgres password, otherwise it will not create the database.

    POSTGRES_PASSWORD=<your-database-password>

#### 6. Create Infrastructure (EKS, RDS, EFS)
     cd engineerx-aws-infrastructure/
     terraform init
     terraform apply --var postgres_password=$POSTGRES_PASSWORD --auto-approve --var region=$REGION
     
#### 7. Update Kubeconfig
To be able to connect to our eks cluster, update kubeconfig:

     aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME
   
#### 8. Install Cluster Autoscaler
We need out eks cluster to be elastic. It has to be able to automatically add/remove worker nodes.

We can install this helm chart:

    sed -i 's/AWS_ACCOUNT_ID/$AWS_ACCOUNT_ID/g' cluster-autoscaler-chart-values.yaml
    helm repo add autoscaler https://kubernetes.github.io/autoscaler
    helm repo update
    helm install cluster-autoscaler --namespace kube-system autoscaler/cluster-autoscaler --values=cluster-autoscaler-chart-values.yaml
    
 #### 9. Install aws-efs-csi-driver
 To be able to mount EFS storage on containers running on kubernetes pods, we need to install the EFS's container storage interface:
 
    helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
    helm repo update
    helm upgrade --install aws-efs-csi-driver --namespace kube-system aws-efs-csi-driver/aws-efs-csi-driver


## Testing Environment
Integration tests are run in the kubernetes cluster created during [creating infrastructure](https://github.com/HsnVahedi/engineerx-aws-infrastructure). For each of the integration tests, a pod named `integration-${var.test_name}-${var.test_number}` will be created in `integration-test` namespace. Then tests are run using [cypress](https://www.cypress.io/).

## Cypress Dashboard
Each of the test runs will be recorded (including a video created by cypress) on the project's [cypress dashboard](https://dashboard.cypress.io/projects/4zons4).

## EngineerX code repositories

EngineerX is a big project and consists of several code bases:

- [engineerx-aws-cli](https://github.com/HsnVahedi/engineerx-aws-cli)
- [engineerx-aws-infrastructure](https://github.com/HsnVahedi/engineerx-aws-infrastructure)
- [engineerx-aws-deployment](https://github.com/HsnVahedi/engineerx-aws-deployment)
- [engineerx-backend](https://github.com/HsnVahedi/engineerx-backend)
- [engineerx-frontend](https://github.com/HsnVahedi/engineerx-frontend)
- [engineerx-integration](https://github.com/HsnVahedi/engineerx-integration)
- [engineerx-backend-unittest](https://github.com/HsnVahedi/engineerx-backend-unittest)
- [engineerx-frontend-unittest](https://github.com/HsnVahedi/engineerx-frontend-unittest)
- [engineerx-integration-test](https://github.com/HsnVahedi/engineerx-integration-test)
- [engineerx-efs-pv](https://github.com/HsnVahedi/engineerx-efs-pv)
- [engineerx-efs-pvc](https://github.com/HsnVahedi/engineerx-efs-pvc)
- [engineerx-backend-latest-tag](https://github.com/HsnVahedi/engineerx-backend-latest-tag)
- [engineerx-frontend-latest-tag](https://github.com/HsnVahedi/engineerx-frontend-latest-tag)
