#!/bin/bash
for i in $(dir)
do
        tar -czf $i.tar.gz $i
        if [ $? -eq 0 ]
        then
                echo $i" has been tared"
                rm -r $i
                echo $i" has been removed"
        else
                echo $i" could not get tared and wont be removed"
        fi
done
