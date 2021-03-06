/*[1] 파이프라인에서 진행할 각 stage를 정의하는 파라미터 */
def useDockerBuild = true
def useDockerPush = true
def useDeploy = true


/* stage Flow를 확인할 수 있는 설정.
예외 발생 시 기본값으로 동작하도록 try-catch 설정 */
node(''){
stage("Flow Check", {
    try {
        println "  DOCKER BUILD = $USE_DOCKERBUILD"
        useDockerBuild = "$USE_DOCKERBUILD" == "true"
    }
    catch (MissingPropertyException e) {
        println "  DOCKER BUILD = true"
    }

    try {
        println "  DOCKER PUSH = $USE_DOCKERPUSH"
        useDockerPush = "$USE_DOCKERPUSH" == "true"
    }
    catch (MissingPropertyException e) {
        println "  DOCKER PUSH = true"
    }

    try {
        println "  DOCKER DEPLOY = $USE_DEPLOY"
        useDeploy = "$USE_DEPLOY" == "true"
    }
    catch (MissingPropertyException e) {
        println "  DOCKER DEPLOY = true"
    }
})

/* 파라미터 검증 단계. 필수 파라미터들은 예외 처리를 하지 않음 */
stage("Parameter Check", {
    println "  GIT_URL = $GIT_URL"
    println "  BRANCH_SELECTOR = $BRANCH_SELECTOR"
    println "  ACR_ID = $ACR_ID"
    println "  ACR_PASSWORD = $ACR_PASSWORD"
    println "  ACR_SERVER = $ACR_SERVER"
    println "  CONTAINER_NAME = $CONTAINER_NAME"
    println "  SSH_PASS = $SSH_PASS"
    println "  SSH_USER = $SSH_USER"
    println "  TARGET_IP = $TARGET_IP"
    println "  SSH_PORT = $SSH_PORT"

})

/* 넘겨 받은 GitUrl과 Branch를 사용하여 Git CheckOut 을 실행.
Test나 Build 중 하나라도 Flow에 포함되어 있다면 이 단계가 실행 */
stage("Git CheckOut", {
    if (useDockerBuild || useDockerPush) {
        println "Git CheckOut Started"
        checkout(
                [
                        $class                           : 'GitSCM',
                        branches                         : [[name: '${BRANCH_SELECTOR}']],
                        doGenerateSubmoduleConfigurations: false,
                        extensions                       : [],
                        submoduleCfg                     : [],
                        userRemoteConfigs                : [[url: '${GIT_URL}']]
                ]
        )
        println "Git CheckOut End"
    } else {
        println "Git CheckOut Skip"
    }
})

/* 구체적인 테스트 - 빌드 - 배포 - 실행 파이프라인 */

stage('Docker Build') {
    if (useDockerBuild) {
        println "Docker Build"
       /* SLACK Configuration */
        slackSend (channel: '#hiclass-build-deploy-alert', color: '#FFFF00', message: "Docker BUILD START: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        try {
            sh 'docker image build -t ${ACR_SERVER}/node_js:${BUILD_NUMBER} .'
       /* SLACK Configuration */
            slackSend (channel: '#hiclass-build-deploy-alert', color: '#00FF00', message: "Docker BUILD SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            println "Docker Build End"job/testbuild/configure
        }
        catch (Exception e) {
        /* SLACK Configuration */
            slackSend (channel: '#hiclass-build-deploy-alert', color: '#FF0000', message: "Docker BUILD Error:${e} Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            throw e;  /* 빌드 중단 */
        }
     } else {
        println "Docker Build Skip"
    }
}


stage('Docker Push') {
    if (useDockerPush) {
        println "Docker Login"
        /* SLACK Configuration */
        slackSend (channel: '#hiclass-build-deploy-alert', color: '#FFFF00', message: "Docker PUSH START: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        try {
            sh 'docker login ${ACR_SERVER} -u ${ACR_ID} -p ${ACR_PASSWORD}'
            println "Docker Push"
            sh 'docker push ${ACR_SERVER}/node_js:${BUILD_NUMBER}'
            println "Docker Push End"
        /* SLACK Configuration */
            slackSend (channel: '#hiclass-build-deploy-alert', color: '#00FF00', message: "Docker PUSH SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    }
        catch (Exception e) {
        /* SLACK Configuration */
            slackSend (channel: '#hiclass-build-deploy-alert', color: '#FF0000', message: "Docker PUSH Error:${e} Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            throw e;  /* 빌드 중단 */
        }
    } else {
        println "Docker Push Skip"
    }
}

stage('Deploy') {
    if (useDeploy) {
        println "Create container"
        /* SLACK Configuration */
        slackSend (channel: '#hiclass-build-deploy-alert', color: '#FFFF00', message: "Deploy START: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        try {
        /* .stripIndent() 멀티라인 실행 구현 */
        /* 배포할 서버에 ssh로 로그인 -> 기존 도커 컨테이너 중지 및 삭제 -> 도커 레지스트리 로그인 -> 이미지 가져오기 -> 컨테이너 생성 -> 컨테이너 실행 */
            sh'''
            sshpass -p${SSH_PASS} ssh -T ${SSH_USER}@${TARGET_IP} -p${SSH_PORT} -oStrictHostKeyChecking=no <<EOF
            docker stop ${CONTAINER_NAME}_pro
            docker rm ${CONTAINER_NAME}_pro
            docker login ${ACR_SERVER} -u ${ACR_ID} -p ${ACR_PASSWORD}
            docker pull ${ACR_SERVER}/node_js:${BUILD_NUMBER}
            docker create --name ${CONTAINER_NAME}_pro -p 3000:3000 ${ACR_SERVER}/node_js:${BUILD_NUMBER}
            docker start ${CONTAINER_NAME}_pro
            sleep 20
            echo "docker exec ${CONTAINER_NAME}_pro ./send_alive_msg_to_slack.sh > /dev/null 2>&1"
            docker exec ${CONTAINER_NAME}_pro ./send_alive_msg_to_slack.sh > /dev/null 2>&1
            echo "done"
            EOF
            '''.stripIndent()
        /* SLACK Configuration */
            slackSend (channel: '#hiclass-build-deploy-alert', color: '#00FF00', message: "Deploy SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            }
        catch (Exception e) {
            /* SLACK Configuration */
              slackSend (channel: '#hiclass-build-deploy-alert', color: '#FF0000', message: "Deploy Error:${e} Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
              throw e;  /* 빌드 중단 */
        }
    } else {
        println "Docker Deploy Skip"
    }
  }
}
