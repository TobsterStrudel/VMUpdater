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
            serverInfoList.push_back({server, username, "-a " + password, sshUSR, true});
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
