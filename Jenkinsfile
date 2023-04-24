pipeline {
    agent {
        label 'node1'
    }
    stages {
            stage('Clean') {
                steps {
                    sh 'echo Cleaning existing containers'
                    sh 'docker ps -aq | xargs docker container rm -f || exit 0'
                }
            }
            stage('Installations') {
                steps {
                    sh 'echo Installing requirements'
                    sh 'pip3 install -r newshopapp/requirements.txt'
                }
            }
            stage('Build') {
                steps {
                    sh 'echo Building App..'
                    sh 'docker build -t myapp .'
                }
            }
            stage('Test') {
                steps {
                    withCredentials([string(credentialsId: 'MONGODB_PASS', variable: 'mongo_sec')]) {
                        sh 'echo Running app'
                        sh "docker run -p 8000:8000 -e MONGO_PASS='${mongo_sec}' -d myapp"
                    }
                    sh 'echo Testing..'
                    sh 'cd newshopapp'
                    sh 'python3 -m pytest'
                    sh 'docker ps -aq | xargs docker container stop'
                    sh 'cd ..'
                }
            }
            stage('Tag') {
                steps {
                    echo 'Tagging..'
                    sh 'docker tag myapp danieliko/kafka_python'

                }
            }
            stage('Publish') {
                steps {
                    echo 'Publishing to Dockerhub'
                    sh 'docker push danieliko/kafka_python'

                }
            }
            stage('Deploy') {
                steps {
                    echo 'Deploying app to EKS'
                    sh 'aws eks update-kubeconfig --name education-eks-I3NsDpN6'
                    sh 'kubectl rollout restart deployment/scalable-nginx-example'
                }
            }
            stage('Post Clean') {
                steps {
                    sh 'pip3 uninstall -y -r newshopapp/requirements.txt'

                }
            }
    }
}