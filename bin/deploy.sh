#!/bin/bash -e
#
############################################################

printf "\n\nBuild and deploy D-CMS component\n";
printf "\n-----------------------------------------------------------------------------------------------------\n";
printf "\t1. Jenkins pulls code from git (prior to this script).\n";
printf "\t2. Jenkins creates dist folder - npm run build (prior to this script).\n";
printf "\t3. Jenkins pushes dist folder to brightblock-docker/brightblock/nginx.\n";
printf "\t4. Jenkins builds the nginx image.\n";
printf "\t5. Jenkins tags and pushes the image.\n";
printf "\t6. Jenkins ssh to the target server and pulls the image.\n\n";

DOCKER_COMPOSE_CMD='sudo /usr/local/bin/docker-compose'
DOCKER_ID_USER='mijoco'
DOCKER_CMD='sudo /usr/bin/docker'
DOCKER_HOME=/var/jenkins_home/brightblock/brightblock-docker/brightblock
ls -lt dist
cp -r dist/* $DOCKER_HOME/nginx/www/brightblock-dcms

pushd $DOCKER_HOME > /dev/null

$DOCKER_CMD ps -a
$DOCKER_COMPOSE_CMD build
$DOCKER_CMD tag brightblock_nginx  $DOCKER_ID_USER/brightblock_nginx
$DOCKER_CMD push $DOCKER_ID_USER/brightblock_nginx
$DOCKER_COMPOSE_CMD restart nginx

popd > /dev/null

printf "Finished brightblock-dcms nginx build and deployment.\n"
printf "\n-----------------------------------------------------------------------------------------------------\n";

exit 0;

# old deployment where code was loaded from volume rather than baked into images..
#SERVER=$1
#DEPLOY_SERVER=$SERVER:/home/bob/deployment/brightblock-dcms
#rsync -aP --quiet -e "ssh -p 7019" dist/ bob@$DEPLOY_SERVER
#ssh -i ~/.ssh/id_rsa -p 7019 bob@$SERVER "
#	rsync -aP --quiet  /home/bob/deployment/brightblock-dcms/  rsync://localhost:10873/volume/deployments/nginx/html/brightblock-dcms
#";
