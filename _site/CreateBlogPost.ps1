# Variables
$blogDirectory = "C:\Users\marka\The-Secure-Forge\_posts"
$obsidianPath = "C:\Program Files\Obsidian\Obsidian.exe"
$blogTitle = Read-Host "Enter the blog title"
$date = Get-Date -Format "yyyy-MM-dd"
$filename = "$blogDirectory\$date-$($blogTitle -replace '\s', '-').md"

# Step 1: Create the .md File
if (Test-Path $filename) {
    Write-Host "File $filename already exists. Exiting." -ForegroundColor Yellow
    exit 1
} else {
    New-Item -Path $filename -ItemType File -Force | Out-Null
    Write-Host "File $filename created successfully." -ForegroundColor Green
}

# Step 2: Populate the .md File with Template
$frontMatter = @"
---
title: "$blogTitle"
description: "Add a brief description of the post here."
author: Mark A J Lee II
date: "$date"
categories: [blog]
tags: [tag1, tag2] # Replace with relevant tags
pin: false
media_subpath: '/posts/$fileDate'
---
"@
Set-Content -Path $filename -Value $frontMatter
Write-Host "Template added to $filename successfully." -ForegroundColor Green

# Step 3: Open the File in Obsidian
if (Test-Path $obsidianPath) {
    Start-Process -FilePath $obsidianPath -ArgumentList $blogDirectory
    Write-Host "Opened Obsidian. Select the file to edit: $filename" -ForegroundColor Green
} else {
    Write-Host "Obsidian not found at $obsidianPath. Please check the path." -ForegroundColor Red
}
