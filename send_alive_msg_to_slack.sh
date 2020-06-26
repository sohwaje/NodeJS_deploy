#!/bin/sh
# 컨테이너가 실행되면 slack 채널로 "I'm Alive" 메시지를 보낸다.

# Slack 주소
WEBHOOK_ADDRESS='https://hooks.slack.com/services/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'
# 날짜
DATE=$(date '+%Y-%m-%d %H:%M:%S')
# json 형식의 ALERT 메시지
URL_STATUS_OK="{\"text\": \"SUCCESS: Container is running. Date:  $DATE\"}"
URL_STATUS_Error="{\"text\": \"ERROR: no response Date:  $DATE\"}"

# URL
URL="http://127.0.0.1:3000"

# URL 체크
function check {
  if [ $? == 0 ]; then
    curl -X POST -H 'Content-type: application/json' --data "$CURL_TEXT" $WEBHOOK_ADDRESS > /dev/null 2>&1
  elif [ $? -ne 0 ]; then
    curl -X POST -H 'Content-type: application/json' --data "$URL_STATUS_Error" $WEBHOOK_ADDRESS > /dev/null 2>&1
  elif [ $? -eq 6 ]; then
    curl -X POST -H 'Content-type: application/json' --data "$URL_STATUS_Error" $WEBHOOK_ADDRESS > /dev/null 2>&1
  elif [ $? -eq 7 ]; then
    curl -X POST -H 'Content-type: application/json' --data "$URL_STATUS_Error" $WEBHOOK_ADDRESS > /dev/null 2>&1
  else
    curl -X POST -H 'Content-type: application/json' --data "$URL_STATUS_Error" $WEBHOOK_ADDRESS > /dev/null 2>&1
  fi
  exit 1
}

# check 함수 실행
curl -s -o "/dev/null" $1 $URL
check
