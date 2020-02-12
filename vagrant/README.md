Prerequisite :-

``` VirtualBox - https://www.virtualbox.org/wiki/Downloads ```

``` Vagrant - https://www.vagrantup.com/docs/installation/ ```

To Begin Spinnaker Installation, Please Run the Below Command :-

```
# vagrant up
```
After installing Spinnaker in Virtual-Box, To Access The Newly Created Machine, 
Create `vim $HOME/.ssh/config` With The Below Content.

```
# Configure as the output say in: vagrant ssh-config

Host opsmx-spinnaker-start
  HostName localhost
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  ########### REPLACE IT WITH CLONE PATH ###########
  IdentityFile /home/aswath2saru/MEGA/GIT-Projects/OpsMx-Spinnaker-Tutorial/vagrant/.vagrant/machines/default/virtualbox/private_key
  ##################################################
  IdentitiesOnly yes
  LogLevel FATAL
  ControlMaster yes
  ControlPath ~/.ssh/spinnaker-tunnel.ctl
  RequestTTY no
  LocalForward 9000 localhost:9000
  LocalForward 8084 localhost:8084
  LocalForward 8087 localhost:8087
```

After that Please Run: 
```# ssh opsmx-spinnaker-start```


And then open you browser in `127.0.0.1:9000
`
