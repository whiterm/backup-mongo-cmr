# backup-mongo-cmr
Backup mongodb data on cloud mail ru

To start backup the scheduler
``` 
    docker run -e MAILRU_USER=backup-mail@bk.ru -e MAILRU_PASSWORD=my_password --link mongodb:mongodb --volumes-from:mongodb phantomx/backup-mongo-cmr 
```

To start only one backup mongo database
```
    docker run -e MAILRU_USER=backup-mail@bk.ru -e MAILRU_PASSWORD=my_password --link mongodb:mongodb --volumes-from:mongodb phantomx/backup-mongo-cmr ./backup.sh
```

To start only one restore mongo database
```
    docker run -e MAILRU_USER=backup-mail@bk.ru -e MAILRU_PASSWORD=my_password --link mongodb:mongodb --volumes-from:mongodb phantomx/backup-mongo-cmr ./restore.sh
```
