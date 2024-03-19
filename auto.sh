#!/usr/bin/expect -f
set DEV 0
set FTI 0
set DISPLACE 0
set hasCRED 0
set PIN ""
foreach arg $argv {
    switch -glob -- $arg {
        "-d" {
            set DEV 1
            set CRT [lindex $argv [expr {[lsearch $argv $arg] + 1}]]
            incr DISPLACE 2
        }
        "-p" {
            set CRT [lindex $argv [expr {[lsearch $argv $arg] + 1}]]
            incr DISPLACE 2
        }
        "-f" {
            set FTI 1
            set PIN [lindex $argv [expr {[lsearch $argv $arg] + 1}]]
            incr DISPLACE 2
        }
        "-c" {
            set hasCRED 1
            incr DISPLACE
        }
    }
}

set SERVER [lindex $argv 0+$DISPLACE]
set REMOTE_DIR [lindex $argv 1+$DISPLACE]
set LOCAL_DIR [lindex $argv 2+$DISPLACE]
set USERNAME [lindex $argv 3+$DISPLACE]
set PASSWORD [lindex $argv 4+$DISPLACE]
set FMS_V [lindex $argv 5+$DISPLACE]
set ARC [lindex $argv 6+$DISPLACE]
set SRC [lindex $argv 7+$DISPLACE]
set sshUSR [lindex $argv 8+$DISPLACE]

puts "CRT: $CRT"
puts "SERVER: $SERVER"
puts "REMOTE_DIR: $REMOTE_DIR"
puts "LOCAL_DIR: $LOCAL_DIR"
puts "USERNAME: $USERNAME"
puts "PASSWORD: $PASSWORD"
puts "FMS_V: $FMS_V"
puts "ARC: $ARC"
puts "SRC: $SRC"
puts "DEV: $DEV"
puts "FTI: $FTI"
puts "sshUSR: $sshUSR"


proc sftp_transfer {sshUSR SERVER PASSWORD SRC LOCAL_DIR REMOTE_DIR} {
    set timeout 120
    spawn sftp -i /Users/tobias/Desktop/AutoUpdatercopy/AutoUpdater/tobias.pem "$sshUSR@$SERVER"
#    expect "*password:"
#    send "$PASSWORD\r"
    expect "sftp>"
    send "put -r $SRC$LOCAL_DIR $REMOTE_DIR\r"
    expect "sftp>"
    send "quit\r"
    expect eof
}

proc first_install {hasCRED DEV PASSWORD REMOTE_DIR LOCAL_DIR USERNAME PIN FMS_V ARC} {
    set timeout 120
    global ssh_spawnID
    set spawn_id $ssh_spawnID
    if {$hasCRED} {
        expect "$ "
        if {$DEV} {
            send "sudo cp ~/$REMOTE_DIR/$LOCAL_DIR/DevLicenseCert.fmcert \"/opt/FileMaker/FileMaker Server/CStore/LicenseFile/LicenseCert.fmcert\"\r"
        } else {
            send "sudo cp ~/$REMOTE_DIR/$LOCAL_DIR/ProdLicenseCert.fmcert \"/opt/FileMaker/FileMaker Server/CStore/LicenseFile/LicenseCert.fmcert\"\r"
        }
        expect "$ "
        send "sudo apt install ./filemaker-server-$FMS_V-$ARC.deb\r"
        expect "*/n"
        send "y\r"
        expect "0/1"
        send "0\r"
        expect "y/n"
        send "y\r"
    } else {
        send "sudo apt install ./filemaker-server-$FMS_V-$ARC.deb\r"
        expect "y/n"
        send "y\r"
#        expect "y/n"
#        send "y\r"
        expect "0/1"
        send "0\r"
        expect "*User Name:"
        send "$USERNAME\r"
        expect "*Password:"
        send "$PASSWORD\r"
        expect "*Password:"
        send "$PASSWORD\r"
        expect "*PIN:"
        send "$PIN\r"
        expect "*PIN:"
        send "$PIN\r"
    }
    return
}

