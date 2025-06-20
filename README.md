# YouTube Playlist to MP3 Album

_This tool converts a YouTube Playlist to a folder of MP3 files with cover image and metadata pulled from Discogs_

## Usage

```
bash yttoalbum.sh "Paul Simon" "Graceland" "https://www.youtube.com/watch?v=eL2fMjSA-rs&list=PLHyO2T46aytAfiTMq5RqEoGPzgMyzOMf5"
```

or

```
zsh yttoalbum.sh "Paul Simon" "Graceland" "https://www.youtube.com/watch?v=eL2fMjSA-rs&list=PLHyO2T46aytAfiTMq5RqEoGPzgMyzOMf5"
```

## Configuration

- `DISCOGS_TOKEN` — Required env var. Create a personal access token at [Discogs Developer Settings](https://www.discogs.com/settings/developers).

## Contributing

Feel free to contribute. Please open issues or pull requests.

## Prerequisites

- ffmpeg
- jq
- Python3
- Discogs Personal Access Token
