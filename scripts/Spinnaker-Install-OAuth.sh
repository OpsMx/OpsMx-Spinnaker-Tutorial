#!/bin/bash

set -e


USER1=ubuntu
mkdir -p ~/.hal/default/profiles/
touch ~/.hal/default/profiles/front50-local.yml
echo "Please Enter the github CLIENT_ID :"
read CLIENT_ID 
echo "Please Enter the github client-secret :"
read CLIENT_SECRET
echo "Please Enter the provider details (google | github | azure) :"
read PROVIDER
echo "Please Enter the REDIRECT_URL"
read REDIRECT_URL
echo "Please Enter the spinnaker Version :"
read SPINNAKER_VERSION


if id $USER1 >/dev/null 2>&1; then
        echo "User $USER1 Already Exists, Skipping Now ...."
else
        echo "User $USER1 Does Not Exist, Creating Now ...."
        groupadd ubuntu
		useradd -g ubuntu -G admin -s /bin/bash -d /home/ubuntu ubuntu
		mkdir -p /home/ubuntu
		cp -r /root/.ssh /home/ubuntu/.ssh
		chown -R ubuntu:ubuntu /home/ubuntu
		echo "ubuntu	ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
		echo "User $USER1 Created Successfully ...."
fi

sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo swapon /swapfile


curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh --user ubuntu
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker ubuntu
sudo docker run -p 127.0.0.1:9090:9000 -d --name minio1 \
  -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
  -e "MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  -v /mnt/data:/data \
  minio/minio server /data

sudo apt-get -y install jq

MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE
echo $MINIO_SECRET_KEY | hal config storage s3 edit --endpoint http://127.0.0.1:9090 \
    --access-key-id $MINIO_ACCESS_KEY \
    --secret-access-key

hal config storage edit --type s3

if [ -z "${CLIENT_ID}" ] ; then
  echo "CLIENT_ID not set"
  exit
fi
if [ -z "${CLIENT_SECRET}" ] ; then
  echo "CLIENT_SECRET not set"
  exit
fi
if [ -z "${PROVIDER}" ] ; then
  echo "PROVIDER not set"
  exit
fi
if [ -z "${REDIRECT_URL}" ] ; then
  echo "REDIRECT_URL not set"
  exit
fi

MY_IP=`curl -s ifconfig.co`

hal config security authn oauth2 edit \
  --client-id $CLIENT_ID \
  --client-secret $CLIENT_SECRET \
  --provider $PROVIDER
hal config security authn oauth2 enable

hal config security authn oauth2 edit --pre-established-redirect-uri $REDIRECT_URL

hal config security ui edit \
    --override-base-url http://${MY_IP}:9000

hal config security api edit \
    --override-base-url http://${MY_IP}:8084


sudo apt update
sudo apt-get -y install redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server


echo 'spinnaker.s3:
  versioning: false
' > ~/.hal/default/profiles/front50-local.yml


if [ -z "${SPINNAKER_VERSION}" ] ; then
  echo "SPINNAKER_VERSION not set"
  exit
fi

sudo hal config version edit --version $SPINNAKER_VERSION

sudo hal deploy apply
sleep 10
echo ""
echo "Spinnaker Installed Successfully - Open Browser And Access The Spinnaker"
echo ""
