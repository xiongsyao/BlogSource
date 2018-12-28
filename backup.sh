#!/bin/bash

echo -e "\033[0;32mBackup source data to GitHub...\033[0m"

# Add changes to git.
git add .

# Commit changes.
msg="backup `date`"
if [ $# -ne 0 ]
  then msg="$*"
fi
git commit -m "$msg"

#Push source
git push origin master

echo -e "\033[0;32mFinish backup!\033[0m"
