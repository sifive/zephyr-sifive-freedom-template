#!/bin/bash

echo "Customizing board template for SiFive Freedom E-Series Chip"

BOARD_NAME=${PWD##*/}
BOARD_IDENTIFIER=$(echo $BOARD_NAME | sed -e 's/-/_/g' | tr '[:lower:]' '[:upper:]')

echo "Using the name of the containing folder for the board identifier: $BOARD_NAME"
echo "Using the upcase of that as an identifier: $BOARD_IDENTIFIER"

# Finding DTS File
echo "Looking for DTS in current directory..."
DTS_FILENAME=$(find . -maxdepth 1 -name "*.dts")
if [ -z $DTS_FILENAME ]; then
    >&2 echo "ERROR: DTS file not found!"
    exit 1    
fi
if [ "${DTS_FILENAME}" != "${BOARD_NAME}.dts" ]; then
    echo "Renaming ${DTS_FILENAME} to ${BOARD_NAME}.dts"
    mv $DTS_FILENAME ${BOARD_NAME}.dts
fi
DTS_FILENAME=${BOARD_NAME}.dts
DTB_FILENAME=${BOARD_NAME}.dtb

# Find first defined serial device in the DTS and use it to set the chosen UART
UART_DEV_NAME=`cat ${DTS_FILENAME} | python3 -c "import re, sys ; m = re.search('\s*(.*):\s*serial.*{', sys.stdin.read()) ; print(m.groups(0)[0])"`

# Getting Boot ROM Address
read -p "Do you want to boot from the default boot address 0x2040_0000? (Y/n): " DEFAULT_BASE_ADDR
case $DEFAULT_BASE_ADDR in
    [Nn]* ) read -p "Enter ROM boot address in hex (ex. 0x20000000, 0x20400000): " ROM_BASE_ADDR;;
    * ) ROM_BASE_ADDR="0x20400000";;
esac

# Copy and autofill template files
RENAME_FILES=("board_name.yaml" "board_name_defconfig")
TEMPLATE_FILES=("chosen.dtsi" "Kconfig.board" "Kconfig.defconfig" "${RENAME_FILES[@]}")

for template_file in "${TEMPLATE_FILES[@]}"
do
    cp templates/$template_file ./
    sed -i $template_file -e "s/<BOARD_IDENTIFIER>/$BOARD_IDENTIFIER/g" \
        -e "s/<BOARD_NAME>/$BOARD_NAME/g" -e "s/<ROM_BASE_ADDR>/$ROM_BASE_ADDR/" \
        -e "s/<UART_DEV_NAME>/$UART_DEV_NAME/g"
done

for rename_file in "${RENAME_FILES[@]}"
do
    mv $rename_file $(echo $rename_file | sed -e "s/board_name/$BOARD_NAME/")
done

# Include the customized chosen.dts file in the DTS
DTS_COMMENT="// Automatically included by customize_board.sh"
if ! grep -q "${DTS_COMMENT}" $DTS_FILENAME ;  then
    echo "${DTS_COMMENT}" >> $DTS_FILENAME
    cat chosen.dtsi >> $DTS_FILENAME
fi

# Generate dts.fixup
dtc $DTS_FILENAME -o $DTB_FILENAME -O dtb || exit 1
freedom-zephyrdtsfixup-generator -d $DTB_FILENAME -o dts.fixup  || exit 1

echo "Done customizing board files"
