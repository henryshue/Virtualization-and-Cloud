#!/bin/bash

IMAGE=hadoop-cluster

echo "stop and remove the relevant containers.."
names=(`docker ps -a | grep $IMAGE | awk '{print $1}'`)
for name in ${names[*]}
do
  echo $name
  docker stop $name
  docker rm $name
done

# 删除旧版的镜像名为hadoop-cluster镜像（如果存在）
cluster=`docker images | grep $IMAGE`
if [ -z "$cluster" ]; then
  echo "the $IMAGE image is not existed!"
else
  echo "removing the $IMAGE..."
  docker rmi $IMAGE
fi
