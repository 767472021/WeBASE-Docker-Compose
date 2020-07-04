# FISCO-BCOS，区块链中间件 一键部署

## 项目说明
该项目是 FISCO-BCOS 和 区块链中间件 中间件的一键快速部署工具。基于 Docker 和 Docker Compose 实现。

主要是为了简化部署流程和步骤，快速的部署一个区块链底层服务，以及一个可视化的管理界面，达到快速上手，快速使用的目的。

部署后的结构如下：
![fisco-bcos-docker-compose-architecture](https://img.tupm.net/2020/05/7D8E4C6141A6DF270B96D90EF3DCA775.jpg)

## 使用方法

### 部署

```Bash
# 生成节点配置文件
# 默认使用 FISCO-BCOS build_chain.sh 为 v2.4.1 版本；
# 默认使用 Docker 镜像版本为 v1.3.2 版本；
$ bash deploy.sh

# 部署标密版本
# -b 指定 FISCO-BCOS build_chain.sh 的 v2.4.1；
# -w 指定 Docker 镜像版本；
$ bash deploy.sh -w v1.3.2 -b v2.4.1 

# 部署国密版本
# -g 部署国密版本
$ bash deploy.sh -w v1.3.2 -b v2.4.1 -g

# 脚本帮助文档
$ bash deploy.sh -h
Usage:
    deploy.sh [-w webase_docker_tag] [-b build_version] [-g] [-h]
    -w        The docker image tag, default v1.3.2
    -b        The version of build chain shell script, default v2.4.1.
    -g        Use guomi, default no.
    -h        Show help info.

```
### 启动

```Bash
bash start.sh
```
### 停止

```Bash
bash stop.sh
```

## 镜像编译
执行 `dockerfile` 目录中的 `build_image.sh`，根据提示选择需要版本的版本，输入新的标签 `tag`。

如果需要需要编译指定的 GitHub 仓库，修改 `build_image.sh` 脚本中的仓库地址和 `branch` 分支即可。

# TODO List

* ~~增加 `start.sh` 脚本，整合 `build_chain.sh` 和 `docker compose` 命令；~~
* ~~优化各个项目的 Docker 镜像结构；~~
* ~~增加 Docker 镜像编译脚本；~~
* ~~完成 README.md 文档；~~
* 设计和实现镜像更新方案；
* 升级版本；