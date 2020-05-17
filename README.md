# 使用说明

# 生成节点

```Bash
# 安装节点工具
sudo apt install -y openssl curl

cd ~ && mkdir -p fisco && cd fisco

curl -LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v2.4.0/build_chain.sh && chmod u+x build_chain.sh
 
bash build_chain.sh -l "127.0.0.1:4" -p 30300,20200,8545 -d
```

# TODO List

* 增加 `start.sh` 脚本，整合 `build_chain.sh` 和 `docker compose` 命令；
* 优化各个项目的 Docker 镜像结构；
* 完成 README.md 文档；
* 设计和实现镜像更新方案；