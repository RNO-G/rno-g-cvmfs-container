#!/bin/bash

TARGET=rnog.opensciencegrid.org

# Mount the CVMFS repository directly using FUSE
if mount -t cvmfs $TARGET /cvmfs/$TARGET ; then
  echo "mount returned successfully"
else
  echo "mount failed. perhaps a permisisons issue? May need to pass --device /dev/fuse"
fi

# Check the mount was successful
if mountpoint -q /cvmfs/$TARGET; then
    echo "Successfully mounted /cvmfs/$TARGET"
else
    echo "Failed to mount CVMFS."
    exit 1
fi


# load setup, turning on auto export
set -a
. /cvmfs/$TARGET/software/trunk/setup.sh
set +a

# This is trying to match uid/gid in a way compatible with both docker or podman
# hopefully it doens't blow up! my user account is 1000 so...
if [ -n "$HOST_UID" ] && [ "$HOST_UID" != "$(id -u rno-g)" ]; then
    echo "Updating rno-g UID to $HOST_UID to match host..."
    usermod -u "$HOST_UID" rno-g

    # Also fix ownership of the internal home directory so they aren't locked out
    chown -R rno-g /home/rno-g
fi

if [ -n "$HOST_GID" ] && [ "$HOST_GID" != "$(id -g rno-g)" ]; then
    groupmod -g "$HOST_GID" rno-g
    chgrp -R rno-g /home/rno-g
fi

cd /rno-g

# continue with shell or whatever the user asked for
if [ $# -eq 0 ]; then
    exec  runuser -u rno-g -- /bin/bash
else
    exec  runuser -u rno-g -- "$@"
fi

