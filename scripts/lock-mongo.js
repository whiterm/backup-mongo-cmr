/*global db, print*/

var lockCheck = db.currentOp();
if (lockCheck.hasOwnProperty('fsyncLock') && lockCheck.fsyncLock) {
  throw 'Aborting backup since someone else already has server locked!';
}

/* Check that if this is a replica set that we are a secondary */
var isMaster=db.isMaster();
if ( isMaster.hasOwnProperty('setName')     /* and we are talking to a replica set */
  && isMaster.primary ) {                   /* and we are connected to a primary */
  throw 'This is a replica set, so we must be talking to a secondary!';
}

/* Lock the server, check success */
var lockResult = db.fsyncLock();
if ( lockResult.ok != 1 ) {
  print('Didn’t successfully fsynLock  the server.  Returned status is ' + lockResult.code + ' ' + lockResult.errmsg);
  throw 'Exiting after error locking';
} else {
  print('Completed fsyncLock command: now locked against writes.\n');
}
