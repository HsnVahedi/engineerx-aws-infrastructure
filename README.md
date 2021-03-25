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
     terraform apply --var postgres_password=$POSTGRES_PASSWORD --auto-approve --var region=$REGION --var cluster_name=$CLUSTER_NAME
     
#### 7. Update Kubeconfig
To be able to connect to our eks cluster, update kubeconfig:

     aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME
   
#### 8. Install Cluster Autoscaler
We need our eks cluster to be elastic. It has to be able to automatically add/remove worker nodes.

We can install this helm chart:

    AWS_ACCOUNT_ID=$(terraform output --raw account_id)
    sed -i 's/AWS_ACCOUNT_ID/$AWS_ACCOUNT_ID/g' cluster-autoscaler-chart-values.yaml
    helm repo add autoscaler https://kubernetes.github.io/autoscaler
    helm repo update
    helm install cluster-autoscaler --namespace kube-system autoscaler/cluster-autoscaler --values=cluster-autoscaler-chart-values.yaml
    
 #### 9. Install aws-efs-csi-driver
 To be able to mount EFS storage on containers running on kubernetes pods, we need to install the EFS's container storage interface:
 
    helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
    helm repo update
    helm upgrade --install aws-efs-csi-driver --namespace kube-system aws-efs-csi-driver/aws-efs-csi-driver
    
#### 10. Provision Persistent Volume
First of all, store EFS ids that has been created during step #6:

    MEDIA_EFS_ID=$(terraform output -raw media_efs_id)
    STATIC_EFS_ID=$(terraform output -raw static_efs_id)

Now Provision persistent volume:

    cd ../engineerx-efs-pv
    terraform init
    terraform apply --var static_efs_id=$STATIC_EFS_ID --var media_efs_id=$MEDIA_EFS_ID --auto-approve
    
#### 11. Create Persistent Volume Claim

    cd ../engineerx-efs-pvc
    terraform init
    terraform apply --auto-approve
    
## Deploy EngineerX project
After creating required infrastructure, we are ready to deploy our application:
    
    cd ../engineerx-aws-deployment/
    
#### 1. Install metrics server
We want to enable our [Horizontal Pod Autoscalers](https://github.com/HsnVahedi/engineerx-aws-deployment/blob/main/hpa.tf) automatically set the number of replicas for each of deployments. HPAs use these metrics to make decisions about removing/creatin a new pod.
    
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml
    
#### 2. Set docker credentials

    DOCKERHUB_CRED_USR=<your-dockerhub-username>
    DOCKERHUB_CRED_PSW=<your-dockerhub-password>

#### 3. Deploy the project
Now it's time to deploy our project:

    terraform init
    terraform apply --var region=$REGION --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var postgres_password=$POSTGRES_PASSWORD --auto-approve
    
#### 4. Initialize database
Now the project is up and running. To see the running pods, run this command:
    
    kubectl get pod
    
You should see some output like this:

    NAME                               READY   STATUS    RESTARTS   AGE
    backend-xxxxxxxxxx-yyyyy           1/1     Running   0          4m50s
    backend-ingress-6bbbb467c6-jth5g   1/1     Running   0          4m50s
    frontend-7cfffdfbfd-hpxrn          1/1     Running   1          4m50s
    ingress-59f5996797-pdwz2           1/1     Running   0          4m50s

To initialize the database with some fake data, execute this command in the backend container:

    kubectl exec backend-xxxxxxxxxx-yyyyy -- python manage.py initdb
    
You can also create a super user:

    kubectl exec -it backend-6b68ccf547-xw64p -- python manage.py createsuperuser
    
#### 5. Visit the WebSite
To visit our deployed website, first run this command to see existing kubernetes services:

    kubectl get service
    
You should see some output like this:

    NAME             TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
    backend          ClusterIP      172.20.119.232   <none>                                                                   80/TCP         31m
    backendingress   ClusterIP      172.20.47.184    <none>                                                                   80/TCP         31m
    frontend         ClusterIP      172.20.147.20    <none>                                                                   80/TCP         31m
    ingress          LoadBalancer   172.20.16.41     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-yyyyyyyyy.<REGION>.elb.amazonaws.com   80:31309/TCP   71m
    kubernetes       ClusterIP      172.20.0.1       <none> 

The `ingress`'s external-ip is `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-yyyyyyyyy.<REGION>.elb.amazonaws.com`. So our website is accessible on `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-yyyyyyyyy.<REGION>.elb.amazonaws.com` and our administration pages are accessible on `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-yyyyyyyyy.<REGION>.elb.amazonaws.com/admin`.

## Destroy

In order to destroy everything, first change directory to `/aws/engineerx-aws-deployment` then destroy the deployment:

    cd ../engineerx-aws-deployment
    terraform destroy --var region=$REGION --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var postgres_password=$POSTGRES_PASSWORD --var cluster_name=$CLUSTER_NAME --auto-approve
    
 Now delete metrics server:
 
    kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml
    
 Delete persistent volume claims:
 
    cd ../engineerx-efs-pvc
    terraform destroy --auto-approve
    
 Delete persistent volumes:
 
    cd ../engineerx-efs-pv
    terraform destroy --var static_efs_id=$STATIC_EFS_ID --var media_efs_id=$MEDIA_EFS_ID --auto-approve
    
 Destroy AWS Infrastructure:
 
    cd ../engineerx-aws-infrastructure
    terraform refresh --var postgres_password=$POSTGRES_PASSWORD --var region=$REGION --var cluster_name=$CLUSTER_NAME
    terraform destroy --auto-approve --var postgres_password=$POSTGRES_PASSWORD --var region=$REGION --var cluster_name=$CLUSTER_NAME
    
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
