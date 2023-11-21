#!/bin/bash -x

send_discord_message() {
    local content="$1"

    curl -H "Content-Type: application/json" \
         -d "{\"username\": \"Terraform\", \"content\": \"$${content}\"}" \
         "${webhook_url}"
}

capture_error() {
    local status="$?"
    if [[ "$${status}" -ne 0 ]]; then
        send_discord_message "Error: $BASH_COMMAND failed with exit code $?"
    fi
}

function create_user() {
    local username="$1"
    local password="$2"

    sudo useradd -p "$(openssl passwd -1 "$${password}")" -s /bin/bash -d /home/"$${username}"/ -m -G sudo,docker "$${username}"
    echo "$${username} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
}

trap capture_error EXIT

send_discord_message "Starting server setup"
sudo apt-get update

send_discord_message "Installing packages"
sudo apt-get install -y ca-certificates curl jq gnupg lsb-release git

send_discord_message "Installing Docker"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin


# cloudflared configuration
# The package for this OS is retrieved 
send_discord_message "Installing Cloudflared"
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared focal main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt-get update && sudo apt-get install -y cloudflared

# A local user directory is first created before we can install the tunnel as a system service 
send_discord_message "Configuring Cloudflared"
mkdir ~/.cloudflared
touch ~/.cloudflared/cert.json
touch ~/.cloudflared/config.yml
# Another herefile is used to dynamically populate the JSON credentials file 
cat > ~/.cloudflared/cert.json << "EOF"
{
    "AccountTag"   : "${account}",
    "TunnelID"     : "${tunnel_id}",
    "TunnelName"   : "${tunnel_name}",
    "TunnelSecret" : "${secret}"
}
EOF
# Same concept with the Ingress Rules the tunnel will use 
cat > ~/.cloudflared/config.yml << "EOF"
tunnel: ${tunnel_id}
credentials-file: /etc/cloudflared/cert.json
logfile: /var/log/cloudflared.log
loglevel: info

ingress:
  - hostname: ssh.${hostname}
    service: ssh://localhost:22
  - hostname: webhook.${hostname}
    service: http://localhost:9999
  - hostname: "*"
    path: "^/_healthcheck$"
    service: http_status:200
  - service: http_status:404
EOF
# Now we install the tunnel as a systemd service
send_discord_message "Installing Cloudflared as a service" 
sudo cloudflared service install
# The credentials file does not get copied over so we'll do that manually 
sudo cp -via ~/.cloudflared/cert.json /etc/cloudflared/
sudo systemctl start cloudflared

# Change SSH configuration to support browser based
send_discord_message "Configuring SSH"
sudo cat > /etc/ssh/ca.pub << "EOF"
${ssh_ca_cert}
EOF
sudo sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config
sudo sed -i '$ a TrustedUserCAKeys /etc/ssh/ca.pub' /etc/ssh/sshd_config
sudo systemctl restart ssh

send_discord_message "Creating users"
USERNAMES="ponjimon"
IFS=',' read -ra NAMES <<< "$${USERNAMES}"
for name in "$${NAMES[@]}"; do
    USERNAME="$${name}"
    PASSWORD=$(openssl rand -base64 32)
    send_discord_message "Creating user $${USERNAME}"
    create_user "$${USERNAME}" "$${PASSWORD}"
done

send_discord_message "Installing webhookd service"
sudo curl -s https://raw.githubusercontent.com/ncarlier/webhookd/master/install.sh | bash
sudo mkdir -p /root/webhookd/scripts
sudo mv /.local/bin/webhookd /usr/local/bin/webhookd
cat > /etc/systemd/system/webhookd.service << "EOF"
[Unit]
Description=Webhook Bridge

[Service]
ExecStart=/usr/local/bin/webhookd -scripts /root/webhookd/scripts -listen-addr :9999
WorkingDirectory=/root/webhookd/
Type=simple
Restart=always
RestartSec=1
User=root

[Install]
WantedBy=default.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable webhookd
sudo systemctl start webhookd


cat > /root/webhookd/scripts/notify.sh << "EOF"
#!/bin/bash
# Path: /root/webhookd/scripts/notify.sh
# This script is called by webhookd when a webhook is received
# It will send a message to Discord
method="$${hook_method}"
body="$1"
content=$(echo "$${body}" | jq -r '.content')

if [[ "$${method}" == "POST" ]]; then
    curl -H "Content-Type: application/json" \
         -d "{\"username\": \"Webhookd\", \"content\": \"$${content}\"}" \
         "${webhook_url}"
else
    echo "Unsupported method: $${method}"
fi
EOF
sudo chmod u+x /root/webhookd/scripts/notify.sh

send_discord_message "Server setup complete"