proc update {PASSWORD REMOTE_DIR LOCAL_DIR FMS_V ARC DEV} {
    set timeout 120
    global ssh_spawnID
    set spawn_id $ssh_spawnID
    expect "$ "
    if {$DEV} {
        send "sudo cp ~/$REMOTE_DIR/$LOCAL_DIR/DevLicenseCert.fmcert \"/opt/FileMaker/FileMaker Server/CStore/LicenseFile/LicenseCert.fmcert\"\r"
    } else {
        send "sudo cp ~/$REMOTE_DIR/$LOCAL_DIR/ProdLicenseCert.fmcert \"/opt/FileMaker/FileMaker Server/CStore/LicenseFile/LicenseCert.fmcert\"\r"
    }
    expect "$ "
    send "sudo apt install ./filemaker-server-$FMS_V-$ARC.deb\r"
    expect "y/n"
    send "y\r"
    return
}

proc SSL_cert {CRT USERNAME PASSWORD} {
    set timeout 120
    global ssh_spawnID
    set spawn_id $ssh_spawnID
    send "cd '$CRT'_cloud\r"
#    expect "$ "
#    send "sudo cp serverKey.pem \"/opt/FileMaker/FileMaker\ Server/CStore/serverKey.pem\"\r"
#    expect "$ "
#    send "cat __'$CRT'_cloud.crt <(echo) serverKey-without-passphrase.key > \"/opt/FileMaker/FileMaker\ Server/CStore/serverCustom.pem\"\r"
    expect "$ "
    send "fmsadmin certificate import __'$CRT'_cloud.crt --keyfile serverKey.pem --keyfilepass \$(cat keyPassword.txt) --intermediateCA __'$CRT'_cloud.ca-bundle\r"
    expect "(Warning: server needs to be restarted) "
    send "y\r"
    expect "username (*):"
    send "$USERNAME\r"
    expect "password:"
    send "$PASSWORD\r"
    expect "$ "
    send "fmsadmin restart server\r"
    expect "really restart server? (y, n) "
    send "y\r"
    expect "username (*):"
    send "$USERNAME\r"
    expect "password:"
    send "$PASSWORD\r"
    return
}

proc change_password {USERNAME newPASSWORD PIN} {
    set timeout 120
    global ssh_spawnID
    set spawn_id $ssh_spawnID
    expect "$ "
    send "fmsadmin resetpw -p $newPASSWORD -z $PIN\r"
    expect "username (*):"
    send "$USERNAME\r"
    expect "password:"
    send "$PASSWORD\r"
    expect "$ "
    return
}

proc encrypt_file {FILE TARGET_FILE sharedID PASSWORD} {
    set timeout 120
    global ssh_spawnID
    set spawn_id $ssh_spawnID
    expect "$ "
    send "cd /FM location\r" ; # TODO
    expect "$ "
    send "./FMDeveloperTool --enableEncryption $FILE -target_file $TARGET_FILE  -sharedID $sharedID -passCode $PASSWORD\r"
}
proc ssh_connection {sshUSR USERNAME SERVER PASSWORD REMOTE_DIR LOCAL_DIR hasCRED DEV FMS_V ARC FTI PIN CRT} {
    set timeout 120
    spawn ssh -i /Users/tobias/Desktop/AutoUpdatercopy/AutoUpdater/tobias.pem "$sshUSR@$SERVER"
    global ssh_spawnID
    set ssh_spawnID $spawn_id
#    expect "*password:"
#    send "$PASSWORD\r"
#    expect "$ "
#    send "sudo which\r"
#    expect "*icadmin:"
#    send "$PASSWORD\r"
    expect "$ "
    send "cd $REMOTE_DIR/$LOCAL_DIR\r"
#    expect "$ "
#    if {$FTI} {
#        send "\r"
#        first_install $hasCRED $DEV $PASSWORD $REMOTE_DIR $LOCAL_DIR $USERNAME $PIN $FMS_V $ARC
#    } else {
#        send "\r"
#        update $PASSWORD $REMOTE_DIR $LOCAL_DIR $FMS_V $ARC $DEV
#    }
    expect "$ "
    send "yes | sudo curl -sSL \"https://appupdates.proofgeist.com/ottofms/install-scripts/install-linux.sh\" | bash\r" ;#Otto-FMS install/update
    expect "$ "
    SSL_cert $CRT $USERNAME $PASSWORD
    expect "$ "
    send "sudo reboot\r"
    expect eof
}

#sftp_transfer $sshUSR $SERVER $PASSWORD $SRC $LOCAL_DIR $REMOTE_DIR
ssh_connection $sshUSR $USERNAME $SERVER $PASSWORD $REMOTE_DIR $LOCAL_DIR $hasCRED $DEV $FMS_V $ARC $FTI $PIN $CRT

puts "End of script"
