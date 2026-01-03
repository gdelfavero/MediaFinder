<#
.SYNOPSIS
    MediaFinder - A PowerShell-based audio, video, and picture file finder.

.DESCRIPTION
    This script searches for media files (audio, video, and pictures) in a specified directory.
    It supports recursive search, filtering by media type, and various output formats.

.PARAMETER Path
    The directory path to search for media files. Defaults to the current directory.

.PARAMETER MediaType
    The type of media to search for. Valid values: Audio, Video, Picture, All
    Default: All

.PARAMETER Recursive
    Search subdirectories recursively. Default: $true

.PARAMETER ExportCSV
    Export results to a CSV file at the specified path.

.PARAMETER ExportJSON
    Export results to a JSON file at the specified path.

.PARAMETER ShowDetails
    Display detailed information about each file (size, creation date, modification date).

.EXAMPLE
    .\MediaFinder.ps1
    Searches for all media files in the current directory and subdirectories.

.EXAMPLE
    .\MediaFinder.ps1 -Path "C:\Users\Documents" -MediaType Audio
    Searches for audio files only in the specified directory.

.EXAMPLE
    .\MediaFinder.ps1 -Path "D:\Media" -Recursive $false
    Searches for media files only in the specified directory (no subdirectories).

.EXAMPLE
    .\MediaFinder.ps1 -Path "C:\Media" -ExportCSV "media_results.csv" -ShowDetails
    Searches for all media files and exports detailed results to CSV.

.NOTES
    Author: MediaFinder
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path = (Get-Location).Path,
    
    [Parameter()]
    [ValidateSet("Audio", "Video", "Picture", "All")]
    [string]$MediaType = "All",
    
    [Parameter()]
    [bool]$Recursive = $true,
    
    [Parameter()]
    [string]$ExportCSV,
    
    [Parameter()]
    [string]$ExportJSON,
    
    [Parameter()]
    [switch]$ShowDetails
)

# Define media file extensions
$audioExtensions = @('.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a', '.wma', '.opus', '.aiff', '.ape')
$videoExtensions = @('.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp', '.divx')
$pictureExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.tif', '.svg', '.webp', '.ico', '.raw', '.heic')

# Function to get media files
function Get-MediaFiles {
    param(
        [string]$SearchPath,
        [string[]]$Extensions,
        [bool]$RecursiveSearch
    )
    
    $files = @()
    
    try {
        if ($RecursiveSearch) {
            $files = Get-ChildItem -Path $SearchPath -File -Recurse -ErrorAction SilentlyContinue | 
                     Where-Object { $Extensions -contains $_.Extension.ToLower() }
        } else {
            $files = Get-ChildItem -Path $SearchPath -File -ErrorAction SilentlyContinue | 
                     Where-Object { $Extensions -contains $_.Extension.ToLower() }
        }
    } catch {
        Write-Warning "Error accessing path '$SearchPath': $_"
    }
    
    return $files
}

# Function to format file size
function Format-FileSize {
    param([long]$Size)
    
    if ($Size -gt 1GB) {
        return "{0:N2} GB" -f ($Size / 1GB)
    } elseif ($Size -gt 1MB) {
        return "{0:N2} MB" -f ($Size / 1MB)
    } elseif ($Size -gt 1KB) {
        return "{0:N2} KB" -f ($Size / 1KB)
    } else {
        return "{0} bytes" -f $Size
    }
}

# Validate path
if (-not (Test-Path -Path $Path)) {
    Write-Error "The specified path '$Path' does not exist."
    exit 1
}

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║            MediaFinder - Media File Scanner            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Searching in: $Path" -ForegroundColor Yellow
Write-Host "Media Type: $MediaType" -ForegroundColor Yellow
Write-Host "Recursive: $Recursive`n" -ForegroundColor Yellow

# Determine which extensions to search for
$searchExtensions = @()
switch ($MediaType) {
    "Audio" { $searchExtensions = $audioExtensions }
    "Video" { $searchExtensions = $videoExtensions }
    "Picture" { $searchExtensions = $pictureExtensions }
    "All" { $searchExtensions = $audioExtensions + $videoExtensions + $pictureExtensions }
}

# Search for media files
Write-Host "Scanning for media files..." -ForegroundColor Green
$startTime = Get-Date

$allMediaFiles = Get-MediaFiles -SearchPath $Path -Extensions $searchExtensions -RecursiveSearch $Recursive

$endTime = Get-Date
$duration = $endTime - $startTime

# Process and categorize results
$results = @()
$audioFiles = @()
$videoFiles = @()
$pictureFiles = @()

