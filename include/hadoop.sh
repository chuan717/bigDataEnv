#!/bin/bash
generate_ssh()
{
id_res_pub=~/.ssh/id_rsa.pub  
if [ ! -f "$id_res_pub" ];then  
    ssh-keygen -t rsa  
else  
    echo "id_rsa.pub is exist!"  
fi  
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
}
install_hadoop()
{
    local hadoop_version=$1
    local install_path=$2
    local stack=$3
    generate_ssh
    # 判断源文件是否存在，不存在即下载
    if [ ! -f $CUR/src/hadoop-${hadoop_version}.tar.gz ]; then
        log_info "download hadoop-${hadoop_version}"
        wget -O $CUR/src/hadoop-${hadoop_version}.tar.gz http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-${hadoop_version}/hadoop-${hadoop_version}.tar.gz
        log_info "解压缩hadoop-${hadoop_version}"
        tar -zxvf $CUR/src/hadoop-${hadoop_version}.tar.gz -C $install_path
	chown $USER:$USER -R ${install_path}/hadoop-${hadoop_version}
    else
        log_info "解压缩hadoop-${hadoop_version}"
        tar -zxvf $CUR/src/hadoop-${hadoop_version}.tar.gz -C $install_path
        chown $USER:$USER -R ${install_path}/hadoop-${hadoop_version}
    fi
    if [ ${stack} = "undistributed" ];then
        # 配置core-site.xml
        cat > ${install_path}/hadoop-${hadoop_version}/etc/hadoop/core-site.xml<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
        <property>
             <name>hadoop.tmp.dir</name>
             <value>file:${install_path}/hadoop-${hadoop_version}/hadoop/tmp</value>
             <description>Abase for other temporary directories.</description>
        </property>
        <property>
             <name>fs.defaultFS</name>
             <value>hdfs://localhost:9000</value>
        </property>
</configuration>
EOF

        # 配置hdfs-site.xml
        cat > ${install_path}/hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
        <property>
             <name>dfs.replication</name>
             <value>1</value>
        </property>
        <property>
             <name>dfs.namenode.name.dir</name>
             <value>file:${install_path}/hadoop-${hadoop_version}/tmp/dfs/name</value>
        </property>
        <property>
             <name>dfs.datanode.data.dir</name>
             <value>file:${install_path}/hadoop-${hadoop_version}/tmp/dfs/data</value>
        </property>
</configuration>
EOF
        # 配置hadoop-env.sh
        jdk_path="${install_path}/`ls -l ${install_path}|grep jdk|awk '{print $NF}'`"
        sed -i "s#^export JAVA_HOME=.*#export JAVA_HOME=${jdk_path}#g" ${install_path}/hadoop-${hadoop_version}/etc/hadoop/hadoop-env.sh
        # 添加环境变量
        echo "# hadoop environment" >> /etc/profile
        echo "export HADOOP_HOME=${install_path}/hadoop-${hadoop_version}" >> /etc/profile
        echo 'export PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH' >> /etc/profile
        echo -e "\n" >> /etc/profile
        source /etc/profile
        hdfs namenode -format
    else
        echo "distrubuted"
    fi
}
          
    
