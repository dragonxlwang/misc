#!/bin/bash

# Tom Hale, 2016. MIT Licence.
# Print out 256 colours, with each number printed in its corresponding colour
# See http://askubuntu.com/questions/821157/print-a-256-color-test-pattern-in-the-terminal/821163#821163

set -eu # Fail on errors or undeclared variables

printable_colours=256

# Return a colour that contrasts with the given colour
# Bash only does integer division, so keep it integral
function contrast_colour {
    local r g b luminance
    colour="$1"

    if (( colour < 16 )); then # Initial 16 ANSI colours
        (( colour == 0 )) && printf "15" || printf "0"
        return
    fi

    # Greyscale # rgb_R = rgb_G = rgb_B = (number - 232) * 10 + 8
    if (( colour > 231 )); then # Greyscale ramp
        (( colour < 244 )) && printf "15" || printf "0"
        return
    fi

    # All other colours:
    # 6x6x6 colour cube = 16 + 36*R + 6*G + B  # Where RGB are [0..5]
    # See http://stackoverflow.com/a/27165165/5353461

    # r=$(( (colour-16) / 36 ))
    g=$(( ((colour-16) % 36) / 6 ))
    # b=$(( (colour-16) % 6 ))

    # If luminance is bright, print number in black, white otherwise.
    # Green contributes 587/1000 to human perceived luminance - ITU R-REC-BT.601
    (( g > 2)) && printf "0" || printf "15"
    return

    # Uncomment the below for more precise luminance calculations

    # # Calculate percieved brightness
    # # See https://www.w3.org/TR/AERT#color-contrast
    # # and http://www.itu.int/rec/R-REC-BT.601
    # # Luminance is in range 0..5000 as each value is 0..5
    # luminance=$(( (r * 299) + (g * 587) + (b * 114) ))
    # (( $luminance > 2500 )) && printf "0" || printf "15"
}

# Print a coloured block with the number of that colour
function print_colour {
    local colour="$1" contrast
    contrast=$(contrast_colour "$1")
    local text=${2-""}
    text=${text:+"] $text"}
    printf "\e[48;5;%sm" "$colour"                # Start block of colour
    printf "\e[38;5;%sm%3d" "$contrast" "$colour" # In contrast, print number
    printf "$text"                                # print text
    printf "\e[0m "                               # Reset colour
}
function print_colour_with_fg {
    local colour="$1" contrast
    contrast=$2
    local text=${3-""}
    text=${text:+"] $text"}
    printf "\e[48;5;%sm" "$colour"                # Start block of colour
    printf "\e[38;5;%sm%3d" "$contrast" "$colour" # In contrast, print number
    printf "$text"                                # print text
    printf "\e[0m"                                # Reset colour
}

# Starting at $1, print a run of $2 colours
function print_run {
    local i
    for (( i = "$1"; i < "$1" + "$2" && i < printable_colours; i++ )) do
        print_colour "$i"
    done
    printf "  "
}

# Print blocks of colours
function print_blocks {
    local start="$1" i
    local end="$2" # inclusive
    local block_cols="$3"
    local block_rows="$4"
    local blocks_per_line="$5"
    local block_length=$((block_cols * block_rows))

    # Print sets of blocks
    for (( i = start; i <= end; i += (blocks_per_line-1) * block_length )) do
        printf "\n" # Space before each set of blocks
        # For each block row
        for (( row = 0; row < block_rows; row++ )) do
            # Print block columns for all blocks on the line
            for (( block = 0; block < blocks_per_line; block++ )) do
                print_run $(( i + (block * block_length) )) "$block_cols"
            done
            (( i += block_cols )) # Prepare to print the next row
            printf "\n"
        done
    done
}

function print_lines {
    local i
    local start=0
    local end=255

    # Print sets of blocks
    for (( i = start; i <= end; i += 1 )) do
        printf "\n" # Space before each set of blocks
        print_colour $i "The quick brown fox jumps over the lazy dog THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG'S BACK 1234567890"
    done
}

function print_fg_lines {
    local i
    local start=0
    local end=255

    # Print sets of blocks
    for (( i = start; i <= end; i += 1 )) do
        printf "\n" # Space before each set of blocks
        print_colour_with_fg $i 0 "The "
        print_colour_with_fg $i 1 "quick "
        print_colour_with_fg $i 2 "brown "
        print_colour_with_fg $i 3 "fox "
        print_colour_with_fg $i 4 "jumps "
        print_colour_with_fg $i 5 "over "
        print_colour_with_fg $i 6 "the "
        print_colour_with_fg $i 7 "lazy "
        print_colour_with_fg $i 8 "dog "
        print_colour_with_fg $i 9 "THE "
        print_colour_with_fg $i 10 "QUICK "
        print_colour_with_fg $i 11 "BROWN "
        print_colour_with_fg $i 12 "FOX "
        print_colour_with_fg $i 13 "JUMPED "
        print_colour_with_fg $i 14 "OVER "
        print_colour_with_fg $i 15 "THE "
        print_colour_with_fg $i 16 "LAZY DOG'S BACK 1234567890"
    done
}

function print_tmux_lines {
    local i
    local start=0
    local end=255

    # Print sets of blocks
    for (( i = start; i <= end; i += 1 )) do
        printf "\n" # Space before each set of blocks
        print_colour_with_fg $i 14 "devgpu088.cco2 "
        print_colour_with_fg $i 13 "ⓢ devgpu088-main "
        print_colour_with_fg $i 3  "ⓘ 2 "
        print_colour_with_fg $i 12 "ⓟ 1 "
        print_colour_with_fg $i 14 "1:misc- "
        print_colour_with_fg $i 15 "2:vim* "
        print_colour_with_fg $i 14 "ⓟ Ⅰ ☎ 35:7 "
        print_colour_with_fg $i 10 "Ⓖ 0 0 "
        print_colour_with_fg $i 11 "Ⓛ 106.4 "
        print_colour_with_fg $i 12 "ⓒ 1.8 "
        print_colour_with_fg $i 3  "ⓜ 17.2 "
        print_colour_with_fg $i 2  "Tue Apr 30  1:17AM PDT "
    done
}

print_run 0 16 # The first 16 colours are spread over the whole spectrum
printf "\n"
print_blocks 16 231 6 6 3 # 6x6x6 colour cube between 16 and 231 inclusive
print_blocks 232 255 12 2 1 # Not 50, but 24 Shades of Grey


print_lines
printf "\n"
print_tmux_lines
printf "\n"
