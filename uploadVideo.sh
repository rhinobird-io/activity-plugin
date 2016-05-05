#!/bin/bash

set -e

VIDEO_HOST=${VIDEO_HOST:-localhost}
HOST_USER=${HOST_USER:-username}

if [ "$#" -ne 3 ]; then
   echo "Parameter length should be 3: origin video name, convert to name, activity id" 
   exit 1
fi

echo "Convert $1 to $2...."
/usr/bin/avconv -i $1 $2


ACTIVITY_VIDEO="activity_"$3".mp4"
echo "Upload video with filename $ACTIVITY_VIDEO..."

VIDEO_DIR=${VIDEO_DIR:-/home/ate/rhinobird/video/files/$ACTIVITY_VIDEO}
/usr/bin/scp $2 ${HOST_USER}@${VIDEO_HOST}:${VIDEO_DIR}