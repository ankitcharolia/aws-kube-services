#!/bin/bash

# without linebreaking
#git filter-branch -f --env-filter "GIT_AUTHOR_NAME='Ankit Charolia'; GIT_AUTHOR_EMAIL='ankitcharolia@gmail.com'; GIT_COMMITTER_NAME='Ankit Charolia'; GIT_COMMITTER_EMAIL='ankitcharolia@gmail.com';" HEAD

# with linebreaking
git filter-branch -f --env-filter "
	GIT_AUTHOR_NAME='Ankit Charolia'; 	
	GIT_AUTHOR_EMAIL='ankitcharolia@gmail.com' 
	GIT_COMMITTER_NAME='Ankit Charolia'
	GIT_COMMITTER_EMAIL='ankitcharolia@gmail.com'
     " HEAD

# git push origin master --force
