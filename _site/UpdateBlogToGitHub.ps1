# Paths to Python script and interpreter
$pythonPath = "C:\Users\marka\AppData\Local\Programs\Python\Python313\python.exe"
$pythonScript = "C:\Users\marka\The-Secure-Forge\process_md_images.py"

# Define expected repository and branch
$expectedRepository = "markajleejr/The-Secure-Forge.git"
$expectedBranch = "main"

# Run the Python script
Write-Host "Running Python script to process Markdown files and images..." -ForegroundColor Cyan
$pythonResult = & $pythonPath $pythonScript
Write-Host $pythonResult

# Step 2: Push changes to GitHub
$gitDirectory = "C:\Users\marka\The-Secure-Forge"

# Navigate to the Git Repository
Set-Location $gitDirectory

# Validate and correct repository
Write-Host "Checking repository and branch..." -ForegroundColor Yellow
$currentRepository = git remote get-url origin
if ($currentRepository -ne "https://github.com/$expectedRepository") {
    Write-Host "Current repository ($currentRepository) does not match expected repository ($expectedRepository)." -ForegroundColor Yellow
    Write-Host "Updating repository URL..." -ForegroundColor Cyan
    git remote set-url origin "https://github.com/$expectedRepository"
	if ($currentRepository -ne "https://github.com/$expectedRepository") {
		Write-Host "Error: Failed to update repository to ($expectedRepository). It is still set too ($currentRepository)." -ForegroundColor Red
		exit 1
	} else{
		Write-Host "Repository URL updated successfully." -ForegroundColor Green
	}
}

# Validate and correct branch
$currentBranch = git branch --show-current
if ($currentBranch -ne $expectedBranch) {
    Write-Host "Current branch ($currentBranch) does not match expected branch ($expectedBranch)." -ForegroundColor Yellow
    Write-Host "Switching to the correct branch..." -ForegroundColor Cyan
    git fetch origin
    git checkout $expectedBranch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to update repository to ($expectedBranch). It is still set too ($currentBranch)." -ForegroundColor Red
		exit 1
    } else {
		Write-Host "Switched to branch $expectedBranch successfully." -ForegroundColor Green
	}
}

# Pull changes from remote to ensure synchronization
Write-Host "Synchronizing with the remote branch..." -ForegroundColor Cyan
git pull origin $expectedBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to pull changes. Resolve conflicts manually if necessary." -ForegroundColor Red
    exit 1
}

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
    git push origin $expectedBranch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Push failed. Resolve conflicts and try again." -ForegroundColor Red
        exit 1
    }
    Write-Host "Changes pushed to GitHub successfully." -ForegroundColor Green
} else {
    Write-Host "Git commit failed. Check for issues." -ForegroundColor Red
}
