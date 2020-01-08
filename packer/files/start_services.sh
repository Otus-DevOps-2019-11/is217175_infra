#!/bin/bash

cat << EOF > /etc/systemd/system/pumad.service
[Unit]
Description=Puma HTTP server running reddit test application
After=network.target mongodb.service
Wants=mongodb.service

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser/reddit/
ExecStart=/usr/local/bin/puma
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -INT $MAINPID
Restart=Always

[Install]
WantedBy=multi-user.target

EOF
systemctl daemon-reload
systemctl start mongod
systemctl start pumad
systemctl enable mongod
systemctl enable pumad
