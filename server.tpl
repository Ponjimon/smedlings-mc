#!/bin/bash -x

sudo apt-get update
sudo apt-get install ca-certificates curl jq gnupg lsb-release git
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
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared focal main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt-get update && sudo apt-get install -y cloudflared

# A local user directory is first created before we can install the tunnel as a system service 
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
  - hostname: ssh-${domain}
    service: ssh://localhost:22
  - hostname: "*"
    path: "^/_healthcheck$"
    service: http_status:200
  - service: http_status:404
EOF
# Now we install the tunnel as a systemd service 
sudo cloudflared service install
# The credentials file does not get copied over so we'll do that manually 
sudo cp -via ~/.cloudflared/cert.json /etc/cloudflared/
sudo systemctl start cloudflared

# Change SSH configuration to support browser based
sudo cat > /etc/ssh/ca.pub << "EOF"
${ssh_ca_cert}
EOF
sudo sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config
sudo sed -i '$ a TrustedUserCAKeys /etc/ssh/ca.pub' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Unix usernames must match the identity preceding the email domain. 
USERNAME=$(echo "${email}" | sed 's/@.*//')
sudo useradd -p "$(openssl passwd -1 "${unix_password}")" -s /bin/bash -d /home/$${USERNAME}/ -m -G sudo,docker $${USERNAME}
echo "$${USERNAME} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers