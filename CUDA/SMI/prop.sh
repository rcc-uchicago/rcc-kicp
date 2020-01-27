#!/bin/bash

nvidia-smi -L
nvidia-smi -q -i 0 -d MEMORY | tail -n 5
nvidia-smi -q -i 0 -d UTILIZATION | tail -n 100

#ssh gpu1405

nvidia-smi topo -m
