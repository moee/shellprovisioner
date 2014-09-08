#!/usr/bin/env bash

config=$1
configs_dir=configs
tasks_dir=tasks

success () { echo -e "\e[00;32mSuccess\e[00m"; }
error () { echo -e "\e[00;31mError: $1\e[00m"; }
fatal () { echo -e "\e[00;31mFatal Error: $1\e[00m"; exit 1; }
info () { echo -e "\e[00;34m$1\e[00m"; }

usage() {
    echo "Usage: $0 configname"
}

if [ -z $config ]; then
    usage
    exit 1
fi

if [ ! -f $configs_dir/$config ]; then
    fatal "Config $config does not exist."
fi

info "Running config $config"

info "Checking tasks"
for task in `cat $configs_dir/$config`; do
    if [ ! -d $tasks_dir/$task ]; then
        fatal "task directory $tasks_dir/$task not found" 
    fi

    if [ ! -f $tasks_dir/$task/do.sh ]; then
        fatal "task file $tasks_dir/$task/do.sh not found" 
    fi
done

info "Running tasks"
num=1 
for task in `cat $configs_dir/$config`; do
    info "starting task $num: $task"
    $tasks_dir/$task/do.sh
    if [ $? != 0 ]; then
        error "task $task failed. Rolling back."
        for task in `tac $configs_dir/$config | tail -n $num`; do
            if [ -f $tasks_dir/$task/undo.sh ]; then
                info "undo $task"
                $tasks_dir/$task/undo.sh            
            fi
        done
        error "provisioning of $config failed."
        exit 1
    else
        info "success"
    fi
    let num=num+1
done

info "$config is now ready."
