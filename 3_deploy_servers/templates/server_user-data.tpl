#!/bin/bash
# Install neccesary packages
yum update -y
yum install -y docker
yum install -y git

# Set timezone
timedatectl set-timezone Europe/Madrid

# Clone git repo and copy to html folder
cd /tmp
git clone ${git_uri}
cp -r .${git_uri_app_path}docker /var

# Start Docker
service docker start
chkconfig docker on
usermod -a -G docker ec2-user

# Create docker-compose.yml
cd /var/docker
touch docker-compose.yml
cat > docker-compose.yml <<EOF
${docker_file}
EOF

# Create nginx.conf
cd /var/docker/proxy_init/config
touch default.conf
cat > default.conf <<EOF
${nginx_config}
EOF

# Create nginx.html
cd /var/docker/proxy_init/html
touch index.html
cat > index.html <<EOF
${nginx_html}
EOF

# Create redis.conf
mkdir /var/docker/redis_init
cd /var/docker/redis_init
curl -o redis.conf https://raw.githubusercontent.com/redis/redis/7.2/redis.conf
sed -i 's/^bind 127.0.0.1 -::1/bind 0.0.0.0/' redis.conf
sh -c "echo 'requirepass ${redis_pass}' >> redis.conf"

# Install Docker compose
cd /home/ec2-user
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Run containers
docker network create frontweb
docker-compose -f /var/docker/docker-compose.yml up -d