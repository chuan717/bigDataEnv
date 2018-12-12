#!/bin/bash
# 安装scala
install_scala()
{
    local scala_version=$1
    local install_path=$2
	# 判断源文件是否存在，不存在即下载https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.tgz
    if [ ! -f $CUR/src/scala-${scala_version}.tgz ]; then
    	log_info "下载scala-${scala_version}"
        wget -O $CUR/src/scala-${scala_version}.tgz https://downloads.lightbend.com/scala/${scala_version}/scala-${scala_version}.tgz
        log_info "解压缩scalap-${scala_version}"
        tar -zxvf $CUR/src/scala-${scala_version}.tgz -C $install_path
    else
        log_info "解压缩scala-${scala_version}"
        tar -zxvf $CUR/src/scala-${scala_version}.tgz -C $install_path
    fi
    chown $USER:$USER -R $install_path/scala-${scala_version}
    # 添加环境变量
    echo "# scala environment" >> /etc/profile
    echo "export SCALA_HOME=${install_path}/scala-${scala_version}" >> /etc/profile
    echo 'export PATH=${SCALA_HOME}/bin:$PATH' >> /etc/profile
    echo -e "\n" >> /etc/profile
}
# 安装spark
install_spark()
{
    local spark_version=$1
    local install_path=$2
    local stack=$3
    # 判断源文件是否存在，不存在即下载https://archive.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-hadoop2.7.tgz
    if [ ! -f $CUR/src/spark-${spark_version}-bin-hadoop2.7.tgz ]; then
        log_info "下载spark-${spark_version}"
        wget -O $CUR/src/spark-${spark_version}-bin-hadoop2.7.tgz https://archive.apache.org/dist/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop2.7.tgz
        log_info "解压缩spark-${spark_version}"
        tar -zxvf $CUR/src/spark-${spark_version}-bin-hadoop2.7.tgz -C $install_path
        mv $install_path/spark-${spark_version}-bin-hadoop2.7 $install_path/spark-${spark_version}
    else
        log_info "解压缩spark-${spark_version}"
        tar -zxvf $CUR/src/spark-${spark_version}-bin-hadoop2.7.tgz -C $install_path
        mv $install_path/spark-${spark_version}-bin-hadoop2.7 $install_path/spark-${spark_version}
    fi
    chown $USER:$USER -R $install_path/spark-${spark_version}
    if [ ${stack} = "undistributed" ];then
        # 添加环境变量
        echo "# spark environment" >> /etc/profile
        echo "export SPARK_HOME=${install_path}/spark-${spark_version}" >> /etc/profile
        echo 'export PATH=${SPARK_HOME}/bin:$PATH' >> /etc/profile
        echo -e "\n" >> /etc/profile
        source /etc/profile
    else
        echo "distrubuted"
    fi
}
