#!/bin/bash
action=$1
originRepo=$2
sourceRepo=$3
# 源分支
originBranch=$4
if [ ! $originBranch ];then
    originBranch="main"
fi
# 目标分支名
sourceBranch=$5
if [ ! $sourceBranch ];then
    sourceBranch=$originBranch
fi

# npm 版本
publishVersion=$6

echo $originBranch
echo $sourceBranch

# id="$($(dirname "$0")/getName.js ${originRepo} ${sourceRepo})"
# filepath=$(cd "$(dirname "$0")"; pwd) # 本地开发使用
filepath=""
echo $filepath

workDir="/root/app"
originDir="${originRepo#*/}"
originDir=$workDir/"${originDir%.*}"

sourceDir="${sourceRepo#*/}"
sourceDir="${sourceDir%.*}"
sourceDir=$workDir/"${sourceDir}"

# workDir=`pwd`

#存在工作目录，移除工作目录
if [ -d $workDir ];then
    rm -rf $workDir
fi

# 重新创建目录
mkdir -p $workDir
cd $workDir

# # 克隆仓库代码
git clone -b $originBranch --depth 1 ${originRepo}
git clone -b $sourceBranch --depth 1 ${sourceRepo}

# 删除目标代码的除.git之外的代码
echo "-----delete source dir-----"
cd $sourceDir && ls | grep -v "^.git$" | xargs -I {} rm -rf {}

cd $originDir
pwd # 查看当前路径
git branch # 查看当前分支

# 安装包
tnpm i

# 若需要更新 npm 版本，运行更新脚本
if [ $publishVersion ]; then
    node $originDir/scripts/release.js $publishVersion
    # git add .
    # git commit -m "feat: npm版本更新$publishVersion"
    # git push
fi
# 拷贝原始代码的除 .git 和以 not-external 开头的文件或者文件夹代码到目标代码文件夹
echo "-----copy origin to source dir-----"
ls | grep -v "^.git$" | grep -v "^not-external" | grep -v "^node_modules$" | xargs -I {} cp -r {} $sourceDir

pwd

# 提交此次 github 变更
echo "-----ready push to gihub-----"
cd $sourceDir
git add .
if [ $publishVersion ]; then
    git commit -m "release: $publishVersion"
else
    git commit -m "feat: 版本更新"
fi
git tag v$publishVersion
git push origin refs/tags/v$publishVersion
git push
