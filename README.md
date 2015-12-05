# Summary

Compares the content to find out a suitable fork point and then rebase onto orphan branch.

The repository contains two branches without common ancestor. Root comommit in fact a snapshot of a commit of the other branch, so we have to joint these orphan branches to a DAG.

# Usage

```
git checkout <branch>
git-rebase-orphan-branch.sh <upstream>
```

To Revert:

```
git-rebase-orphan-branch.sh --undo
```
