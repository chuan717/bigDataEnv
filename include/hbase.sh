#!/bin/bash
install_hbase()
{
    local hbase_version=$1
    local install_path=$2
    local stack=$3
    # 判断源文件是否存在，不存在即下载http://www-us.apache.org/dist/hbase/1.2.6/
    if [ ! -f $CUR/src/hbase-${hbase_version}-bin.tar.gz ]; then
    	log_info "下载hbase-${hbase_version}"
        wget -O $CUR/src/hbase-${hbase_version}-bin.tar.gz http://www-us.apache.org/dist/hbase/${hbase_version}/hbase-${hbase_version}-bin.tar.gz
        log_info "解压缩hbase-${hbase_version}"
        tar -zxvf $CUR/src/hbase-${hbase_version}-bin.tar.gz -C $install_path
    else
        log_info "解压缩hbase-${hbase_version}"
        tar -zxvf $CUR/src/hbase-${hbase_version}-bin.tar.gz -C $install_path
    fi
    chown $USER:$USER -R $install_path/hbase-${hbase_version}
    # 添加环境变量
    echo "# hbase environment" >> /etc/profile
    echo "export HBASE_HOME=${install_path}/hbase-${hbase_version}" >> /etc/profile
    echo 'export PATH=${HBASE_HOME}/bin:$PATH' >> /etc/profile
    echo -e "\n" >> /etc/profile

    if [ ${stack} = "undistributed" ];then
        echo "undistrubuted"
    else
        echo "distrubuted"
    fi
}
