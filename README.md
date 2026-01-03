# MediaFinder

A powerful PowerShell-based media file finder for locating audio, video, and picture files on your system.

## Features

- 🎵 **Audio File Detection** - Finds MP3, WAV, FLAC, AAC, OGG, M4A, WMA, OPUS, AIFF, and APE files
- 🎥 **Video File Detection** - Finds MP4, AVI, MKV, MOV, WMV, FLV, WebM, M4V, MPG, MPEG, 3GP, and DivX files
- 🖼️ **Picture File Detection** - Finds JPG, PNG, GIF, BMP, TIFF, SVG, WebP, ICO, RAW, and HEIC files
- 🔍 **Recursive Search** - Option to search subdirectories
- 📊 **Detailed Reports** - View file sizes, creation dates, and modification dates
- 💾 **Export Options** - Export results to CSV or JSON format
- 🎨 **Color-Coded Output** - Easy-to-read categorized results
- 📈 **Statistics** - Extension breakdown and file type summaries

## Requirements

- Windows PowerShell 5.1 or later
- PowerShell Core 7.x or later (cross-platform)

## Installation

1. Clone this repository:
   ```powershell
   git clone https://github.com/gdelfavero/MediaFinder.git
   cd MediaFinder
   ```

2. Ensure script execution is enabled:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## Usage

### Basic Usage

Search for all media files in the current directory:
```powershell
.\MediaFinder.ps1
```

### Search Specific Directory

```powershell
.\MediaFinder.ps1 -Path "C:\Users\Documents\Media"
```

### Filter by Media Type

Search for audio files only:
```powershell
.\MediaFinder.ps1 -MediaType Audio
```

Search for video files only:
```powershell
.\MediaFinder.ps1 -MediaType Video
```

Search for picture files only:
```powershell
.\MediaFinder.ps1 -MediaType Picture
```

### Non-Recursive Search

Search only in the specified directory (no subdirectories):
```powershell
.\MediaFinder.ps1 -Path "C:\Media" -Recursive $false
```

### Show Detailed Information

Display detailed file information including sizes and dates:
```powershell
.\MediaFinder.ps1 -ShowDetails
```

### Export Results

Export to CSV:
```powershell
.\MediaFinder.ps1 -ExportCSV "results.csv"
```

Export to JSON:
```powershell
.\MediaFinder.ps1 -ExportJSON "results.json"
```

Export with detailed information:
```powershell
.\MediaFinder.ps1 -Path "D:\Media" -ShowDetails -ExportCSV "detailed_results.csv"
```

### Combined Examples

Search for audio files in a specific directory and export to CSV:
```powershell
.\MediaFinder.ps1 -Path "C:\Music" -MediaType Audio -ExportCSV "music_catalog.csv"
```

Search with details and export to both CSV and JSON:
```powershell
.\MediaFinder.ps1 -Path "D:\Media" -ShowDetails -ExportCSV "media.csv" -ExportJSON "media.json"
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Path` | String | Current directory | Directory path to search for media files |
| `-MediaType` | String | "All" | Type of media to search (Audio, Video, Picture, All) |
| `-Recursive` | Boolean | $true | Search subdirectories recursively |
| `-ExportCSV` | String | - | Export results to CSV file at specified path |
| `-ExportJSON` | String | - | Export results to JSON file at specified path |
| `-ShowDetails` | Switch | - | Display detailed information about each file |

## Supported File Types

### Audio Formats
- MP3, WAV, FLAC, AAC, OGG, M4A, WMA, OPUS, AIFF, APE

### Video Formats
- MP4, AVI, MKV, MOV, WMV, FLV, WebM, M4V, MPG, MPEG, 3GP, DivX

### Picture Formats
- JPG, JPEG, PNG, GIF, BMP, TIFF, TIF, SVG, WebP, ICO, RAW, HEIC

## Output Example

```
╔══════════════════════════════════════════════════════════╗
║            MediaFinder - Media File Scanner            ║
╚══════════════════════════════════════════════════════════╝

Searching in: C:\Users\Documents\Media
Media Type: All
Recursive: True

Scanning for media files...

╔══════════════════════════════════════════════════════════╗
║                     Search Results                      ║
╚══════════════════════════════════════════════════════════╝

Search completed in: 2.34 seconds

Total files found: 127
  Audio files:   45
  Video files:   28
  Picture files: 54

Total size: 15.67 GB
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Author

Created by gdelfavero