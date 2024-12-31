import os
import re
import shutil

# Paths (using raw strings to handle Windows backslashes correctly)
posts_dir = r"C:\Users\marka\The-Secure-Forge\_posts"
attachments_dir = r"C:\Users\marka\The-Secure-Forge\_posts\assets\images"
static_images_dir = r"C:\Users\marka\The-Secure-Forge\assets\images"

def log_error(message):
    print(f"ERROR: {message}")

def log_info(message):
    print(f"INFO: {message}")

try:
    # Ensure all directories exist
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

                # Step 2: Find all image links in the format ![](Pasted%20image%20<timestamp>.png)
                images = re.findall(r'Pasted%20image%20.*?\.(?:png|jpg|jpeg|gif)', content)

                
                if not images:
                    log_info(f"No images found in {filename}.")
                    continue
                
                # Step 3: Replace image links and ensure URLs are correctly formatted
                for image in images:
                    image_filename = image  # Directly use the matched full filename
                    markdown_image = f"![Alt Text](/assets/images/{image_filename.replace(' ', '%20')})"
                    content = content.replace(f"![]({image_filename})", markdown_image)
                
                    # Step 4: Copy the image to the static/images directory if it exists
                    image_source = os.path.join(attachments_dir, image_filename.replace('%20', ' '))
                    if os.path.exists(image_source):
                        shutil.copy(image_source, static_images_dir)
                        log_info(f"Copied image: {image_filename} to {static_images_dir}")
                    else:
                        log_error(f"Image not found: {image_source}")
                
                # Step 5: Write the updated content back to the markdown file
                with open(filepath, "w", encoding="utf-8") as file:
                    file.write(content)
                log_info(f"Updated content written to: {filename}")
            except Exception as e:
                log_error(f"Error processing file {filename}: {e}")
    log_info("All markdown files processed successfully.")
except Exception as e:
    log_error(f"Script failed: {e}")
