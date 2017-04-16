/*global db, print, tojson*/

var isLocked=function() {
  var lockCheck = db.currentOp();
  if ( lockCheck.hasOwnProperty('fsyncLock') && lockCheck.fsyncLock) return true;
  else return false;

};


var lockCheck = db.currentOp();
if (!lockCheck.hasOwnProperty('fsyncLock') || !lockCheck.fsyncLock) {
  throw 'Aborting unlock. Database is not locked !';
}

/* Check that if this is a replica set that we are a secondary */
var isMaster=db.isMaster();
if ( isMaster.hasOwnProperty('setName')     /* and we are talking to a replica set */
  && isMaster.primary ) {                   /* and we are connected to a primary */
  throw 'This is a replica set, so we must be talking to a secondary!';
}


var unlockResult = db.fsyncUnlock();
if ( unlockResult.ok != 1 ) {
  if ( unlockResult.errmsg == 'not locked' ) {
    print('Server was already unlocked!');
  }
  else {
    print('Didn’t successfully fsynUnlock  the server.  \nReturned status is ' + tojson(unlockResult));
    throw 'Error unlock';
    /* Next section can be uncommented to keep trying to unlock if you want to guarantee the server is unlocked
     when the script is finished.  However, this is not safe, since other processes may not be paying
     attention to already locked state and queueing their lock requests anyway */
    /*  print("\tWill try again every 5 seconds!");
     while (unlockResult.ok!=1) {
     if (unlockResult.errmsg=='not locked') {
     print("\t\tServer no longer locked");
     break;
     }
     sleep(5000);
     unlockResult=db.fsyncUnlock();
     }
     */
  }
}

if (!isLocked() ) {
  print('Server is unlocked.  We are finished.\n');
} else {
  throw 'Server is locked';
}
