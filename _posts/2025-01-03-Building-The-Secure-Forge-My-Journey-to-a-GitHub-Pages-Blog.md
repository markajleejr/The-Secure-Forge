---
layout: post
title: 'Building "The Secure Forge": My Journey to a GitHub Pages Blog'
date: 2025-01-03
categories: Blog, Tech, Cybersecurity, Personal Projects
tags:
  - obsidian
  - cybersecurity
  - automation
---
Creating my GitHub Pages blog, _The Secure Forge_, has been a blend of problem-solving, tech wizardry, and the occasional coffee-fueled night. As a cybersecurity professional on a journey to showcase my skills and passion, I wanted a platform to share insights and ideas. Here’s how I built it—and how you can too.

### The Vision

I envisioned a dynamic, professional blog to reflect my expertise while showing off some technical flair. GitHub Pages felt like the perfect choice: simple hosting, markdown-friendly, and free. Paired with Obsidian for writing and a sprinkle of automation magic, it was the ideal setup.

### The Workflow

The core of my process revolves around three scripts that automate blog creation, update, and image processing:

#### Script 1: `CreateBlogPost.ps1`

This PowerShell script generates a markdown file with preformatted front matter and opens it in Obsidian.
```PowerShell
# Variables
# Set the directory where your blog posts are stored
$blogDirectory = "C:\Path\To\Your\Blog\_posts" # Replace with the path to your blog's _posts directory

# Set the path to the Obsidian executable
$obsidianPath = "C:\Path\To\Obsidian\Obsidian.exe" # Replace with the path to the Obsidian application

# Prompt the user to enter the blog title
$blogTitle = Read-Host "Enter the blog title"

# Generate the current date in yyyy-MM-dd format
$date = Get-Date -Format "yyyy-MM-dd"

# Construct the file name based on the title and date
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
# Replace `tag1` and `tag2` with relevant tags for the blog post
$frontMatter = @"
---
layout: post
title: "$blogTitle"
date: "$date"
categories: blog
tags: [tag1, tag2] # Replace with relevant tags
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
```
#### Script 2: `UpdateBlogToGitHub.ps1`

This handles the heavy lifting: image processing and syncing content to GitHub.
```PowerShell
# Paths to Python script and interpreter
# Replace these paths with the location of your Python interpreter and script
$pythonPath = "C:\Path\To\Python\python.exe" # Example: C:\Python\python.exe
$pythonScript = "C:\Path\To\Your\Project\process_md_images.py" # Example: C:\Projects\process_md_images.py

# Run the Python script
Write-Host "Running Python script to process Markdown files and images..." -ForegroundColor Cyan
$pythonResult = & $pythonPath $pythonScript
Write-Host $pythonResult

# Step 2: Push changes to GitHub
# Replace this path with the location of your Git repository
$gitDirectory = "C:\Path\To\Your\Git\Repository" # Example: C:\Projects\MyBlog

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

```
#### Script 3: `process_md_images.py`

The unsung hero, this Python script normalizes image paths for GitHub compatibility and copies them to the correct directory.
```Pyhton
import os
import re
import shutil

# Paths (replace placeholders with actual paths to your directories)
posts_dir = r"C:\Path\To\Your\Blog\_posts"  # Example: C:\Projects\Blog\_posts
attachments_dir = r"C:\Path\To\Your\Blog\_posts\assets\images"  # Example: C:\Projects\Blog\_posts\assets\images
static_images_dir = r"C:\Path\To\Your\Blog\assets\images"  # Example: C:\Projects\Blog\assets\images

def log_error(message):
    print(f"ERROR: {message}")

def log_info(message):
    print(f"INFO: {message}")

def normalize_filename(filename):
    # Replace spaces with underscores
    return filename.replace(" ", "_").replace("%20", "_")

try:
    # Ensure directories exist
    if not os.path.exists(posts_dir):
        raise FileNotFoundError(f"Posts directory not found: {posts_dir}")
    if not os.path.exists(attachments_dir):
        log_info(f"Attachments directory not found. Creating: {attachments_dir}")
        os.makedirs(attachments_dir)
    if not os.path.exists(static_images_dir):
        log_info(f"Static images directory not found. Creating: {static_images_dir}")
        os.makedirs(static_images_dir)

    log_info(f"Processing markdown files in: {posts_dir}")
    for filename in os.listdir(posts_dir):
        if filename.endswith(".md"):
            filepath = os.path.join(posts_dir, filename)
            log_info(f"Processing file: {filename}")

            try:
                with open(filepath, "r", encoding="utf-8") as file:
                    content = file.read()

                # Step 2: Find all image links in the format ![Alt Text](https://markajleejr.github.io/The-Secure-Forge/assets/images/Pasted_image_<timestamp>.png)
                images = re.findall(r'Pasted%20image%20.*?\.(?:png|jpg|jpeg|gif)', content)

                if not images:
                    log_info(f"No images found in {filename}.")
                    continue

                # Step 3 and Step 4: Replace image links and copy files
                for image in images:
                    normalized_image_filename = normalize_filename(image)
                    markdown_image = f"![Alt Text](https://yourdomain.github.io/Your-Blog/assets/images/{normalized_image_filename})"
                    content = content.replace(f"![]({image})", markdown_image)

                    image_source = os.path.join(attachments_dir, image.replace('%20', ' '))  # Decode %20 to spaces for local lookup
                    image_dest = os.path.join(static_images_dir, normalized_image_filename)

                    if os.path.exists(image_source):
                        shutil.copy(image_source, image_dest)
                        log_info(f"Copied and normalized image: {image} to {image_dest}")
                    else:
                        log_error(f"Image not found: {image_source}")

                # Step 5: Write the updated content back to the Markdown file
                with open(filepath, "w", encoding="utf-8") as file:
                    file.write(content)
                log_info(f"Updated content written to: {filename}")

            except Exception as e:
                log_error(f"Error processing file {filename}: {e}")
    log_info("All markdown files processed successfully.")
except Exception as e:
    log_error(f"Script failed: {e}")

```
### Lessons Learned

1. **Automate Everything:** These scripts save time and ensure consistency.
2. **Keep It Organized:** Structure matters when dealing with multiple tools.
3. **Iterate Quickly:** Small tweaks lead to big improvements.

### How You Can Build Your Blog

1. **Set Up GitHub Pages:** Create a repo and enable GitHub Pages in settings.
2. **Use Obsidian:** Its markdown capabilities are perfect for writing posts.
3. **Automate:** Adapt my scripts to your workflow by replacing paths and directories.
4. **Iterate and Improve:** Experiment until your system clicks.

---

### Final Thoughts

This project is more than a blog; it’s a statement of my capabilities as a cybersecurity expert and tech enthusiast. If you’re considering building your site, don’t overthink—start!

Let’s forge ahead together. 🚀

**Hashtags:** #CyberSecurity #Automation #GitHubPages #Obsidian #Markdown