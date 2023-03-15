#!/bin/bash


# install package
echo "install package $PACKAGE_NAME"
pacman -Syu --needed --noconfirm $PACKAGE_NAME

echo "start xvfb with command $PACKAGE_COMMAND"
# nohup Xvfb :1 -screen 0 1024x768x24 > /dev/null 2>&1 &
nohup xvfb-run --server-num 1 --server-args="-screen 0 1600x900x24" "$PACKAGE_COMMAND" &

sleep 5

echo "start x0vncserver"
# nohup x0vncserver -rfbport 5900 -display :1 -UseIPv4 -SecurityTypes None > /dev/null 2>&1 &
nohup x0vncserver -rfbport 5900 -display :1 -UseIPv4 -SecurityTypes None &

sleep 5

echo "start novnc"
novnc --listen 6080 --vnc localhost:5900 &

wait -n 
exit $?