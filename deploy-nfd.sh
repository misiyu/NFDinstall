#!/bin/bash

####################################################
######## 本脚本用于安装运行NFD需要的环境
###################################################$

sudo apt install git

FORCE_UPDATE=$1

NDN_CXX_VERSION=0.6.5
NDN_NFD_VERSION=0.6.5
WEB_SOCKET_PP_VERSION=0.8.1
CHRONO_SYNC_VERSION=0.5.2
PSYNC_VERSION=0.1.0
NLSR_VERSION=0.5.0
NDN_TOOLS_VERSION=0.6.3
DEFAULT_DIR=~/Documents

function ensureDir() {
    dir=$1
    if [[ ! -d "$dir" ]]; then
        echo "文件夹${dir}不存在，正在创建"

        mkdir -p ${dir}
    fi
}

# 确保Documents文件夹存在
ensureDir ${DEFAULT_DIR}


function cloneOrUpdate() {
    cd ${DEFAULT_DIR}
    name=$1
    url=$2
    version=$3
    if [[ ! -d ${name} ]];then          # 项目不存在则为其创建文件夹
        mkdir ${name}
    else
        if [[ ${FORCE_UPDATE} -eq 1 ]]; then        # 强制更新则不管是否版本号相同都更新
            rm -r ${name} ${name}.tar.gz
            mkdir ${name}
        else
            # 得到当前的版本号
            curVersion=$(cat ${name}/VERSION)

            # 版本号不一致则删除原来的，更新新的
            if [[ ${curVersion} != ${version} ]]; then
                echo "${name}版本更新： ${curVersion} -> ${version}"
                rm -r ${name} ${name}.tar.gz
                mkdir ${name}
            else
                echo "${name}已是最新版本，无需更新"
                return
            fi
        fi
    fi
    curl -L ${url} > ${name}.tar.gz
    tar xf ${name}.tar.gz -C ${name} --strip 1
    cd ${name}


}

function afterInstall() {
    cd ${DEFAULT_DIR}
    name=$1
    url=$2
    version=$3
    if [[ ! -f ${name}/VERSION ]]; then
        echo "项目没有版本号，输出一个版本号："
        # 有些项目没有版本号，手动输出一个版本号
        echo ${version} > ${name}/VERSION
    fi
}

# install nfd use apt
#sudo apt-get install software-properties-common -y
#sudo add-apt-repository ppa:named-data/ppa
#sudo apt update
#sudo apt-get install nfd -y

# install ndn-cxx prerequesites
sudo apt-get install build-essential libsqlite3-dev libboost-all-dev libssl-dev curl tar -y
sudo apt-get install doxygen graphviz python-sphinx python-pip -y
sudo pip install sphinxcontrib-doxylink sphinxcontrib-googleanalytics

# install ndn-cxx
cloneOrUpdate ndn-cxx https://github.com/named-data/ndn-cxx/archive/ndn-cxx-${NDN_CXX_VERSION}.tar.gz ${NDN_CXX_VERSION}
./waf configure --enable-static
./waf
sudo ./waf install
afterInstall ndn-cxx https://github.com/named-data/ndn-cxx/archive/ndn-cxx-${NDN_CXX_VERSION}.tar.gz ${NDN_CXX_VERSION}

# install nfd
sudo apt-get install build-essential pkg-config libboost-all-dev \
                     libsqlite3-dev libssl-dev libpcap-dev -y
sudo apt-get install doxygen graphviz python-sphinx -y
cloneOrUpdate NFD https://github.com/named-data/NFD/archive/NFD-${NDN_NFD_VERSION}.tar.gz ${NDN_NFD_VERSION}
mkdir websocketpp
curl -L https://github.com/zaphoyd/websocketpp/archive/${WEB_SOCKET_PP_VERSION}.tar.gz > websocket.tar.gz
tar xf websocket.tar.gz -C websocketpp/ --strip 1
./waf configure
./waf
sudo ./waf install
afterInstall NFD https://github.com/named-data/NFD/archive/NFD-${NDN_NFD_VERSION}.tar.gz ${NDN_NFD_VERSION}

#check nfd.conf exists?
#if [[ ! -f /usr/local/etc/ndn/nfd.conf ]];then
#    cd /usr/local/etc/ndn
sudo cp nfd.conf.sample nfd.conf
#fi

# install ChronoSync
cloneOrUpdate ChronoSync https://github.com/named-data/ChronoSync/archive/${CHRONO_SYNC_VERSION}.tar.gz ${CHRONO_SYNC_VERSION}
./waf configure
./waf
sudo ./waf install
afterInstall ChronoSync https://github.com/named-data/ChronoSync/archive/${CHRONO_SYNC_VERSION}.tar.gz ${CHRONO_SYNC_VERSION}


# install PSync
cloneOrUpdate PSync https://github.com/named-data/PSync/archive/${PSYNC_VERSION}.tar.gz ${PSYNC_VERSION}
./waf configure
./waf
sudo ./waf install
afterInstall PSync https://github.com/named-data/PSync/archive/${PSYNC_VERSION}.tar.gz ${PSYNC_VERSION}


# install NLSR
cloneOrUpdate NLSR https://github.com/named-data/NLSR/archive/NLSR-${NLSR_VERSION}.tar.gz ${NLSR_VERSION}
./waf configure
./waf
sudo ./waf install
afterInstall NLSR https://github.com/named-data/NLSR/archive/NLSR-${NLSR_VERSION}.tar.gz ${NLSR_VERSION}

#check nlsr.conf exists?
if [[ ! -f /usr/local/etc/ndn/nlsr.conf ]];then
    cd /usr/local/etc/ndn
    sudo cp nlsr.conf.sample nlsr.conf
fi

#check /var/lib/nlsr exists?
if [[ ! -d /var/lib/nlsr ]];then
    sudo mkdir /var/lib/nlsr
fi

# install ndn-tools
sudo apt-get install libpcap-dev -y
cloneOrUpdate ndn-tools https://github.com/named-data/ndn-tools/archive/ndn-tools-${NDN_TOOLS_VERSION}.tar.gz ${NDN_TOOLS_VERSION}
./waf configure
./waf
sudo ./waf install
afterInstall ndn-tools https://github.com/named-data/ndn-tools/archive/ndn-tools-${NDN_TOOLS_VERSION}.tar.gz ${NDN_TOOLS_VERSION}

## install ndn-cpp
#sudo apt install build-essential libssl-dev libsqlite3-dev libprotobuf-dev protobuf-compiler \
#    liblog4cxx-dev doxygen libboost-all-dev -y
#cloneOrUpdate ndn-cpp https://github.com/named-data/ndn-cpp/archive/v0.15.tar.gz
#./configure
#make
#sudo make install

# install jsoncpp
sudo apt install libjsoncpp-dev jq cmake -y
# enforce loading lib
sudo ldconfig

echo "move /usr/local/etc/ndn/nfd.conf "
sudo cp /usr/local/etc/ndn/nfd.conf.sample /usr/local/etc/ndn/nfd.conf
