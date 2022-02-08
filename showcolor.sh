#!/bin/bash
show_colour() {
    perl -e 'foreach $a(@ARGV){print "\e[48:2::".join(":",unpack("C*",pack("H*",$a)))."m      \e[49m "};print "\n"' "$@"
}

printf "                "
show_colour "$@"
