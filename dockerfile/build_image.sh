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

## 获取用户输入
# $1 提示信息
# $2 使用正则校验用户的输入
# $3 默认值
read_value=""
function readValue(){
    read_value=""

    tip_msg="$1"
    regex_of_value="$2"
    default_value="$3"

    until  [[ ${read_value} =~ ${regex_of_value} ]];do
        read -r -p "${tip_msg}" read_value;read_value=${read_value:-${default_value}}
    done
}

function dockerBuild(){

  target_module=""
  case $1 in
   f)
          target_module="Dockerfile-Front"
          ;;
   m)
          target_module="Dockerfile-Node-Manager"
          ;;
   w)
          target_module="Dockerfile-Web"
          ;;
   s)
          target_module="Dockerfile-MySQL"
          ;;
  esac

  LOG_INFO "Start to build [${target_module}] docker image..."
  readValue "镜像的新标签, 默认: v1.3.2 ? " "^v[0-9]+\.[0-9]+\.[0-9]+$" "v1.3.2"
  new_version="${read_value}"
  branch="$2"

  cd ${__root}/dockerfile
  case $1 in
   f)
      new_name=yuanmomo/webase-front:"${new_version}"
      cat Dockerfile-Front | docker build -t "${new_name}" -f - https://github.com/WeBankFinTech/WeBASE-Front.git#"${branch}"
      docker push "${new_name}"
      ;;
   m)

      new_name=yuanmomo/webase-node-manager:"${new_version}"
      cat Dockerfile-Node-Manager | docker build -t "${new_name}" -f - https://github.com/WeBankFinTech/WeBASE-Node-Manager.git#"${branch}"
      docker push "${new_name}"
      ;;
   w)
      new_name=yuanmomo/webase-web:"${new_version}"
      cat Dockerfile-Web | docker build -t "${new_name}" -f - https://github.com/WeBankFinTech/WeBASE-Web.git#"${branch}"
      docker push "${new_name}"
      ;;
   s)
      new_name=yuanmomo/manager-mysql:"${new_version}"
      cat Dockerfile-MySQL | docker build -t "${new_name}" -f - https://github.com/WeBankFinTech/WeBASE-Node-Manager.git#"${branch}"
      cat Dockerfile-MySQL-guomi | docker build -t "${new_name}-gm" -f - https://github.com/WeBankFinTech/WeBASE-Node-Manager.git#"${branch}"
      docker push "${new_name}"
      docker push "${new_name}"-gm
      ;;
   k)
      new_name=yuanmomo/webase-sign:"${new_version}"
      cat Dockerfile-Sign | docker build -t "${new_name}" -f - https://github.com/WeBankFinTech/WeBASE-Sign.git#"${branch}"
      docker push "${new_name}"
      ;;
  esac
}

echo "  f: 编译 Front 镜像; "
echo "  m: 编译 Node-Manager 镜像; "
echo "  w: 编译 Web 镜像; "
echo "  s: 编译 Manager-MySQL 镜像; "
echo "  k: 编译 Sign 镜像; "
echo "  a: 全量编译 Front, Node-Manager, Web, Manager-Mysql, Sign 镜像; "
readValue "编译模块, 默认: f ? " "^([aA]|[Ff]|[Mm]|[Ww]|[Ss]|[Kk])$" "f"
target_image=$(echo "${read_value}" | tr [A-Z]  [a-z])

if [[ "${target_image}"x == "a"x ]] ; then
    dockerBuild "f" "master"
    dockerBuild "m" "master"
    dockerBuild "w" "master"
    dockerBuild "s" "master"
    dockerBuild "k" "master"
else
    dockerBuild "$target_image" "master"
fi


