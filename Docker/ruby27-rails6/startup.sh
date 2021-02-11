#!/bin/bash
if [ ! -d "/root/.ssh/" ]; then
    mkdir /root/.ssh
    ln -s /var/lib/secrets/is_rsa /root/.ssh/id_rsa
fi
PWD=$(pwd)
rm ${PWD}/tmp/pids/server.pid
LANG=DE rails s -b 0.0.0.0 >>/${PWD}/log/rails_out 2>> ${PWD}/log/rails_err
