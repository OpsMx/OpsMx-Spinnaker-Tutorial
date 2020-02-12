#!/bin/bash
USER1=ubuntu

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
