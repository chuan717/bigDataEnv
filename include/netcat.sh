#!/bin/bash
install_netcat()
{
    local netcat_version=$1
    local install_path=$2
    local stack=$3
    # 判断源文件是否存在，不存在即下载netcat-0.7.1.tar.gz
    if [ ! -f $CUR/src/netcat-${netcat_version}.tar.gz ]; then
    	log_info "下载netcat-${netcat_version}"
        wget -O $CUR/src/netcat-${netcat_version}.tar.gz https://sourceforge.NET/projects/netcat/files/netcat/${netcat_version}/netcat-${netcat_version}.tar.gz
        log_info "解压缩netcat-${netcat_version}"
        tar -zxvf $CUR/src/netcat-${netcat_version}.tar.gz -C $install_path
    else
        log_info "解压缩netcat-${netcat_version}"
        tar -zxvf $CUR/src/netcat-${netcat_version}.tar.gz -C $install_path
    fi
    chown $USER:$USER -R $install_path/netcat-${netcat_version}
    cd $install_path/netcat-${netcat_version} && ./configure && make && make install
    # 添加环境变量
    echo "# netcat environment" >> /etc/profile
    echo "export NETCAT_HOME=${install_path}/netcat-${netcat_version}" >> /etc/profile
    echo 'export PATH=${NETCAT_HOME}/bin:$PATH' >> /etc/profile
    echo -e "\n" >> /etc/profile

    if [ ${stack} = "undistributed" ];then
        echo "undistrubuted"
    else
        echo "distrubuted"
    fi
}
