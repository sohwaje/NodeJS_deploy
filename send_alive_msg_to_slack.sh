#!/bin/sh
# 컨테이너가 실행 -> 앱 URL 체크 -> 성공 또는 실패 메시지를 slack 채널로 보낸다.

# Slack 웹 훅주소
WEBHOOK_ADDRESS='https://hooks.slack.com/services/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'
# 날짜
DATE=$(date '+%Y-%m-%d %H:%M:%S')
# json 형식의 ALERT 메시지
URL_STATUS_OK="{\"text\": \"SUCCESS: NodeJS container is running: $DATE\"}"
URL_STATUS_Error="{\"text\": \"ERROR: no response: $DATE\"}"

# URL
URL="http://127.0.0.1:3000"

# URL 체크
check(){
  if [ $? = 0 ]; then # Bash에서는 "=="가 맞지만, Bourne shell에서는 "="를 쓴다.
    curl -X POST -H 'Content-type: application/json' --data "$URL_STATUS_OK" $WEBHOOK_ADDRESS > /dev/null 2>&1
  else
    curl -X POST -H 'Content-type: application/json' --data "$URL_STATUS_Error" $WEBHOOK_ADDRESS > /dev/null 2>&1
  fi
  exit 1
}

# check 함수 실행
curl -s -o "/dev/null" $1 $URL
check
