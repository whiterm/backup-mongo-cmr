# backup-mongo-cmr
A set of scripts to create backups of the Mongo database and save them in the `cloud.mail.ru`

To create backups on a schedule. The schedule changes occur in the file `/etc/cron.d/backup-cron`
``` 
    docker run -e MAILRU_USER=backup-mail@bk.ru -e MAILRU_PASSWORD=my_password --link mongodb:mongodb --volumes-from:mongodb phantomx/backup-mongo-cmr 
```

To create a backup and save it locally to disk. Backup will not be sent to the `cloud.mail.ru`
```
    mkdir -p `pwd`/tmp
    docker run --rm --link mongodb:mongodb --volumes-from=mongodb -v `pwd`/tmp:/backup phantomx/backup-mongo-cmr ./backup.sh -local
```

To create a backup and save it to the `cloud.mail.ru`
```
    docker run -e MAILRU_USER=backup-mail@bk.ru -e MAILRU_PASSWORD=my_password --link mongodb:mongodb --volumes-from=mongodb phantomx/backup-mongo-cmr ./backup.sh
```

Restore the Mongo database from an earlier backup
```
    docker run -e MAILRU_USER=backup-mail@bk.ru -e MAILRU_PASSWORD=my_password --link mongodb:mongodb --volumes-from=mongodb phantomx/backup-mongo-cmr ./restore.sh
```
