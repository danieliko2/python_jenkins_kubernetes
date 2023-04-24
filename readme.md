# Python Jenkins Kubernetes - Daniel Kohav

# ABOUT
This is a project that has 4 major technologies implemented in it:

-- Python --

A simple python shop app with MongoDB as a Database

-- Jenkins --

A pipeline that builds, tests, deploys and updates the kubernetes image.

-- kubernetes --

The application is deployed to an EKS cluster

-- ELK Stack --

The application logs are sent to an ELK stack using Filebeat

# USAGE  
-- Requirements --

MongoDB password:
kubectl create secret generic mysecret --from-literal=MY_ENV_MONGO=<my mongo password>

ELK Stack Public IP:
kubectl create configmap elastic-ip-configmap --from-literal=my_elastic_ip=<my ELK ip>

Change the cluster name in Jenkinsfile for your cluster name
