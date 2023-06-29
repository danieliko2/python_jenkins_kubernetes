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
                    sh 'export $(cat .env | xargs)'
                }
            }
            stage('Build') {
                steps {
                    sh 'echo Building App..'
                    sh "docker build -t ${env.PYTHON_DOCKER_IMAGE} ."
                }
            }
            stage('Test') {
                steps {
                    withCredentials([string(credentialsId: 'MONGODB_CONNECTION', variable: 'mongo_con')]) {
                        sh 'echo Running app'
                        sh "docker run -p 8000:8000 -e MONGO_CON='${mongo_sec}' -d myapp"
                    }
                    sh 'echo Testing..'
                    sh 'cd newshopapp'
                    sh 'python3 -m pytest'
                    sh 'docker ps -aq | xargs docker container stop'
                    sh 'cd ..'
                }
            }
            stage('Publish') {
                steps {
                    echo 'Publishing to Dockerhub'
                    sh "docker push ${env.PYTHON_DOCKER_IMAGE}"

                }
            }
            stage('Deploy') {
                steps {
                    echo 'Deploying app to EKS'
                    sh "aws eks update-kubeconfig --name ${env.EKS_CONTEXT}"
                    sh 'kubectl rollout restart deployment/python-app'
                }
            }
            stage('Post Clean') {
                steps {
                    sh 'pip3 uninstall -y -r newshopapp/requirements.txt'

                }
            }
    }
}