#!/bin/bash

#set permissions

path=$1
cd $path

for file in *.sh; do
	chmod u+x $file
	sed -i -e 's/\r$//' $file
done