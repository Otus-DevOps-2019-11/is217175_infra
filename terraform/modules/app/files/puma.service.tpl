[Unit]
Description=Puma HTTP server running reddit test application
After=network.target mongodb.service
Wants=mongodb.service

[Service]
Type=simple
User=appuser
Environment=DATABASE_URL=${ db_addr }
WorkingDirectory=/home/appuser/reddit/
ExecStart=/usr/local/bin/puma
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -INT $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
