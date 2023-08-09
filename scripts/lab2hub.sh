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

		id="$($(dirname "$0")/getName.js ${originRepo} ${sourceRepo})"
		# filepath=$(cd "$(dirname "$0")"; pwd) # 本地开发使用
		filepath=""
		echo $filepath

		cacheDir=$filepath/builds/pylon-git
		originDir="${originRepo#*/}"
		originDir=$cacheDir/"${originDir%.*}"

		sourceDir="${sourceRepo#*/}"
		sourceDir="${sourceDir%.*}"
		sourceDir=$cacheDir/"${sourceDir}"
		echo $originDir
		echo $sourceDir
		echo $cacheDir

		workDir=`pwd`
		# workDir="/root/app"

		#存在工作目录，移除工作目录
		if [ -d $cacheDir ];then
			    echo "1231"
				    rm -rf $cacheDir
				fi
				# 重新创建目录
				mkdir -p $cacheDir
				cd $cacheDir

				# # 克隆仓库代码
				#git clone -b $originBranch --depth 1 ${originRepo}
				git clone --depth 1 ${sourceRepo}

				# 删除目标代码的除.git之外的代码
				echo "-----delete source dir-----"
				cd $sourceDir && ls | grep -v "^.git$" | xargs -I {} rm -rf {}

				cd $workDir
				# 若需要更新 npm 版本，运行更新脚本
				if [ $publishVersion ]; then
					    node ./scripts/release.js $publishVersion
						    #git add .
							 #   git commit -m "feat: npm版本更新$publishVersion"
							#	    git push
								fi
								# 拷贝原始代码的除 .git 和以 not-external 开头的文件或者文件夹代码到目标代码文件夹
								echo "-----copy origin to source dir-----"
								ls | grep -v "^.git$" | grep -v "^not-external" | xargs -I {} cp -r {} $sourceDir

								pwd

								# 提交此次 github 变更
								echo "-----ready push to gihub-----"
								cd $sourceDir
								git add .
								git commit -m "feat: init"
								git push