#!/bin/sh
########### #################################################################
# 컨테이너 실행 -> 앱 URL 체크 -> 성공 또는 실패 메시지를 slack 채널로 보낸다. #
#############################################################################

# 상태체크해야 할 컨테이너의 URL
URL="http://127.0.0.1:3000"

# Slack 웹 훅주소
WEBHOOK_ADDRESS='http://'

# 슬랙으로 메시지 보내기 함수 good = 녹색, false = 빨간색
slack_message(){
    # $1 : message
    # $2 : true=good, false=danger

  COLOR="danger"
  if $2 ; then
      COLOR="good"
  fi
  curl -s -d 'payload={
      "attachments":
      [
        {"color":"'"$COLOR"'",
         "pretext":"<!channel> *NODEJS DEPLOY INFORMATION*",
         "text":"*HOST* : '"$HOSTNAME"' \n*MESSAGE* : '"$1"'"}
      ]
  }' $WEBHOOK_ADDRESS > /dev/null 2>&1
}

# 생성된 컨테이너의 URL을 체크
function check_url() {
  curl -s -o "/dev/null" $URL
  if [ $? = 0 ]; then # Bash에서는 "=="가 맞지만, Bourne shell에서는 "="를 쓴다.
    slack_message "container is running " true  # 성공
    exit 0
  else
    slack_message "failure" false               # 실패
    exit 1
  fi
}

# URL 체크 실행
check_url
