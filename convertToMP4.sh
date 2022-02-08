#!/bin/bash
codec=libx265
rate=28
numthreads=3
usage="$(basename "$0") [-c n] [-r n] [-t n]-- program to convert all webm files to mp4.

where:
    -h  show this help text
    -c  codec (default: libx265)
    -r  crf (default: 28)
    -t  number of threads  to use(default: 3)
    "
while getopts c:r:t: flag
do
    case "${flag}" in 
        c) codec=${OPTARG};;
        r) rate=${OPTARG};;
        t) numthreads=${OPTARG};;
        h) echo "$usage";exit;;
        :) printf "missing argument for -%s\n" "$OPTARG" >&2;
           echo "$usage" >&2;
           exit 1;;
       \?) printf "illegal option: -%s\n" "$OPTARG" >&2;
           echo "$usage" >&2;
           exit 1;;
    esac
done

for i in *.webm; do ffmpeg -i "$i" -threads $numthreads -vcodec "$codec" -crf $rate "${i%.*}.mp4";done   
