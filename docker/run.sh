#!/bin/bash

case $1 in
    run)
        ifconfig
        vernemq console | recall vernemq
        ;;
    shell)
        bin/bash
        ;;
    usage)
        less usage
        ;;
    *)
        cat <<-EOF
        Verne.mq Docker Image
        Usage: docker run --tty --interactive [command]
        Commands:
        run         Run vernemq
        shell       Run a bash shell without starting vernemq
        usage       Show more usage information
EOF
        ;;
esac

