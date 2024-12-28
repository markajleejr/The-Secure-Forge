# Variables
$gitDirectory = "C:\Users\marka\The-Secure-Forge"

# Navigate to the Git Repository
Set-Location $gitDirectory

# Step 1: Add Changes to Git
git add .

# Step 2: Commit Changes
$commitMessage = Read-Host "Enter a commit message (or press Enter for default message)"
if ([string]::IsNullOrEmpty($commitMessage)) {
    $commitMessage = "Updated blog posts on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}
git commit -m $commitMessage

if ($LASTEXITCODE -eq 0) {
    # Step 3: Push to GitHub
    git push origin main
    Write-Host "Changes pushed to GitHub successfully." -ForegroundColor Green
} else {
    Write-Host "Git commit failed. Check for issues." -ForegroundColor Red
}
