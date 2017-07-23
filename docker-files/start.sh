mongod &
su memcacheuser
memcached &
su root
redis-server &
cd /airstep1
node ./servers/production/server.js --portIncrement 0 --environmentId 4d0000000000000000000001 --NODE_ENV production  --poolId 2a346d5df16f840db532271a  --serverId 9124517ddc688c678d767212
