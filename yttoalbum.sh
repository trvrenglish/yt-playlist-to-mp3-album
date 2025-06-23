#!/bin/zsh

# Create a Discogs personal access token at https://www.discogs.com/settings/developers
: "${DISCOGS_TOKEN:?You must set the DISCOGS_TOKEN environment variable}"

mkdir -p "$HOME/Downloads/$1 - $2"

yt-dlp -x --audio-format mp3 -P "$HOME/Downloads/$1 - $2" "$3" -o "%(playlist_index)02d - %(title)s.%(ext)s"

cd "$HOME/Downloads/$1 - $2" || exit

artist_enc=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$1'''))")
album_enc=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$2'''))")

response=$(curl -s -H "Authorization: Discogs token=$DISCOGS_TOKEN" -A "ytb-playlist-to-mp3-album/1.0" \
"https://api.discogs.com/database/search?artist=$artist_enc&release_title=$album_enc&type=release&format=album" | jq '.results[0]')

if [[ "$response" == "null" || -z "$response" ]]; then
  echo "$response" > debug_response.json
  echo "No results found from Discogs. See debug_response.json."
  exit 1
fi

cover_url=$(echo "$response" | jq -r '.cover_image')
release_year=$(echo "$response" | jq -r '.year')


if [[ "$cover_url" != "null" && -n "$cover_url" ]]; then
  curl -L "$cover_url" -o cover.jpg
else
  echo "No cover image found on Discogs, using default cover.jpg if present."
fi

for f in *.mp3; do
  track_number=$(echo "$f" | awk -F' - ' '{print $1}' | sed 's/^0*//')
  newname="$(echo "$f" | sed 's/^[0-9]\{1,\} - //')"

  artist_nospaces=$(echo "$1" | tr -d '[:space:]')
  artist_regex=$(echo "$artist_nospaces" | sed 's/./&[ _-]*/g')

  clean_title=$(echo "$newname" | sed -E "
    s/^($artist_regex)[ _-]*//I;
    s/[[:space:]]*-[[:space:]]*\(Lyrics\)//I;
    s/\[Official Video\]//I;
    s/[[:space:]]*lyrics//I;
  ")
  title=$(echo "${clean_title%.mp3}" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')

  if [[ -f cover.jpg ]]; then
    ffmpeg -i "$f" -i cover.jpg \
      -map 0:a -map 1:v \
      -codec:a libmp3lame -qscale:a 2 \
      -id3v2_version 3 \
      -metadata artist="$1" \
      -metadata album="$2" \
      -metadata title="$title" \
      -metadata track="$track_number" \
      -metadata date="$release_year" \
      -metadata:s:v title="album cover" \
      -metadata:s:v comment="cover (front)" \
      "tmp_$title.mp3" && mv "tmp_$title.mp3" "$title.mp3" && rm "$f"
  else
    ffmpeg -i "$f" \
      -codec:a libmp3lame -qscale:a 2 \
      -id3v2_version 3 \
      -metadata artist="$1" \
      -metadata album="$2" \
      -metadata title="$title" \
      -metadata track="$track_number" \
      -metadata date="$release_year" \
      "tmp_$title.mp3" && mv "tmp_$title.mp3" "$title.mp3" && rm "$f"
  fi
done

rm -f cover.jpg
