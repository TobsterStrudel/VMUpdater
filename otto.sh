#!/bin/sh
set AWS 0
foreach arg $argv {
    switch -glob -- $arg {
        "-a" {
            set AWS 1
            set kfDIR [lindex $argv [expr {[lsearch $argv $arg] + 1}]]
        }
        "-p" {
            set PASSWORD [lindex $argv [expr {[lsearch $argv $arg] + 1}]]
        }
    }
}
set SERVER [lindex $argv 0]
set USERNAME [lindex $argv 1]
set sshUSR [lindex $argv 2]

proc updateOtto {SERVER USERNAME PASSWORD sshUSR} {
    set timeout 120
    if {AWS} {
        spawn ssh -i $kfDIR "$sshUSR@$SERVER"
    } else {
        spawn ssh "$sshUSR@$SERVER"
        expect "*password:"
        send "$PASSWORD\r"
    }
    global ssh_spawnID
    set ssh_spawnID $spawn_id
    
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
