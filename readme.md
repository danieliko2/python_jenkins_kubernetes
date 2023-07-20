# Python Jenkins Kubernetes - Daniel Kohav

# ABOUT
This setup consists of a Python shop app utilizing a MongoDB database. The application's lifecycle is managed through a Jenkins pipeline, which handles building, testing, publishing, and deploying updates to a Kubernetes cluster. The application is deployed specifically to an EKS cluster. To facilitate log management, the application's logs are sent to an ELK (Elasticsearch, Logstash, and Kibana) stack using Filebeat. A customized Filebeat Docker image is employed to aggregate the application's logs    .

-- Python app --  
A sample shop app with MongoDB database.

-- Jenkins --  
A pipeline that builds, tests, publishes and deploys the udpates to kubernetes cluster.

-- kubernetes --  
The application is deployed to an EKS cluster.

-- ELK Stack --  
The application logs are sent to an ELK stack using Filebeat.
A custom filebeat docker image is used for aggeregating the application's logs.  
  
  
![alt text](https://lh3.googleusercontent.com/drive-viewer/AFGJ81rpAlRxqP4OkPpaZLdEA0kh2FIKehFHvbzZhWQtRZLL80jqETrQEB8zg2Wlq_Mxlf_qxbKnW4t_1HJ4GYWJu58o9SrWdQ=s1600)
  
  

# USAGE  
-- Prerequisites --  
A Jenkins server connected to SCM
AWS CLI installed on Jenkins host
EKS Cluster (Terraform configuration files for EKS cluster can be found in terraform directive)  

-- Docker images --
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
FILEBEAT_DOCKER_IMAGE=my_repo_name/filebeat
PYTHON_DOCKER_IMAGE=my_repo_name/python_app

-- Deploy ELK server --  
A configured ELK server is required.
docker-compose ELK example can be found in '/ELK/' directive.
```
docker-compose up
```  
  
-- Jenknins Prequisites --  
AWS CLI installed and configured on Jenkins host
```
aws configure
```
Jenkins Credentials 'MONGODB_CONNECTION' for the MongoDB connection string configured in Jenkins GUI.
Configured connection/webhook to project SCM (github, gitlab, etc).
  
-- Provisioning EKS --  
Provising an EKS cluster, an example can be found in '/terraform/provision-eks' directive.  
A readme file is available in '/terraform' directive.
```
terraform apply
```
A loadbalancer IP (as an output parameter) will be displayed in the CLI, after the provisioning is complete,  
and will be the entrypoint to the cluster.  
   
-- .env --  
After provisioning the EKS cluster, edit the .env file with the following:  
Names of the Dockerhub registries (Python app and Custom Filebeat, already done in previous 'Docker images' step).  
The name of the EKS cluster for the cluster context.
```
export $(cat .env | xargs) && rails c
```

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