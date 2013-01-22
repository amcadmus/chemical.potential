#!/bin/bash

for i in `ls`;
do
    if test -d $i; then
	test -f $i/Makefile && make -C $i clean
    fi
done