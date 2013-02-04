#DEPLOYMENT GUIDE

## Switch to branch deployment

  git checkout deployment

## Deploy code to servers

  cap staging deploy # for staging servers
  cap production deploy # for production servers

  cap staging ts_remote:conf #reconfig sphinx search, when index changed
