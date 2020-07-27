FROM node:carbon

#app 폴더 만들기 - NodeJS 어플리케이션 
RUN mkdir -p /app
#winston 등을 사용할떄엔 log 폴더도 생성

#어플리케이션 폴더를 Workdir로 지정
WORKDIR /app

#서버 파일 복사 ADD [어플리케이션파일 위치] [컨테이너내부의 어플리케이션 파일위치]
#Dockerfile과 서버 파일이 같은 위치에 있어서 ./입니다
ADD ./ /app
COPY send_alive_msg_to_slack.sh /

#패키지 파일 빌드
RUN npm install
RUN npm install nodemon -g

# 컨테이너 생성 후 slack으로 알림을 보내기 위한 스크립트에 실행 권한 부여
RUN chmod +x send_alive_msg_to_slack.sh

#배포버젼으로 설정 - 이 설정으로 환경을 나눌 수 있습니다.
ENV NODE_ENV=production

#서버실행
CMD node nodejs_tutorial_server.js
