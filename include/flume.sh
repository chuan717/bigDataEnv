#!/bin/bash
install_flume()
{
    local flume_version=$1
    local install_path=$2
    local jdk_path=$3
    # 判断源文件是否存在，不存在即下载http://www.apache.org/dyn/closer.lua/flume/1.8.0/apache-flume-1.8.0-bin.tar.gz
    if [ ! -f $CUR/src/flume-${flume_version}-bin.tar.gz ]; then
    	log_info "下载flume-${flume_version}"
        wget -O $CUR/src/apache-flume-${flume_version}-bin.tar.gz http://mirrors.tuna.tsinghua.edu.cn/apache/flume/${flume_version}/apache-flume-${flume_version}-bin.tar.gz 
        log_info "解压缩flume-${flume_version}"
        tar -zxvf $CUR/src/apache-flume-${flume_version}-bin.tar.gz -C $install_path
    else
        log_info "解压缩flume-${flume_version}"
        tar -zxvf $CUR/src/flume-${flume_version}-bin.tar.gz -C $install_path
    fi
    mv $install_path/apache-flume-${flume_version}-bin $install_path/flume-${flume_version}
    chown $USER:$USER -R $install_path/flume-${flume_version}
    # 添加环境变量
    echo "# flume environment" >> /etc/profile
    echo "export FLUME_HOME=${install_path}/flume-${flume_version}" >> /etc/profile
    echo 'export PATH=${FLUME_HOME}/bin:$PATH' >> /etc/profile
    echo -e "\n" >> /etc/profile
    cp $install_path/flume-${flume_version}/conf/flume-env.sh.template $install_path/flume-${flume_version}/conf/flume-env.sh
    echo "export JAVA_HOME=${jdk_path}" >> $install_path/flume-${flume_version}/conf/flume-env.sh

}
