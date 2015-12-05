#!/bin/bash

# Compare the content to find out a suitable fork point
# and then rebase onto orphan branch.
#
# The repository contains two branches without common ancestor.
# Root comommit in fact a snapshot of a commit of the other branch,
# so we have to joint these orphan branches to a DAG.
#
# Author: Phoebus Veiz <phoebusveiz@qq.com>

if [ $1 = "--undo" ]; then
	git reset --hard ORIG_HEAD
	exit 0
fi

UPSTREAM=$1
FORK_POINT=0
ROOT_COMMIT=$(git rev-list --max-parents=0 HEAD)

git config --list | grep url

echo "Upstream:"
git log -n1 --oneline $UPSTREAM

WC_MERGE_BASE=$(git merge-base HEAD $UPSTREAM | wc -l)
if [ $WC_MERGE_BASE -eq 1 ]; then
	echo "Branches are not orphan. Ignore. Fork Point:"
	git log -n1 --oneline $(git merge-base HEAD $UPSTREAM)
	exit 0
fi

echo "Root Commit:"
git log -n1 --oneline $ROOT_COMMIT

for UPSTREAM_REV in $(git rev-list $UPSTREAM); do
	WC=$(git diff $ROOT_COMMIT --shortstat $UPSTREAM_REV | wc -l)
	if [ $WC -eq 0 ]; then
        	FORK_POINT=$UPSTREAM_REV
		break
	fi
done

if [ $FORK_POINT = "0" ]; then
	echo "No Fork Point. Exit."
	exit 0;
fi

echo "Fork Point:"
git log -n1 --oneline $FORK_POINT

git branch _backup-branch

git rebase --no-fork-point $FORK_POINT

DIFF_BACKUP_WC=$(git diff --shortstat _backup-branch | wc -l)
if [ $DIFF_BACKUP_WC -eq 1 ]; then
	echo "Fatal: Rebase failed!"
else
	git branch -D _backup-branch
	echo "Rebase successful."
fi
