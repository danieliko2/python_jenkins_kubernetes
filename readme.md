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
  

![alt text](https://lh3.googleusercontent.com/drive-viewer/AFGJ81rpAlRxqP4OkPpaZLdEA0kh2FIKehFHvbzZhWQtRZLL80jqETrQEB8zg2Wlq_Mxlf_qxbKnW4t_1HJ4GYWJu58o9SrWdQ=s1600
  

# USAGE  
-- Prerequisites --  
A Jenkins server connected to SCM
AWS CLI installed on Jenkins host
EKS Cluster (Terraform configuration files for EKS cluster can be found in terraform directive)  

-- Deploy ELK server --  
docker-compose ELK example can be found in ELK directive  

-- Provisioning EKS --  
Provising an EKS cluster, an example can be found in terraform/provision-eks directive.  

-- .env --  
After provisioning the EKS cluster, edit the .env with the name of the docker images of your choice, and the name of the EKS cluster for the cluster context.  

-- Kubernetes Cluster Prequisites --  
MongoDB connection string:
Set a kubernetes secret for the MongoDB connection string:
```
kubectl create secret generic mysecret --from-literal=MY_ENV_MONGO=<MongoDB_connection_string>
```
ELK Server IP:
Set a configmap for ELK server public ip
```
kubectl create configmap elastic-ip-configmap --from-literal=my_elastic_ip=<my_ELK_ip>
```
-- Deploy cluster --  
An example deployment of the cluster can be found at /terraform/deploy-cluster directive.  

-- Jenknins Prequisites --  
AWS CLI installed on Jenkins host
Jenkins Credentials 'MONGODB_CONNECTION' for the MongoDB connection string.
Connection to project SCM (github, gitlab, etc)