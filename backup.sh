#!/bin/bash

echo -e "\033[0;32mBacking up source data to GitHub...\033[0m"

# Add changes to git.
git add .

# Commit changes.
msg="Baking up `date`"
if [ $# -ne 0 ]
  then msg="$*"
fi
git commit -m "$msg"

#Push source
git push origin master

echo -e "\033[0;32mFinish backing up!\033[0m"
