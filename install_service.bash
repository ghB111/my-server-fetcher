#!/bin/bash

npm install

if [ ! -f "./res/token.secret" ]
then
  echo "Provide a bot token in './res/token.secret'"
  exit 1
fi

user="$USER"

# https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel
app_target_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Installing for $app_target_dir"

app_name=${app_target_dir##*/}
echo "App name is $app_name"

source ~/.nvm/nvm.sh

current_node=$(nvm which node)
echo "Using node installation $current_node"

current_node_bin=${current_node%/*}

# Make a service file

service_file="/etc/systemd/system/$app_name.service"

echo "The service file is $service_file"

if [ -f "$service_file" ]
  then
  echo "Deleted old service file"
  reinstall="yes"
  sudo rm $service_file
fi

sudo tee -a $service_file > /dev/null << EOM
[Unit]
Description=The node app I use to interact with my server through Telegram
After=network.target

[Service]
ExecStart=$current_node_bin/npm start
Restart=always
User=$user
Environment=PATH=/usr/bin:/usr/local/bin:$current_node_bin
Environment=NODE_ENV=production
WorkingDirectory=$app_target_dir

PIDFile=/var/run/$app_name.pid

[Install]
WantedBy=multi-user.target
EOM

sudo systemctl daemon-reload

if [ ! -z "$reinstall" ]
then
  echo "Reenabling and restarting the service"

  sudo systemctl reenable $app_name

  sudo systemctl restart $app_name
else
  echo "Enabling and starting the service"

  sudo systemctl enable $app_name

  sudo systemctl start $app_name
fi
