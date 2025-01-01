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

                # Step 2: Find all image links in the format ![](Pasted%20image%20<timestamp>.png)
                images = re.findall(r'Pasted%20image%20.*?\.(?:png|jpg|jpeg|gif)', content)

                if not images:
                    log_info(f"No images found in {filename}.")
                    continue

                # Step 4: Normalize filenames, copy the images, and update Markdown references
                for image in images:
                    image_filename = image  # Original filename
                    normalized_image_filename = normalize_filename(image_filename)  # Normalized filename

                    image_source = os.path.join(attachments_dir, image_filename.replace('%20', ' '))
                    image_destination = os.path.join(static_images_dir, normalized_image_filename)

                    if os.path.exists(image_source):
                        shutil.copy(image_source, image_destination)
                        log_info(f"Copied and normalized image: {image_filename} to {image_destination}")
                    else:
                        log_error(f"Image not found: {image_source}")

                    # Update Markdown to reference the normalized name
                    markdown_image = f"![Alt Text](/assets/images/{normalized_image_filename})"
                    content = content.replace(f"![]({image_filename})", markdown_image)
                    content = content.replace(f"![]({image_filename.replace('%20', ' ')})", markdown_image)  # Handle unencoded spaces

                # Step 5: Write the updated content back to the Markdown file
                with open(filepath, "w", encoding="utf-8") as file:
                    file.write(content)
                log_info(f"Updated content written to: {filename}")
            except Exception as e:
                log_error(f"Error processing file {filename}: {e}")
    log_info("All markdown files processed successfully.")
except Exception as e:
    log_error(f"Script failed: {e}")
