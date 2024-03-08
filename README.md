# VMUpdater
## Installation

Written in [Tcl Expect](https://www.tcl.tk/man/expect5.31/expect.1.html) to automate updates/installation of proprietary packages, importing of SSL certificates, and VM configuration.

##Syntax
```bash
expect auto.sh [-d Dev ID] || [-p Prod ID] [-f *FMS_PIN] [-c has credentials] [server] [remote_dir] [local_dir] [username] [password] [fms_v] [arc] [src] [sshUSR]
```
`Dev/Prod ID`: Whether this FMS is a developer or production server. ID used for SSL filenames.

Ex. ``` expect auto.sh -d devAdmin```    --This would look for the SSL files in ```/__devAdmin_cloud``` and would look for the DevLicenseCert.fmcert instead of ProdLicenseCert.fmcert.

`FMS_PIN`: FMS will only require a pin if it's a first install with no credentials. If both ```-f``` and ```-c``` are present, leave the FMS_PIN blank.

`server`: Domain name of server

`remote_dir`: The serverside directory for install. Ex. Documents (no slashes)

`local_dir`: The clientside directory for installation files. Ex. files (no slashes)

`username`: username for FMS. Ex. admin

`password`: password for FMS. Ex. P@$$w0rd!

`fms_v`: FMS version to be installed. Ex. 20.3.2.205

`arc`: Architecture of server machine. Ex. arm64, amd64

`src`: Full directory leading to local_dir. Ex. ~/Desktop/VMUpdater/ (with slashes)

`sshUSR`: Only if ssh user is different than ```username```. Ex. user
