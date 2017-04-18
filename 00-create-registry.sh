#!/bin/bash
docker run -d --name registry -p 5000:5000 --restart=always -v /var/registry:/var/lib/registry registry:2

IFS='
'
IMGFILE=$1

for a in $(cat $IMGFILE); do
	echo "Line: $a"
	SOURCE=$(echo $a |cut -f 1 -d '|')
	DESTINY=$(echo $a |cut -f 2 -d '|')
	echo "Pulling images $SOURCE"
	docker pull $SOURCE
	IMGTAG=$(docker images -q $SOURCE)
	docker tag $IMGTAG 127.0.0.1:5000/$DESTINY
	echo "Pushing to 127.0.0.1:5000/$DESTINY"
	docker push 127.0.0.1:5000/$DESTINY
done


