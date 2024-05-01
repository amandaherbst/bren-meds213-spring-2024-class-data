#!/bin/bash 
# how every bash script must start

for file in *.csv; do 
    echo "$file has $(wc -l < $file) lines"
done