# Python Jenkins Kubernetes - Daniel Kohav

# ABOUT
This setup consists of a Python shop app utilizing a MongoDB database. The application's lifecycle is managed through a Jenkins pipeline, which handles building, testing, publishing, and deploying updates to a Kubernetes cluster. The application is deployed specifically to an EKS cluster. To facilitate log management, the application's logs are sent to an ELK (Elasticsearch, Logstash, and Kibana) stack using Filebeat. A customized Filebeat Docker image is employed to aggregate the application's logs    .

-- Python app --  
A sample shop app with MongoDB database.  
The application is dockerized.  

-- Jenkins --  
A pipeline that builds, tests, publishes and deploys the udpates to kubernetes cluster.

-- kubernetes --  
The application is deployed to an EKS cluster.

-- ELK Stack --  
The application logs are sent to an ELK stack using Filebeat.
A custom filebeat docker image is used for aggeregating the application's logs.  
  
  
![alt text](https://lh3.googleusercontent.com/drive-viewer/AITFw-xR__Zwd6GdWyOWmVOIn9hJeCFjaAKA8lYJjtB29McGkOt2UNrccU6VpBKdnsWXarEZ3gXozPrwywK9jctssNfyh1gG=s1600)

# USAGE  

###### Requirements:

Infrastructure:  
Jenkins + Agent Node  
SCM (Github/Gitlab)  
EKS Cluster  
ELK Server  
Dockerhub Registries  

Docker Images:  
python app  
filebeat  
ELK docker-compose  

Setting the project is made of 2 steps - privisioning the infrastructure, and configuring the infrastructure.  


#### Provisioing the infrastructure

###### Jenkins+Agent Node:
Configure a Jenkins Server and a Jenkins agent.  
Jenkins configuration guide: https://octopus.com/blog/jenkins-docker-install-guide  
Jenkins agent configuration guide: https://www.pluralsight.com/resources/blog/cloud/adding-a-jenkins-agent-node  


###### SCM:  
Configure a github/gitlab repository.  
Simple- Github  
Advance-  Gitlab  (This readme is mostly focusted on Gitlab)  
Gitlab provisioining guide: https://thenewstack.io/how-to-deploy-gitlab-server-using-docker-and-ubuntu-server-22-04/  



###### EKS Cluster:  
An EKS cluster is required.  
Terraform files for provisioning the cluster can be found in '/terraform/privision-eks' directive, and a readme file can be found in the '/terraform' directive.
```
terraform init
terraform apply
```
A loadbalancer IP (as an output parameter) will be displayed in the CLI, after the provisioning is complete,  
and will be the entrypoint to the cluster.  
After provisioning the cluster, configure the cluster context:
```
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
```
###### ELK Server:
An ELK server is required.  
A docker-compose example can be found in the ELK directive.  
ELK configuration guide: https://logz.io/blog/elk-stack-on-docker/  

###### Dockerhub registries:
Two public dockerhub regiesties are required:  
One for the application and the second for a custom filebeat image.  


##### Docker images
The kubernetes cluster needs 2 Docker images:  
1: Python app  
The Dockerfile in this repository will build a docker image of the shopapp.  
Build the image and push it to a public Dockerhub registry.  
```
docker build -t 'my_repo_name/python_app' .
docker push my_repo_name/python_app
```  

2: Filebeat image  
A custom filebeat image is used to aggregate logs.  
A dockerfile can be found in '/ELK/filebeat' directive, build an image and push it to a Dockerhub registry.  
```
cd ELK/filebeat
docker build -t 'my_repo_name/filebeat' .
docker push my_repo_name/filebeat
``` 
The names of the registries will be later added to the '.env' file.  
Change the variables in the .env file to the docker images we created:  
```
FILEBEAT_DOCKER_IMAGE=my_repo_name/filebeat  
PYTHON_DOCKER_IMAGE=my_repo_name/python_app  
```
Also, edit the name of the EKS cluster to the EKS cluster we provisioned:  
```
EKS_CONTEXT=my-eks-context  
```
```
export $(cat .env | xargs) && rails c
```

#### Configuring the Infrastructure:
###### Jenkins+Agent Node:
Connect Jenkins to the SCM  
Jenkins+Gitlab tutorial: https://medium.com/@meanuraj.sl/how-to-integrate-jenkins-and-gitlab-3e8b11cf29cc  
Install and configure AWS CLI on the Agent Node: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html  

```
aws configure
```
Jenkins Credentials 'MONGODB_CONNECTION' for the MongoDB connection string configured in Jenkins GUI. 
kubectl installed on Jenkins agent node, configure the kubectl context to the EKS cluster after it's done provisioning:
```
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
``` 

###### SCM:
Create a repository for the project (cloning/forking the repository is the simplest way to do it).  
Create a integration/webhook from SCM to Jenkins:  https://hevodata.com/learn/gitlab-webhook-jenkins-integration/  

###### EKS Cluster:
-- Kubernetes Cluster Prequisites --  
MongoDB connection string:  
The python application needs a valid MongoDB connection string.  
Set a kubernetes secret for the MongoDB connection string:  
```
kubectl create secret generic mysecret --from-literal=MY_ENV_MONGO=<MongoDB_connection_string>
```
ELK Server IP:  
Filebeat needs the public ip of the ELK server to send logs.  
Set a configmap for the ELK server's public ip:  
```
kubectl create configmap elastic-ip-configmap --from-literal=my_elastic_ip=<my_ELK_public_ip>
```
-- Deploy cluster --  
An example deployment of the cluster can be found at /terraform/deploy-cluster directive.  
```
terraform apply -var FILEBEAT_IMAGE=$FILEBEAT_IMAGE -var PYTHON_DOCKER_IMAGE=$PYTHON_DOCKER_IMAGE
```