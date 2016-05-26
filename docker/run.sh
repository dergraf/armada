#!/bin/bash

case $1 in
    run)
        ifconfig
        mosquitto | recall armada
        ;;
    shell)
        bin/bash
        ;;
    usage)
        less usage
        ;;
    *)
        cat <<-EOF
        Commands:
        run         Run that thing
        shell       Run a bash shell without starting vernemq
        usage       Show more usage information
EOF
        ;;
esac

