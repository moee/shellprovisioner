#!/usr/bin/env bash

config=$1

export ZDSP_BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
export ZDSP_TASK_DIR=$ZDSP_BASE_DIR/tasks
export ZDSP_CONFIG_DIR=$ZDSP_BASE_DIR/configs

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

provision() {

    config=$1

    if [ ! -f $ZDSP_CONFIG_DIR/$config ]; then
        fatal "Config $config does not exist."
    fi

    info "Running config $config"

    info "Checking tasks"
    for task in `cat $ZDSP_CONFIG_DIR/$config | sed $'s/\r$//'`; do

        echo $task

        if [[ $task == provision:* ]]; then
            continue
        fi

        if [ ! -d $ZDSP_TASK_DIR/$task ]; then
            fatal "task directory $ZDSP_TASK_DIR/$task not found" 
        fi

        if [ ! -f $ZDSP_TASK_DIR/$task/do.sh ]; then
            fatal "task file $ZDSP_TASK_DIR/$task/do.sh not found" 
        fi
    done

    info "Running tasks"
    num=1 

    base=""
    configs=""

    for comp in `echo $config | sed -e 's#/#\n#g'`; do
        base=$base$comp
        if [ -f $ZDSP_CONFIG_DIR/$base/__init__ ]; then
            configs="$configs $ZDSP_CONFIG_DIR/$base/__init__"
        else
            if [ -f $ZDSP_CONFIG_DIR/$base ]; then
                configs="$configs $ZDSP_CONFIG_DIR/$base"
            fi
        fi
        base=$base/
    done

    for task in `cat $configs | sed $'s/\r$//'`; do
        info "starting task $num: $task"

        if [[ $task == provision:* ]]; then
            provision `echo $task | sed s/^provision://g `
        fi

        sed -i $'s/\r$//' $ZDSP_TASK_DIR/$task/do.sh
        bash $ZDSP_TASK_DIR/$task/do.sh
        if [ $? != 0 ]; then
            error "task $task failed. Rolling back."
            for task in `tac $ZDSP_CONFIG_DIR/$config | tail -n $num`; do
                if [ -f $ZDSP_TASK_DIR/$task/undo.sh ]; then
                    info "undo $task"
                    sed -i $'s/\r$//' $ZDSP_TASK_DIR/$task/undo.sh
                    bash $ZDSP_TASK_DIR/$task/undo.sh            
                fi
            done
            error "provisioning of $config failed."
            exit 1
        else
            info "success"
        fi
        let num=num+1
    done

}

provision $config

info "$config is now ready."
