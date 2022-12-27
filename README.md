# PWNENV
## I am always stuck in the occasion of havig my pwn environment broken or incomplete, when I need it the most.
## This is a simple script to install all the tools I need to have a complete pwn environment.

## Usage:
docker build -t pwnenv .
docker run -it pwnenv

## Recommended setup:
### using zsh:
```
function checkContainerRunning() {
    docker container ls -q -f name="$1"
}

function pwnenv() {
    if [ $(checkContainerRunning "pwnenv") ]; then
        echo "Container already running, attaching..."
        docker exec -it pwnenv zsh
    else
        echo "Starting container..."
        docker run --net=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --rm -it pwnenv zsh
    fi
}
```

## Tools:
- pwntools
- gdb (pwndbg, gef, peda) https://github.com/apogiatzis/gdb
- radare2
- one_gadget
- ropper
- z3
- angr
- ropgadget
- checksec
- many more...

## Credits:
- This work is based on [pwndocker](https://github.com/skysider/pwndocker) and [pwnenv](https://github.com/christoss/pwnenv) a big thanks to them.
