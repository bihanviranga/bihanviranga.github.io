#!/opt/homebrew/bin/bash
set -e

echo "[*] Starting build process"

SRC="src"
DIST="docs"

# clean HTML files from dist (but keep existing assets)
find "$DIST" -type f -name "*.html" -delete
mkdir -p "$DIST"

# load template
TEMPLATE="$SRC/common/template.html"
if [[ -f "$TEMPLATE" ]]; then
    template_content=$(cat "$TEMPLATE")
else
    echo "[x] No template found. Proceeding without one."
    template_content="{{slot}}"
fi

# process HTML files
find "$SRC" -name "*.html" ! -path "$SRC/common/*" | while read -r file; do
    relpath=${file#"$SRC/"}
    out="$DIST/$relpath"

    mkdir -p "$(dirname "$out")"

    # split metadata (if present) from content
    meta_block=""
    if [[ $(head -n1 "$file") == "---" ]]; then
        meta_block=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d')
        content=$(sed '1,/^---$/d' "$file")
    else
        content=$(cat "$file")
    fi

    # parse metadata into associative array
    declare -A meta
    while IFS=":" read -r key value; do
        key=$(echo "$key" | xargs)      # trim whitespace
        value=$(echo "$value" | xargs)  # trim whitespace
        [[ -n "$key" ]] && meta["$key"]="$value"
    done <<< "$meta_block"

    # compute depth
    depth=$(echo "$relpath" | awk -F/ '{print NF-1}')
    base=""
    for ((i=0;i<depth;i++)); do
        base="../$base"
    done
    meta["base"]="${base:-./}"

    # phase 1: replace partials {{name}} with src/common/name.html
    for name in $(grep -o '{{[a-zA-Z0-9_-]\+}}' <<< "$content" | sed 's/[{}]//g'); do
        if [[ -f "$SRC/common/$name.html" ]]; then
            part=$(<"$SRC/common/$name.html")
            content="${content//\{\{$name\}\}/$part}"
        fi
    done

    # phase 2: inject into template at {{slot}}
    final="${template_content//\{\{slot\}\}/$content}"

    # phase 3: replace the metadata placeholders such as {{title}} and {{description}}
    for key in "${!meta[@]}"; do
        final="${final//\{\{$key\}\}/${meta[$key]}}"
    done


    echo "$final" > "$out"
    echo "[+] Built $out"
done

echo "[+] Build process complete"
