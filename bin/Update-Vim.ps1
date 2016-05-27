$vimDownloadPath = Join-Path $env:temp "complete-x86.7z"

if (Test-Path $vimDownloadPath) {
    Write-Output "Found previous downloaded vim at '$vimDownloadPath'. Deleting it."
    Remove-Item -Force $vimDownloadPath
}

Write-Output "Downloading latest vim package..."
(New-Object System.Net.WebClient).DownloadFile("http://tuxproject.de/projects/vim/complete-x86.7z", "$env:temp\complete-x86.7z")

Write-Output "Extract package..."
$sevenZipPath = $(where.exe 7z.exe)
& "$sevenZipPath" x "$env:temp\complete-x86.7z" -o"$env:SystemDrive\Program Files (x86)\vim\vim74\" -aoa

Write-Output "We're done."
