const cron = require('node-cron');
const config = require('../config/config')

const synchronizeBlockchain = async ()=>{
  cron.schedule(`*/${config.synchronize.block_time} * * * * *`, () => {
      handleLogin().then(()=>{}).catch(err=>{
        console.log(err.message)
      });
  });
}

const handleLogin = async()=>{
  console.log('[Synchronize] listen')
  // https://www.npmjs.com/package/web3 
}

module.exports = {synchronizeBlockchain};

