FROM phantomx/cloud-cli:latest

MAINTAINER Belyy Roman

RUN apt-get update && apt-get install -y mongodb-clients cron rsyslog

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