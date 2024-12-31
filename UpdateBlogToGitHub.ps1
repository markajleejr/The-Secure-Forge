# Paths to Python script and interpreter
$pythonPath = "C:\Users\marka\AppData\Local\Programs\Python\Python313\python.exe"
$pythonScript = "C:\Users\marka\The-Secure-Forge\process_md_images.py"

# Run the Python script
Write-Host "Running Python script to process Markdown files and images..." -ForegroundColor Cyan
$pythonResult = & $pythonPath $pythonScript
Write-Host $pythonResult

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
