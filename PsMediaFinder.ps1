function Find-MediaFiles {
    <#
    .SYNOPSIS
        Searches for media files (audio, video, pictures, and vaults) in a specified directory.

    .DESCRIPTION
        This function searches for media files in a specified directory.
        It supports recursive search, filtering by media type, and various output formats.

    .PARAMETER Path
        The directory path to search for media files. Defaults to the current directory.

    .PARAMETER MediaType
        The type of media to search for. Valid values: Audio, Video, Picture, Vaults, All
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
        Find-MediaFiles
        Searches for all media files in the current directory and subdirectories.

    .EXAMPLE
        Find-MediaFiles -Path "C:\Users\Documents" -MediaType Audio
        Searches for audio files only in the specified directory.

    .EXAMPLE
        Find-MediaFiles -Path "D:\Media" -Recursive $false
        Searches for media files only in the specified directory (no subdirectories).

    .EXAMPLE
        Find-MediaFiles -Path "C:\Media" -ExportCSV "media_results.csv" -ShowDetails
        Searches for all media files and exports detailed results to CSV.

    .OUTPUTS
        PSCustomObject[]
        Returns an array of custom objects containing file information.

    .NOTES
        Author: gdelfavero
        Version: 2.0
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = (Get-Location).Path,
        
        [Parameter()]
        [ValidateSet("Audio", "Video", "Picture", "Vaults", "All")]
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
    $vaultExtensions = @('.kdbx', '.1pif', '.agilekeychain', '.opvault', '.bw', '.enpass', '.psafe3', '.kdb', '.keepass', '.hc', '.tc')

    # Helper function to get media files
    function Get-MediaFilesInternal {
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

    # Helper function to format file size
    function Format-FileSizeInternal {
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
        return
    }

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          PsMediaFinder - Media File Scanner            ║" -ForegroundColor Cyan
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
    "Vaults" { $searchExtensions = $vaultExtensions }
    "All" { $searchExtensions = $audioExtensions + $videoExtensions + $pictureExtensions + $vaultExtensions }
}

    # Search for media files
    Write-Host "Scanning for media files..." -ForegroundColor Green
    $startTime = Get-Date

    $allMediaFiles = Get-MediaFilesInternal -SearchPath $Path -Extensions $searchExtensions -RecursiveSearch $Recursive

    $endTime = Get-Date
    $duration = $endTime - $startTime

    # Process and categorize results
    $results = @()
    $audioFiles = @()
    $videoFiles = @()
    $pictureFiles = @()
    $vaultFiles = @()

    foreach ($file in $allMediaFiles) {
        $fileInfo = [PSCustomObject]@{
            Name = $file.Name
            Path = $file.FullName
            Directory = $file.DirectoryName
            Extension = $file.Extension.ToLower()
            Size = $file.Length
            SizeFormatted = Format-FileSizeInternal -Size $file.Length
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
        } elseif ($vaultExtensions -contains $file.Extension.ToLower()) {
            $fileInfo.Type = "Vaults"
            $vaultFiles += $fileInfo
        }
        
        $results += $fileInfo
    }

    # Display summary
    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                     Search Results                      ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

    Write-Host "Search completed in: $($duration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor Cyan
    Write-Host "`nTotal files found: $($results.Count)" -ForegroundColor Whitehite

    if ($MediaType -eq "All" -or $MediaType -eq "Audio") {
        Write-Host "  Audio files:   $($audioFiles.Count)" -ForegroundColor Magenta
    }
    if ($MediaType -eq "All" -or $MediaType -eq "Video") {
        Write-Host "  Video files:   $($videoFiles.Count)" -ForegroundColor Blue
    }
    if ($MediaType -eq "All" -or $MediaType -eq "Picture") {
        Write-Host "  Picture files: $($pictureFiles.Count)" -ForegroundColor Yellow
    }
    if ($MediaType -eq "All" -or $MediaType -eq "Vaults") {
        Write-Host "  Vault files:   $($vaultFiles.Count)" -ForegroundColor Red
    }

    # Calculate total size
    $totalSize = ($results | Measure-Object -Property Size -Sum).Sum
    Write-Host "`nTotal size: $(Format-FileSizeInternal -Size $totalSize)" -ForegroundColor WhitedColor White

    # Display detailed results
    if ($results.Count -gt 0) {
            Write-Host "`n" + ("─" * 80) -ForegroundColor Gray
        
        if ($ShowDetails) {
            Write-Host "`nDetailed File List:" -ForegroundColor Cyan
            Write-Host ("─" * 80) -ForegroundColor Gray
            
            foreach ($file in $results | Sort-Object Type, Name) {e) {
                $typeColor = switch ($file.Type) {
                    "Audio" { "Magenta" }
                    "Video" { "Blue" }
                    "Picture" { "Yellow" }
                    "Vaults" { "Red" }
                    default { "White" }
                }
                
                Write-Host "`n[$($file.Type)]" -ForegroundColor $typeColor -NoNewline
                Write-Host " $($file.Name)" -ForegroundColor White
                Write-Host "  Path:     $($file.Path)" -ForegroundColor Gray
                Write-Host "  Size:     $($file.SizeFormatted)" -ForegroundColor Gray
                Write-Host "  Created:  $($file.Created.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
                Write-Host "  Modified: $($file.Modified.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
            }
        } else {se {
            Write-Host "`nFile List (use -ShowDetails for more information):" -ForegroundColor Cyan
            Write-Host ("─" * 80) -ForegroundColor Gray
            
            foreach ($file in $results | Sort-Object Type, Name) {
                $typeColor = switch ($file.Type) {
                    "Audio" { "Magenta" }
                    "Video" { "Blue" }
                    "Picture" { "Yellow" }
                    "Vaults" { "Red" }
                    default { "White" }
                }
                
                Write-Host "[$($file.Type.PadRight(7))]" -ForegroundColor $typeColor -NoNewline
                Write-Host " $($file.Name.PadRight(40))" -ForegroundColor White -NoNewline
                Write-Host " $($file.SizeFormatted)" -ForegroundColor Gray
            }
        }
        
        Write-Host "`n" + ("─" * 80) -ForegroundColor Gray
    }   }

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
    }   }

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
            Write-Host "  ($(Format-FileSizeInternal -Size $stat.TotalSize))" -ForegroundColor DarkGray
        }
    }

    Write-Host ""

    # Return results
    return $results
}

# If script is run directly (not dot-sourced), execute the function
if ($MyInvocation.InvocationName -ne '.') {
    Find-MediaFiles @PSBoundParameters
}
