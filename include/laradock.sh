#!/bin/bash
#set -x
install_laradock()
{
    local docker_version=$1
    local install_path=$2
    yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
    

    # 判断源文件是否存在，不存在即下载docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
    if [ ! -f $CUR/src/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm  ]; then
        log_info "下载docker-selinux(https://pan.baidu.com/s/1qArsAPo8h0zn6F7Fix37tA)并将文件放在src文件夹"
        wget -O $CUR/src/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm  https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
    else
        log_info "安装docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm"
        yum install -y $CUR/src/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
    fi

    # 判断源文件是否存在，不存在即下载docker-ce-18.03.0.ce-1.el7.centos.x86_64.rpm 
    if [ ! -f $CUR/src/docker-ce-${docker_version}.ce-1.el7.centos.x86_64.rpm  ]; then
        log_info "下载docker(https://pan.baidu.com/s/1l84j-_Ac10_AX5n2HBnCQA)并将文件放在src文件夹"
        wget -O $CUR/src/docker-ce-${docker_version}.ce-1.el7.centos.x86_64.rpm  https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-${docker_version}.ce-1.el7.centos.x86_64.rpm
    else
        log_info "安装docker-ce-${docker_version}.ce-1.el7.centos.x86_64.rpm"
        yum install -y $CUR/src/docker-ce-${docker_version}.ce-1.el7.centos.x86_64.rpm
    fi
    # 安装必要文件
    log_info "install epel-release python-pip git"
    yum install -y epel-release 
    yum install -y python-pip 
    yum install -y git
    pip install docker-compose
    # 启动docker-ce
    log_info "start docker"
    systemctl enable docker
    systemctl start docker
    # 将当前用户加入docker用户组
    log_info "添加当前用户到docker用户组"
    usermod -aG docker $USER
    log_info "镜像加速"
    cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://1234abcd.mirror.aliyuncs.com"
  ]
}
EOF
    cd $install_path;git clone https://github.com/yiluohan1234/laradock
    cp $install_path/laradock/env-example $install_path/laradock/.env
    echo "DB_HOST=mysql" >> $install_path/laradock/.env
    echo "REDIS_HOST=redis" >> $install_path/laradock/.env
    echo "QUEUE_HOST=beanstalkd" >> $install_path/laradock/.env
} 
