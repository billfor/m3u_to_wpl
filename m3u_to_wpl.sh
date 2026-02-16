#!/bin/bash

# Usage: ./m3u_to_wpl.sh input.m3u output.wpl

INPUT_FILE=$1
OUTPUT_FILE=$2

# Create the header with UTF-8 declaration
# Use printf to ensure literal CRLF (\r\n) for Windows compatibility
printf "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n" > "$OUTPUT_FILE"
printf "<?wpl version=\"1.0\"?>\r\n" >> "$OUTPUT_FILE"
printf "<smil>\r\n" >> "$OUTPUT_FILE"
printf "    <head>\r\n" >> "$OUTPUT_FILE"
printf "        <meta name=\"Generator\" content=\"Microsoft Windows Media Player -- 11.0.5721.5145\"/>\r\n" >> "$OUTPUT_FILE"
printf "        <author/>\r\n" >> "$OUTPUT_FILE"
printf "        <title>$(basename "$INPUT_FILE" .m3u)</title>\r\n" >> "$OUTPUT_FILE"
printf "    </head>\r\n" >> "$OUTPUT_FILE"
printf "    <body>\r\n" >> "$OUTPUT_FILE"
printf "        <seq>\r\n" >> "$OUTPUT_FILE"

# Process the file
while IFS= read -r line || [[ -n "$line" ]]; do
    # 1. Remove Windows carriage returns
    clean_line=$(echo "$line" | tr -d '\r')
    
    # 2. Skip empty lines and M3U headers
    if [[ -n "$clean_line" && ! "$clean_line" =~ ^# ]]; then
        
        # 3. Escape XML characters (& and ")
        # This preserves characters like 'œ' and '’' 
        escaped_line=$(echo "$clean_line" | sed 's/&/\&amp;/g' | sed 's/"/\&quot;/g')
        
        # 4. Use %s to prevent \U or \M errors with backslashes
        printf "            <media src=\"%s\"/>\r\n" "$escaped_line" >> "$OUTPUT_FILE"
    fi
done < "$INPUT_FILE"

# Close the XML tags
printf "        </seq>\r\n" >> "$OUTPUT_FILE"
printf "    </body>\r\n" >> "$OUTPUT_FILE"
printf "</smil>\r\n" >> "$OUTPUT_FILE"