#!/usr/bin/env bash

LOG_WARN()
{
    local content=${1}
    echo -e "\033[31m[WARN] ${content}\033[0m"
}

LOG_INFO()
{
    local content=${1}
    echo -e "\033[32m[INFO] ${content}\033[0m"
}

function replaceFile(){
    file="$1"

    content=$(cat "${file}" | envsubst)
    cat <<< "${content}" > "${file}"
}


# 命令返回非 0 时，就退出
set -o errexit
# 管道命令中任何一个失败，就退出
set -o pipefail
# 遇到不存在的变量就会报错，并停止执行
set -o nounset
# 在执行每一个命令之前把经过变量展开之后的命令打印出来，调试时很有用
#set -o xtrace

# 退出时，执行的命令，做一些收尾工作
trap 'echo -e "Aborted, error $? in command: $BASH_COMMAND"; trap ERR; exit 1' ERR

# Set magic variables for current file & dir
# 脚本所在的目录
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 脚本的全路径，包含脚本文件名
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
# 脚本的名称，不包含扩展名
__base="$(basename ${__file} .sh)"
# 脚本所在的目录的父目录，一般脚本都会在父项目中的子目录，
#     比如: bin, script 等，需要根据场景修改
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app


####### 参数解析 #######
cmdname=$(basename $0)
guomi_opt=""
guomi_suffix=""
BUILD_VERSION="v2.4.1"
encrypt_type="0"
DOCKER_TAG="v1.3.2"
MYSQL_TAG=""

# usage help doc.
usage() {
    cat << USAGE  >&2
Usage:
    $cmdname [-w DOCKER_TAG] [-b build_version] [-g] [-h]
    -w        The docker image tag, default v1.3.2
    -b        The version of build chain shell script, default v2.4.1.
    -g        Use guomi, default no.
    -h        Show help info.
USAGE
    exit 1
}

while getopts w:b:gh OPT;do
    case $OPT in
        w)
            DOCKER_TAG=$OPTARG
            ;;
        b)
            BUILD_VERSION=$OPTARG
            ;;
        g)
            guomi_opt=" -g "
            encrypt_type="1"
            guomi_suffix="-gm"
            ;;
        h)
            usage
            exit 3
            ;;
        \?)
            usage
            exit 4
            ;;
    esac
done


# 判断系统
# Debian(Ubuntu) or RHEL(CentOS)
cmd="apt"
if [[ $(command -v yum) ]]; then
	cmd="yum"
fi

# update first
${cmd} -y update
if [[ ${cmd} == "apt" ]]; then
    ${cmd} -y upgrade
fi

${cmd} install -y openssl wget curl

fisco_dir=~/fisco

if [ ! -d "${fisco_dir}" ]; then
  mkdir -p "${fisco_dir}"
fi

if [ -d "${fisco_dir}/nodes" ]; then
  LOG_WARN "Already deployed, delete [${fisco_dir}/nodes] first and re-exec deploy.sh ."
  exit 5;
fi

# download build_chain.sh and generate nodes config
cd "${fisco_dir}" && curl -LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/"${BUILD_VERSION}"/build_chain.sh && chmod u+x build_chain.sh
bash build_chain.sh -l "127.0.0.1:4" -d "$guomi_opt" -o fisco/nodes

# 根据系统, 安装 docker
case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)
    ## install docker
    if [[ ! $(command -v docker) ]]; then
      bash <(curl -s -L get.docker.com);
      curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
      chmod +x /usr/local/bin/docker-compose;
    fi
    ;;
  darwin*)
    LOG_WARN "Unsupported macOS yet."
    exit 6;
    ;;
  msys*)
    LOG_WARN "Unsupported Windows yet."
    ;;
  *)
    LOG_WARN "Unknown OS."
    ;;
esac


cd "${__dir}"
# 修改配置文件
LOG_INFO "Update configuration files..."
MYSQL_TAG="${DOCKER_TAG}${guomi_suffix}"
BUILD_VERSION="${BUILD_VERSION}${guomi_suffix}"

export DOCKER_TAG
export MYSQL_TAG
export BUILD_VERSION

replaceFile docker-compose.yml

sed -i "s/encryptType.*#/encryptType: ${encrypt_type} #/g" conf/front-application.yml
sed -i "s/encryptType.*#/encryptType: ${encrypt_type} #/g" conf/sign-application.yml
sed -i "s/encryptType.*#/encryptType: ${encrypt_type} #/g" conf/node-manager-application.yml

if [[ ! $(command -v docker-compose) ]]; then
  LOG_WARN "Docker && Docker Compose install failed!!!"
  exit 7;
fi

