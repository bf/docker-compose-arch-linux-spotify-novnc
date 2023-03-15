# Run Spotify in Arch Linux docker container

Docker-compose is used to spin up a docker instance which contains a virtual X server (xvfb) that is connected to a VNC server (tigervnc). The VNC server is shown through a web-based GUI (novnc).

Thereby we can download and run GUI applications such as `evince` or `spotify` within Docker and get a nice web interface to use them.