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
    std::string puttygenPath = "/opt/homebrew/bin/puttygen";
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
        std::string server, username, password, sshUSR, AWS;
        if (iss >> server >> username >> password >> sshUSR >> AWS ){                       //5 args, AWS pem
            std::string ppkDir = "/Users/tobias/Desktop/AutoUpdatercopy/AutoUpdater/";
            std::string name = "olive_key";
            serverInfoList.push_back({server, username, "-a " + keyGen(ppkDir, name), sshUSR, true});
        } else{                                                                              //4 args trad password
            serverInfoList.push_back({server, username, "-p " + password, sshUSR, false});
        }
    }
    return serverInfoList;
}

void ottoUpdate(std::vector<ServerInfo> serverInfoList){
    
    for(const auto& info : serverInfoList){
        std::string cmd = "expect ~/VMUpdater/otto.sh " +
        info.server + " " +
        info.username + " " +
        info.password + " " +
        info.sshUSR;
        system(cmd.c_str());
    }
}
int main() {
    std::string serverList = "FULL-PATH-TO/serverList.txt";
    std::vector<ServerInfo> serverInfoList = parseFile(serverList);
//    ottoUpdate(serverInfoList);
    return 0;
}
