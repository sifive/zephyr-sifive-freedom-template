# Zephyr SiFive Freedom Board Template

This repository contains a template for automatically porting [Zephyr RTOS](https://zephyrproject.org) to a SiFive Freedom E-Series board based on that board's DTS file.

## How to use

1. Choose a location for storing custom board configurations. We'll refer to this directory as `<BOARD_DIRECTORY>`
2. `git clone https://github.com/sifive/zephyr-sifive-freedom-template.git <YOUR_BOARD_NAME>`
3. `cd <YOUR_BOARD_NAME>`
4. Copy your DTS file into the current directory
5. `./customize_board.sh`
6. Select your desired ROM Boot address

`customize_board.sh` is idempotent, so feel free to re-run it as many times as you like.

### To build the `hello_world` sample project

1. `source /opt/zephyr/<ZEPHYR_VERSION>/zephyr-env.sh`
2. `cd /opt/zephyr/<ZEPHYR_VERSION>/samples/hello_world`
3. `mkdir build && cd build`
4. `cmake -DBOARD=<YOUR_BOARD_NAME> -DBOARD_ROOT=<BOARD_DIRECTORY> ..`
5. `make -j$(nproc)`
6. The output binary is in zephyr/zephyr.elf

## To Clean/Reset

1. `git clean -dfx` will reset the template to a clean state

