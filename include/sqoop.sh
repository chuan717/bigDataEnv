#!/bin/bash
install_sqoop()
{
    local sqoop_version=$1
    local install_path=$2
    local hadoop_path=$3
    local hive_path=$4
    # 判断源文件是否存在，不存在即下载https://mirrors.tuna.tsinghua.edu.cn/apache/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
    if [ ! -f $CUR/src/sqoop-${sqoop_version}.bin__hadoop-2.6.0.tar.gz ]; then
    	log_info "下载sqoop-${sqoop_version}"
        wget -O $CUR/src/sqoop-${sqoop_version}.bin__hadoop-2.6.0.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/sqoop/${sqoop_version}/sqoop-${sqoop_version}.bin__hadoop-2.6.0.tar.gz
        log_info "解压缩sqoop-${sqoop_version}"
        tar -zxvf $CUR/src/sqoop-${sqoop_version}.bin__hadoop-2.6.0.tar.gz -C $install_path
        mv $install_path/sqoop-${sqoop_version}.bin__hadoop-2.6.0 $install_path/sqoop-${sqoop_version}
    else
        log_info "解压缩sqoop-${sqoop_version}"
        tar -zxvf $CUR/src/sqoop-${sqoop_version}.bin__hadoop-2.6.0.tar.gz -C $install_path
        mv $install_path/sqoop-${sqoop_version}.bin__hadoop-2.6.0 $install_path/sqoop-${sqoop_version}
    fi
    wget -O $CUR/src/java-json.jar.zip http://www.java2s.com/Code/JarDownload/java-json/java-json.jar.zip
    unzip $CUR/src/java-json.jar.zip;mv $CUR/src/java-json.jar $install_path/sqoop-${sqoop_version}/lib
    chown $USER:$USER -R $install_path/sqoop-${sqoop_version}
    # 添加环境变量
    echo "# sqoop environment" >> /etc/profile
    echo "export SQOOP_HOME=${install_path}/sqoop-${sqoop_version}" >> /etc/profile
    echo 'export PATH=${SQOOP_HOME}/bin:$PATH' >> /etc/profile
    echo -e "\n" >> /etc/profile
    # 添加env.sh
    mv ${install_path}/sqoop-${sqoop_version}/conf/sqoop-env-template.sh ${install_path}/sqoop-${sqoop_version}/conf/sqoop-env.sh
    cat > ${install_path}/sqoop-${sqoop_version}/conf/sqoop-env.sh<<EOF
#Set path to where bin/hadoop is available
export HADOOP_COMMON_HOME=${hadoop_path}

#Set path to where hadoop-*-core.jar is available
export HADOOP_MAPRED_HOME=${hadoop_path}

#set the path to where bin/hbase is available
#export HBASE_HOME=/usr/local/hbase-1.2.6

#Set the path to where bin/hive is available
export HIVE_HOME=${hive_path}

#Set the path for where zookeper config dir is
#export ZOOCFGDIR=/usr/local/zookeeper-3.4.8
EOF
    
}
