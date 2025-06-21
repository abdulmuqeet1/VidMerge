#!/bin/bash

# Settings
OUTPUT_RES="1920:1080"
OUTFILE="output.mp4"
CRF=18
PRESET="veryfast"

# Collect video files
FILES=( *.mp4 )
NUM=${#FILES[@]}

if (( NUM < 2 )); then
    echo "Need at least two videos to concatenate."
    exit 1
fi

# Build FFmpeg input list and filter chains
INPUTS=""
FILTERS=""
V_LABELS=""
A_LABELS=""

for i in "${!FILES[@]}"; do
    INPUTS+="-i \"${FILES[$i]}\" "

    FILTERS+="
    [${i}:v]scale=${OUTPUT_RES}:force_original_aspect_ratio=decrease,\
pad=${OUTPUT_RES}:(ow-iw)/2:(oh-ih)/2,setsar=1[v$i];"

    V_LABELS+="[v$i]"
    A_LABELS+="[${i}:a]"
done

# Final filter chain
FILTERS+="
${V_LABELS}concat=n=$NUM:v=1:a=0[vout];
${A_LABELS}concat=n=$NUM:v=0:a=1[aout]"

# Run FFmpeg
CMD="ffmpeg $INPUTS -filter_complex \"$FILTERS\" -map \"[vout]\" -map \"[aout]\" \
-c:v libx264 -crf $CRF -preset $PRESET -c:a aac -b:a 192k \"$OUTFILE\""

# Print and run
echo "Running FFmpeg..."
eval $CMD
