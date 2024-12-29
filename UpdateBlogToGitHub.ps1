# Variables
$blogDirectory = "C:\Users\marka\The-Secure-Forge\_posts"
$imageDirectory = "assets/images"

# Step 1: Find all Markdown files
Write-Host "Scanning Directory: $blogDirectory" -ForegroundColor Cyan
$mdFiles = Get-ChildItem -Path $blogDirectory -Filter *.md -Recurse

# Debugging: Log the number of files found
if ($mdFiles.Count -eq 0) {
    Write-Host "No Markdown files found in the directory." -ForegroundColor Red
    exit 1
} else {
    Write-Host "Found $($mdFiles.Count) Markdown file(s) in the directory:" -ForegroundColor Green
    foreach ($file in $mdFiles) {
        Write-Host " - $($file.FullName)" -ForegroundColor Yellow
    }
}

foreach ($file in $mdFiles) {
    # Read the content
    $content = Get-Content -Path $file.FullName -Raw
    Write-Host "Processing File: $($file.FullName)" -ForegroundColor Cyan
    Write-Host "Original Content:`n$content" -ForegroundColor Yellow

    # Match and log all image paths
    $matches = [regex]::Matches($content, '!\[\]\((Pasted%20image%20.*?\.(png|jpg|jpeg|gif))\)')
    if ($matches.Count -gt 0) {
        Write-Host "Matches Found in File:" -ForegroundColor Green
        foreach ($match in $matches) {
            Write-Host " - Match: $($match.Value)" -ForegroundColor Green
        }
    } else {
        Write-Host "No Matches Found in File." -ForegroundColor Red
    }

    # Replace image paths missing the directory with correct relative paths
    # Use proper syntax for the replacement operation
    $updatedContent = $content -replace '!\[\]\((Pasted%20image%20.*?\.(png|jpg|jpeg|gif))\)', '![Alt Text](/' + $imageDirectory + '/$1)'

    # Log the updated content for debugging
    Write-Host "Updated Content:`n$updatedContent" -ForegroundColor Cyan

    # Write the updated content back to the file if changed
    if ($content -ne $updatedContent) {
        Set-Content -Path $file.FullName -Value $updatedContent
        Write-Host "Updated image paths in $($file.FullName)" -ForegroundColor Green
    } else {
        Write-Host "No Changes Made to $($file.FullName)" -ForegroundColor Yellow
    }
}

# Step 2: Push changes to GitHub
$gitDirectory = "C:\Users\marka\The-Secure-Forge"

# Navigate to the Git Repository
Set-Location $gitDirectory

# Add Changes to Git
git add .

# Commit Changes
$commitMessage = Read-Host "Enter a commit message (or press Enter for default message)"
if ([string]::IsNullOrEmpty($commitMessage)) {
    $commitMessage = "Updated blog posts on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}
git commit -m $commitMessage

if ($LASTEXITCODE -eq 0) {
    # Push to GitHub
    git push origin main
    Write-Host "Changes pushed to GitHub successfully." -ForegroundColor Green
} else {
    Write-Host "Git commit failed. Check for issues." -ForegroundColor Red
}
