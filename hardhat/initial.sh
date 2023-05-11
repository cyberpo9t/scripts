#!/bin/bash

uname=`uname -a`
linuxSystem=""

FILE_EXE=/etc/redhat-release

getLinuxSystem() {
    if [ -f "FILE_EXE" ]; then
        if [[ `cat /etc/redhat-release` =~ "CentOS" ]]; then
            echo "CentOS"
            linuxSystem = "CentOS"
            exit
        fi
    fi

    if [[ $uname =~ "CentOS" ]]; then
        echo "CentOS"
        linuxSystem = "CentOS"
    fi
    if [[ $uname =~ "Ubuntu" ]]; then
        echo "Ubuntu"
        linuxSystem = "Ubuntu"
    fi
}

installNode() {
    echo "Node installing..."
    if [ $linuxSystem == "Ubuntu" ]; then
        curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash - &&\
        sudo apt-get install -y nodejs
    elif [ $linuxSystem == "CentOS" ]; then
        curl -fsSL https://rpm.nodesource.com/setup_current.x | sudo bash -
    fi
}

install_yarn_with_node() {
    echo "Installing Yarn using Node.js..."
    # 安装Yarn
    npm install -g yarn
    # 检查安装结果
    yarn_installed=$(command -v yarn)
    if [[ -n "$yarn_installed" ]]; then
        echo "Yarn installation successful. Installed at: $yarn_installed"
        return 0
    else
        echo "Yarn installation failed."
        return 1
    fi
}

main() {
    if ! type node > /dev/null 2>&1; then
        installNode
    else echo "Node.js is already installed at: $(command -v node)"
    fi
    
    yarn_installed=$(command -v yarn)
    if [[ -n "$yarn_installed" ]]; then
        echo "Yarn is already installed at: $yarn_installed"
    else
        echo "Yarn is not installed."
        install_yarn_with_node
    fi

    yarn add --dev hardhat
    yarn hardhat

    yarn add --dev prettier prettier-plugin-solidity
    yarn add --dev openzeppelin/contracts
    yarn add --dev dotenv

    prettierrc_config="{
    "tabWidth": 4,
    "useTabs": false,
    "singleQuote": false
}"
    echo "${prettierrc_config}" > .prettierrc

    prettierignore_config="node_modules
package.json
img
artifacts
cache
coverage
.env
.*
README.md
coverage.json"
    echo "${prettierignore_config}" > .prettierignore

    touch .env
}
main "$@"