#!/bin/sh
set SERVER [lindex $argv 0]
set USERNAME [lindex $argv 1]
set PASSWORD [lindex $argv 2]
set sshUSR [lindex $argv 3]

proc updateOtto {SERVER USERNAME PASSWORD sshUSR} {
    set timeout 120
    spawn ssh "$sshUSR@$SERVER"
    global ssh_spawnID
    set ssh_spawnID $spawn_id
    expect "*password:"
    send "$PASSWORD\r"
    expect "$ "
    send "sudo which\r"
    expect "*$sshUSR:"
    send "$PASSWORD\r"
    expect "$ "
    send "yes | sudo curl -sSL \"https://appupdates.proofgeist.com/ottofms/install-scripts/install-linux.sh\" | bash\r" ; #Otto-FMS install/update
    expect "$ "
    send "exit"
}
updateOtto $SERVER $USERNAME $PASSWORD $sshUSR