foreach ($file in $allMediaFiles) {
    $fileInfo = [PSCustomObject]@{
        Name = $file.Name
        Path = $file.FullName
        Directory = $file.DirectoryName
        Extension = $file.Extension.ToLower()
        Size = $file.Length
        SizeFormatted = Format-FileSize -Size $file.Length
        Created = $file.CreationTime
        Modified = $file.LastWriteTime
        Type = ""
    }
    
    # Determine file type
    if ($audioExtensions -contains $file.Extension.ToLower()) {
        $fileInfo.Type = "Audio"
        $audioFiles += $fileInfo
    } elseif ($videoExtensions -contains $file.Extension.ToLower()) {
        $fileInfo.Type = "Video"
        $videoFiles += $fileInfo
    } elseif ($pictureExtensions -contains $file.Extension.ToLower()) {
        $fileInfo.Type = "Picture"
        $pictureFiles += $fileInfo
    }
    
    $results += $fileInfo
}

# Display summary
Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                     Search Results                      ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "Search completed in: $($duration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor Cyan
Write-Host "`nTotal files found: $($results.Count)" -ForegroundColor White

if ($MediaType -eq "All" -or $MediaType -eq "Audio") {
    Write-Host "  Audio files:   $($audioFiles.Count)" -ForegroundColor Magenta
}
if ($MediaType -eq "All" -or $MediaType -eq "Video") {
    Write-Host "  Video files:   $($videoFiles.Count)" -ForegroundColor Blue
}
if ($MediaType -eq "All" -or $MediaType -eq "Picture") {
    Write-Host "  Picture files: $($pictureFiles.Count)" -ForegroundColor Yellow
}

# Calculate total size
$totalSize = ($results | Measure-Object -Property Size -Sum).Sum
Write-Host "`nTotal size: $(Format-FileSize -Size $totalSize)" -ForegroundColor White

# Display detailed results
if ($results.Count -gt 0) {
    Write-Host "`n" + ("─" * 80) -ForegroundColor Gray
    
    if ($ShowDetails) {
        Write-Host "`nDetailed File List:" -ForegroundColor Cyan
        Write-Host ("─" * 80) -ForegroundColor Gray
        
        foreach ($file in $results | Sort-Object Type, Name) {
            $typeColor = switch ($file.Type) {
                "Audio" { "Magenta" }
                "Video" { "Blue" }
                "Picture" { "Yellow" }
                default { "White" }
            }
            
            Write-Host "`n[$($file.Type)]" -ForegroundColor $typeColor -NoNewline
            Write-Host " $($file.Name)" -ForegroundColor White
            Write-Host "  Path:     $($file.Path)" -ForegroundColor Gray
            Write-Host "  Size:     $($file.SizeFormatted)" -ForegroundColor Gray
            Write-Host "  Created:  $($file.Created.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
            Write-Host "  Modified: $($file.Modified.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
        }
    } else {
        Write-Host "`nFile List (use -ShowDetails for more information):" -ForegroundColor Cyan
        Write-Host ("─" * 80) -ForegroundColor Gray
        
        foreach ($file in $results | Sort-Object Type, Name) {
            $typeColor = switch ($file.Type) {
                "Audio" { "Magenta" }
                "Video" { "Blue" }
                "Picture" { "Yellow" }
                default { "White" }
            }
            
            Write-Host "[$($file.Type.PadRight(7))]" -ForegroundColor $typeColor -NoNewline
            Write-Host " $($file.Name.PadRight(40))" -ForegroundColor White -NoNewline
            Write-Host " $($file.SizeFormatted)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n" + ("─" * 80) -ForegroundColor Gray
}

# Export results to CSV
if ($ExportCSV) {
    try {
        $results | Select-Object Name, Type, Path, Directory, Extension, SizeFormatted, Created, Modified | 
            Export-Csv -Path $ExportCSV -NoTypeInformation -Encoding UTF8
        Write-Host "`n[SUCCESS] Results exported to CSV: $ExportCSV" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to export to CSV: $_"
    }
}

# Export results to JSON
if ($ExportJSON) {
    try {
        $results | ConvertTo-Json -Depth 3 | Out-File -FilePath $ExportJSON -Encoding UTF8
        Write-Host "`n[SUCCESS] Results exported to JSON: $ExportJSON" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to export to JSON: $_"
    }
}

# Display extension breakdown
if ($results.Count -gt 0) {
    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                  Extension Breakdown                    ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    $extensionStats = $results | Group-Object Extension | 
        Select-Object @{Name='Extension';Expression={$_.Name}}, 
                      @{Name='Count';Expression={$_.Count}},
                      @{Name='TotalSize';Expression={($_.Group | Measure-Object -Property Size -Sum).Sum}} |
        Sort-Object Count -Descending
    
    foreach ($stat in $extensionStats) {
        Write-Host "  $($stat.Extension.PadRight(10))" -ForegroundColor White -NoNewline
        Write-Host " $($stat.Count.ToString().PadLeft(5)) files" -ForegroundColor Gray -NoNewline
        Write-Host "  ($(Format-FileSize -Size $stat.TotalSize))" -ForegroundColor DarkGray
    }
}

Write-Host ""
