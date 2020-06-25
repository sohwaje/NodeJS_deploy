#!/bin/sh
# 컨테이너가 실행되면 slack 채널로 "I'm Alive" 메시지를 보낸다.

# Slack 주소
WEBHOOK_ADDRESS='https://hooks.slack.com/services/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'

# 날짜
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# json 형식의 ALERT 메시지
ALERT_TEXT="{\"text\": \"MSG: I'm Alive. Date:  $DATE\"}"

# alive msg 실행
curl -X POST -H 'Content-type: application/json' --data "$ALERT_TEXT" $WEBHOOK_ADDRESS > /dev/null 2>&1
