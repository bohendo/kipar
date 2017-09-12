#!/bin/bash

input="My Clippings.txt"
output="my-clippings.txt"

# Sanity Checks
if [[ ! -f "$input" ]]; then echo "Nothing to coalesce"; exit;
fi

# Move $output to a temporary read location so we can 
#   write to this filename at the other end of our pipe
if [[ -f "$output" ]]; then mv "$output" ".$output.backup"
fi

# Send our input and old output into the pipe
cat "$input" ".$output.backup" |\

# Remove byte order markers
sed 's/^\xef\xbb\xbf//' |\

# Transform everything into one giant line
tr -d '\n\r' |\

# Split every highlight/bookmark/note onto it's own line
sed 's/==========/==========\n/g' |\

# Sort numerically so books w same title will sort by page/location
# Note: the above logic is flawed, currently sorts 100, 12, 2
# Remove any duplicate lines (we're idempotent!)
sort -n | uniq |\

# Put the newlines back where they were originally and we're done
sed 's/==========/\n==========/g' |\
sed 's/ \([AP]M\)/ \1\n\n/'       |\
sed 's/- Your/\n- Your/'           \
> "$output"

# Remove our input & old output if everything went well
if [[ $? -eq 0 && -f "$output" ]]; then
  rm ".$output.backup" "$input"
fi

