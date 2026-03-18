#!/bin/zsh

BASE_DIR="./Website Projekte"
THUMBS_DIR="$BASE_DIR/thumbs"
RESIZED_DIR="$BASE_DIR/resized"

# Max width/height for files in /resized
MAX_SIZE=1600

mkdir -p "$THUMBS_DIR" "$RESIZED_DIR" || true

process_image() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  # Ignore output folders
  [[ "$file" == "$THUMBS_DIR/"* ]] && return 0
  [[ "$file" == "$RESIZED_DIR/"* ]] && return 0

  # Only image files
  case "${file:l}" in
    *.jpg|*.jpeg|*.png|*.webp|*.heic|*.tif|*.tiff|*.JPG|*.JPEG) ;;
    *) return 0 ;;
  esac

  local filename="${file:t}"
  local name="${filename%.*}"

  local resized_out="$RESIZED_DIR/${name}.jpg"
  local thumb_out="$THUMBS_DIR/${name}.jpg"

  already_exists=false
  [[ -f "$resized_out" ]] && already_exists=true
  [[ -f "$thumb_out" ]] && already_exists=true

  if ! $already_exists; then

  # Smaller version only if original is too big
  magick "$file" \
    -auto-orient \
    -resize "${MAX_SIZE}x${MAX_SIZE}>" \
    -strip \
    -quality 88 \
    "$resized_out"

  # Square thumbnail 300x300
  magick "$file" \
    -auto-orient \
    -thumbnail "300x300^" \
    -gravity center \
    -extent 300x300 \
    -strip \
    -quality 88 \
    "$thumb_out"
  
    cat <<EOF
<a data-fancybox="projects" class="tile" href="$resized_out" data-lightbox="projects" data-title="${name}">
  <img src="$thumb_out" alt="${name}">
</a>
EOF
  fi
}

# Process files already in main folder
find "$BASE_DIR" -maxdepth 1 -type f | while read -r file; do
  process_image "$file"
done
