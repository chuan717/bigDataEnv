#!/bin/bash
install_jdk()
{
    local jdk_version=$1
    local install_path=$2
    local stack=$3
    # 判断源文件是否存在，不存在即下载jdk-8u131-linux-x64.tar.gz
    if [ ! -f $CUR/src/jdk-${jdk_version}-linux-x64.tar.gz ]; then
        log_error "请先下载jdk(https://pan.baidu.com/s/1RxvaPVEYB3rN-bf8iJa7lQ)并将文件放在src文件夹" 
        exit 1 
    else
        log_info "解压缩jdk-${jdk_version}"
        tar -zxvf $CUR/src/jdk-${jdk_version}-linux-x64.tar.gz -C $install_path

    fi
    jdk_path="${install_path}/`ls -l ${install_path}|grep jdk|awk '{print $NF}'`"
    chown $USER:$USER -R ${jdk_path}
    if [ ${stack} = "undistributed" ];then
        # 添加环境变量
        echo "# jdk environment" >> /etc/profile
        echo "export export JAVA_HOME=$jdk_path" >> /etc/profile
        echo 'export PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH' >> /etc/profile
        echo 'export JRE_HOME=${JAVA_HOME}/jre' >> /etc/profile
        echo 'export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib' >> /etc/profile
        echo 'export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:$PATH' >> /etc/profile
        echo -e "\n" >> /etc/profile
        source /etc/profile
    else
        echo "distrubuted"
    fi
}
