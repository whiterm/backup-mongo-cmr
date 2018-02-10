FROM phantomx/cloud-cli:latest

MAINTAINER Belyy Roman

RUN apt-get update && apt-get install -y apt-transport-https

RUN  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 && \
     echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list && \
     apt-get update && \
     apt-get install -y mongodb-org cron rsyslog p7zip-full

ENV LOCAL_BACKUP_STORE_DIR "/backup"
ENV SERVER_BACKUP_STORE_DIR "/backup/dev"
ENV BACKUP_DIR "/data/db"
ENV MAIN_DIR "/opt/scripts/"
ENV MONGO_URL=mongodb:27017

COPY backup-cron /etc/cron.d/backup-cron
RUN touch /var/log/cron.log
RUN touch /root/env.sh


WORKDIR $MAIN_DIR
ADD ./scripts $MAIN_DIR
RUN chmod a+x backup.sh restore.sh
RUN chmod 750 cron_task.sh
RUN chmod 750 /root/env.sh

RUN crontab /etc/cron.d/backup-cron

#CMD ./backup.sh
CMD rsyslogd && \
 printenv | grep -v "\(PPID\|SHELL\|BASH\|PATH\|LS_COLORS\|PWD\|HOME\|ENV_GPG_KEYS\)"  >  /root/env.sh && \
 cron && tail -F /var/log/syslog /var/log/cron.log