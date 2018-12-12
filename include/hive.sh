#!/bin/bash
# 安装mysql并为hive配置环境
install_mysql()
{
rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
yum install -y mysql mysql-server mysql-libs
service mysqld start
systemctl start mysqld.service
mysqladmin -u root password 199037
HOSTNAME="localhost"
PORT="3306"
USERNAME="root"
PASSWORD="199037"
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} -e "create user 'hive'@'%' IDENTIFIED BY 'hive';GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%' WITH GRANT OPTION;grant all on *.* to 'hive'@'localhost' identified by 'hive';flush privileges;"
}

install_hive()
{
    local hive_version=$1
    local install_path=$2
    local stack=$3

    # 判断源文件是否存在，不存在即下载http://mirror.bit.edu.cn/apache/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz
    if [ ! -f $CUR/src/apache-hive-${hive_version}-bin.tar.gz ]; then
        log_info "download hive-${hive_version}"
        wget -O $CUR/src/apache-hive-${hive_version}-bin.tar.gz http://mirror.bit.edu.cn/apache/hive/hive-${hive_version}/apache-hive-${hive_version}-bin.tar.gz
        log_info "解压缩hive-${hive_version}"
        tar -zxvf $CUR/src/apache-hive-${hive_version}-bin.tar.gz -C $install_path
        mv ${install_path}/apache-hive-${hive_version}-bin ${install_path}/hive-${hive_version}
	chown $USER:$USER -R ${install_path}/hive-${hive_version}
    else
        log_info "解压缩hive-${hive_version}"
        tar -zxvf $CUR/src/apache-hive-${hive_version}-bin.tar.gz -C $install_path
        mv ${install_path}/apache-hive-${hive_version}-bin ${install_path}/hive-${hive_version}
        chown $USER:$USER -R ${install_path}/hive-${hive_version}
    fi
    if [ ${stack} = "undistributed" ];then
        log_info "安装mysql并进行配置"
        install_mysql
        log_info "添加环境变量"
        echo "# hive environment" >> /etc/profile
        echo "export HIVE_HOME=${install_path}/hive-${hive_version}" >> /etc/profile
        echo 'export HIVE_CONF_DIR=$HIVE_HOME/conf' >> /etc/profile
        echo 'export PATH=$HIVE_HOME/bin:$PATH' >> /etc/profile
        echo 'export CLASSPATH=$CLASSPATH:$HIVE_HOME/lib' >> /etc/profile
        echo -e "\n" >> /etc/profile

        log_info "配置hive-en.sh"
        mv ${install_path}/hive-${hive_version}/conf/hive-env.sh.template ${install_path}/hive-${hive_version}/conf/hive-env.sh
        
        hadoop_path="${install_path}/`ls -l ${install_path}|grep hadoop|awk '{print $NF}'`"
        echo "HADOOP_HOME=${hadoop_path}" >>${install_path}/hive-${hive_version}/conf/hive-env.sh
        echo "export HIVE_CONF_DIR=${install_path}/hive-${hive_version}/conf" >> ${install_path}/hive-${hive_version}/conf/hive-env.sh
        echo "export HIVE_AUX_JARS_PATH=${install_path}/hive-${hive_version}/lib" >> ${install_path}/hive-${hive_version}/conf/hive-env.sh
        log_info "配置hive-site.xml"
        cat > ${install_path}/hive-${hive_version}/conf/hive-site.xml << EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<!--jdbc -->
<!--
<property>
    <name>hive.metastore.local</name>
    <value>true</value>
    <description>使用本机mysql服务器存储元数据。这种存储方式需要在本地运行一个mysql服>务器</description>
</property>
-->
<property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://localhost:3306/hive?createDatabaseIfNotExist=true</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>hive</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>hive</value>
    <description>password to use against metastore database</description>
</property>
<property>
    <name>hive.metastore.warehouse.dir</name>
    <value>hdfs://localhost:9000/user/hive/warehouse</value>
</property>
<property>
    <name>datanucleus.autoCreateSchema</name>
    <value>false</value>
</property>
<property>
    <name>hive.metastore.schema.verification</name>
    <value>false</value>
</property>
<!--显示数据库名称-->
<property>
    <name>hive.cli.print.current.db</name>
    <value>true</value>
</property>
</configuration>
EOF
    log_info "配置mysql driver"
    wget -O $CUR/src/mysql-connector-java-5.1.41.tar.gz http://mirrors.sohu.com/mysql/Connector-J/mysql-connector-java-5.1.41.tar.gz
    tar -zxvf $CUR/src/mysql-connector-java-5.1.41.tar.gz -C $CUR/src
    cp $CUR/src/mysql-connector-java-5.1.41/mysql-connector-java-5.1.41-bin.jar ${install_path}/hive-${hive_version}/lib
    rm -rf $CUR/src/mysql-connector-java-5.1.41
    # 先执行schematool命令进行初始化
    log_info "schematool初始化"
    ${install_path}/hive-${hive_version}/bin/schematool -dbType mysql -initSchema
    else
        echo "distrubuted"
    fi
    ${hadoop_path}/bin/hdfs dfsadmin -safemode leave
}
          
    
