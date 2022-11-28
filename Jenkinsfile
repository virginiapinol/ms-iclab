def code

def COLOR_MAP =[
    'SUCCESS': 'good',
    'FAILURE': 'danger'
]

pipeline {
    agent any

    parameters {
        choice(name: "TEST_CHOICE", choices: ["maven", "gradle",], description: "Sample multi-choice parameter")
    }
    stages {
        /*stage('Checkout') {
            steps {
                checkout scm
            }
        }*/
        stage('Agregando permisos'){
            steps {
                sh '''#!/bin/bash
                echo shell commands here
                chmod +x mvnw
                chmod +x gradlew
                '''
            }
        }
        stage('get_commit_details') {
            steps {
                script {
                    env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
                    env.GIT_AUTHOR = sh (script: 'git log -1 --pretty=%cn ${GIT_COMMIT}', returnStdout: true).trim()
                    //env.GIT_TAG = sh (script: 'git tag --contains "0.0.4"', returnStdout: true).trim()
                    env.GIT_BRANCH = sh (script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    //env.GIT_TAG = sh (script: 'git describe --tags --abbrev=0', returnStdout: true).trim()
                }
            }
        }
       /* stage('Carga script') {
            steps {
                script {
                    code = load "./${params.TEST_CHOICE}.groovy"
                }
            }
        }
        stage('Compilación') {
            steps {
                script {
                    code.Compilacion()
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    code.Test()
                }
            }
        }
       stage('Análisis Sonarqube') {
            environment {
                scannerHome = tool 'SonarScanner'
            }
            steps {
                 withSonarQubeEnv('SonarServer-1') {
                    sh './mvnw clean verify sonar:sonar -Dsonar.projectKey=lab1-mod3 -Dsonar.host.url=http://178.128.155.87:9000 -Dsonar.login=sqp_3b879c0e3e708f0dbcbfdfdf81b432e84560c4e1'
                }
            }
            
        }
        stage("Comprobación Quality gate") {
            steps {
                waitForQualityGate abortPipeline: true
            }
        }
        stage ('Publish Nexus'){
			when {
				branch "main"
			}
            steps{

                script {
                    pom = readMavenPom file: "pom.xml";
                    //filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    //echo "*** aqui : ${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    //def file = ${pom.artifactId}-${pom.version}.${pom.packaging}
                    echo "*** aqui : ;"//${pom.artifactId} ${pom.version} ${pom.packaging}"
                    artifactPath = "./build/${pom.artifactId}-${pom.version}.${pom.packaging}";//filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "Artifact exists: ${artifactPath}";
                         nexusPublisher nexusInstanceId: 'Nexus-1', nexusRepositoryId: 'devops-usach-nexus', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: "${artifactPath}"]], mavenCoordinate: [artifactId: 'DevOpsUsach2020', groupId: 'com.devopsusach2020', packaging: 'jar', version: pom.version]]]
                    } else {
                        echo "Artifact does not exist: ${artifactPath}";
                    }
                }
            }
        }*/
    }
    post{
        success{
            setBuildStatus("Build succeeded", "SUCCESS");

            /*slackSend channel:'#devops-equipo5',
                color:COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* ${env.GIT_AUTHOR} ${env.JOB_NAME} build ${env.BUILD_NUMBER}  Ejecución exitosa"
*/

            echo "Realizando merge a main ${GIT_BRANCH}";

            script{
                //git branch: "${GIT_BRANCH}", credentialsId: 'github_virginia', url: 'https://github.com/virginiapinol/ms-iclab.git'
                sh 'git config --global user.email "vppinol@gmail.com"'
                sh 'git config --global user.name "Virginia Pino"'
                sh 'git tag -a "0.0.4" -m "Nueva versión"'
                sh 'git merge origin/${GIT_BRANCH}'
                sh 'git commit -am "Merged feature branch to main"'
                sh 'git fetch origin'
                sh 'git branch'
                sh 'git push origin main'

               /* sh '''
                #!/bin/bash
                git checkout origin/main
                git merge origin/${GIT_BRANCH}
                git push 
                git push origin --delete origin/${GIT_BRANCH}

                '''*/
            }
        }

        failure {
            setBuildStatus("Build failed", "FAILURE");

            /*slackSend channel:'#devops-equipo5',
                    color:COLOR_MAP[currentBuild.currentResult],
                    message: "*${currentBuild.currentResult}:* ${env.GIT_AUTHOR} ${env.JOB_NAME} Ejecución fallida en stage: build ${env.BUILD_NUMBER}"
*/
        } 
    }
}

void setBuildStatus(String message, String state) {
    step([
        $class: "GitHubCommitStatusSetter",
        reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/virginiapinol/ms-iclab"],
        contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
        errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
        statusResultSource: [$class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]]]
    ]);
}