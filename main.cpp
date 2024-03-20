#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>

struct ServerInfo {
    std::string server;
    std::string username;
    std::string password;
    std::string sshUSR;
    bool AWS;
};
std::string keyGen(std::string ppk, std::string name){
    std::string puttygenPath = "FULL-PATH-TO/puttygen";
    std::string cmd = puttygenPath + " " + ppk + name + ".ppk -O private-openssh -o " + ppk + name + ".pem";
    system(cmd.c_str());
    cmd = "chmod 400 " + ppk + name + ".pem";
    system(cmd.c_str());
    return ppk + name + ".pem";
}
std::vector<ServerInfo> parseFile(const std::string& filename) {
    std::vector<ServerInfo> serverInfoList;
    std::ifstream file(filename);
    std::string line;
    if (!file.is_open()) {
            std::cerr << "Error opening file: " << filename << std::endl;
            return serverInfoList;
        }
    while (std::getline(file, line)) {
        std::istringstream iss(line);
        std::string server, sshUSR, password, AWS;
        if(line[0] == '#'){ //Allow for comments in server list
            continue;
        }
        if (iss >> server >> password >> sshUSR >> name >> AWS ){                       //5 args, AWS pem
            std::string ppkDir = "FULL-PATH-TO-PPK/";
            serverInfoList.push_back({server, sshUSR, password, "-k " + keyGen(ppkDir, name)});
        } else{                                                                              //4 args trad password
            serverInfoList.push_back({server, sshUSR, password, "nokey"});
        }
    }
    return serverInfoList;
}

void ottoUpdate(std::vector<ServerInfo> serverInfoList){
    for(const auto& info : serverInfoList){
        std::string cmd = "expect ~/VMUpdater/otto.sh " +
        info.server + " " +
        info.sshUSR + " " +
        info.password + " " +
        info.key;
        system(cmd.c_str());
    }
}
int main() {
    std::string serverList = "FULL-PATH-TO/serverList.txt";
    std::vector<ServerInfo> serverInfoList = parseFile(serverList);
//    ottoUpdate(serverInfoList);
    return 0;
}
