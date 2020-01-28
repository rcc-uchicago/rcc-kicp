#!/bin/bash

module="python"

if [ "$#" -eq 1 ]; then
   module=$1
fi

ip=$(host `uname -n` | cut -d ' ' -f 4)
port=$((10000+ $RANDOM % 20000))

echo "Starting ipython notebook"
echo "If you need another version of Python please run sh $BASH_SOURCE python_module_name"
echo "Please wait ..."

module load $module

jupyter notebook --no-browser --ip=$ip --port=$port --log-level='ERROR'
