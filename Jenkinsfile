def code

def COLOR_MAP =[
    'SUCCESS': 'good',
    'FAILURE': 'danger'
]

pipeline {
    agent any
    environment {
        pomVersion = readMavenPom().getVersion()
    }
    parameters {
        choice(name: "TEST_CHOICE", choices: ["maven", "gradle",], description: "Sample multi-choice parameter")
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
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
        stage('Carga script') {
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
        }
        stage ('TAG'){
			when {
				branch "main"
			}
            steps{
                script 
                {
                    withCredentials([usernamePassword(credentialsId: 'acceso-vpino-2', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) 
                    {
                    sh 'git config --global user.email "vppinol@gmail.com"'
                    sh 'git config --global user.name "virginiapinol"'
                    sh 'git tag "v."${pomVersion}'
                    sh 'git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/virginiapinol/ms-iclab.git --tags'
                    }
                }
            }
        }
        stage('Test artefacto') {
            when {
				branch "main"
			}
            steps {
                echo "Test artefacto versión ${pomVersion}"
                withCredentials([usernamePassword(credentialsId: 'jenkins-nexus', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    sh(
                        'curl -X GET -u "${GIT_USERNAME}:${GIT_PASSWORD}" -O http://178.128.155.87:8081/repository/devops-usach-nexus/com/devopsusach2020/DevOpsUsach2020/${pomVersion}/DevOpsUsach2020-${pomVersion}.jar'
                    )
                }
                sh(
                    "java -jar \"DevOpsUsach2020-${pomVersion}.jar\" & " + 
                    '''JAVA_PID="$!"
                    sleep 10
                    curl -X GET "http://178.128.155.87:8080/rest/mscovid/test?msg=testing"
                    kill $JAVA_PID'''
                )
            }
        }
    }
    post{
        success{
            setBuildStatus("Build succeeded", "SUCCESS");

            script{
                if (env.BRANCH_NAME != 'main') {
                  /*  echo "Realizando merge a main ${GIT_BRANCH}";
                    //git branch: "${GIT_BRANCH}", credentialsId: 'github_virginia', url: 'https://github.com/virginiapinol/ms-iclab.git'
                    withCredentials([usernamePassword(credentialsId: 'acceso-vpino-2', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh 'git config --global user.email "vppinol@gmail.com"'
                        sh 'git config --global user.name "virginiapinol"'
                        sh 'git branch'

                    sh '''
                        #!/bin/bash
                        git tag "v."${pomVersion}
                        git push --tags
                        git checkout main
                        git merge origin/${GIT_BRANCH}
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/virginiapinol/ms-iclab.git
                        git push origin --delete origin/${GIT_BRANCH}

                                                '''
                    }
                    */

                    slackSend channel:'#lab-ceres-mod4-sec1-status',
                        color:COLOR_MAP[currentBuild.currentResult],
                        message: "[Grupo5][Pipeline IC/CD][Rama: ${GIT_BRANCH}][Stage: build][Resultado:Éxito/Success]"
                    
                }
            }
        }

        failure {
            setBuildStatus("Build failed", "FAILURE");

            slackSend channel:'#lab-ceres-mod4-sec1-status',
                    color:COLOR_MAP[currentBuild.currentResult],
                    message: "[Grupo5][Pipeline IC/CD][Versión: 'v.'${pomVersion}][Stage: test][Resultado: Error/Fail]."
                  
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