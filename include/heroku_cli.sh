#!/bin/bash
install_heroku_cli()
{
    local install_path=$1
    # 判断源文件是否存在，不存在即下载http://www-us.apache.org/dist/hbase/1.2.6/
    # 百度网盘:https://pan.baidu.com/s/1wRQoR9ghuPITcS2eAIhSyw
    if [ ! -f $CUR/src/heroku-linux-x64.tar.gz ]; then
    	log_info "下载heroku-linux-x64.tar.gz"
        wget -O $CUR/src/heroku-linux-x64.tar.gz https://cli-assets.heroku.com/heroku-linux-x64.tar.gz
        log_info "解压缩heroku-linux-x64.tar.gz"
        tar -zxvf $CUR/src/heroku-linux-x64.tar.gz -C $install_path
    else
        log_info "解压缩heroku-linux-x64.tar.gz"
        tar -zxvf $CUR/src/heroku-linux-x64.tar.gz -C $install_path
    fi
    chown $USER:$USER -R $install_path/heroku
    # 添加环境变量
    echo "# heroku_cli environment" >> /etc/profile
    echo "export HEROKU_HOME=${install_path}/heroku" >> /etc/profile
    echo 'export PATH=${HEROKU_HOME}/bin:$PATH' >> /etc/profile
    echo -e "\n" >> /etc/profile

}
