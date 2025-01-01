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

                # Step 3: Replace image links and ensure URLs are correctly formatted
                for image in images:
                    image_filename = image  # Directly use the matched full filename
                    normalized_image_filename = image_filename.replace(" ", "_")  # Normalize filename
                    markdown_image = f"![Alt Text](/The-Secure-Forge/assets/images/{normalized_image_filename})"  # Add /The-Secure-Forge prefix
                    content = content.replace(f"![]({image_filename})", markdown_image)
                
                    # Copy the image to the static/images directory if it exists
                    image_source = os.path.join(attachments_dir, image_filename.replace('%20', ' '))  # Decode %20 to spaces for local lookup
                    image_dest = os.path.join(static_images_dir, normalized_image_filename)
    
                    if os.path.exists(image_source):
                        shutil.copy(image_source, image_dest)
                       log_info(f"Copied and normalized image: {image_filename} to {image_dest}")
                    else:
                        log_error(f"Image not found: {image_source}")


                    markdown_image = f"![Alt Text](/assets/images/{normalized_image_filename})"
                    content = content.replace(f"![]({image_filename})", markdown_image)


                # Step 5: Write the updated content back to the Markdown file
                with open(filepath, "w", encoding="utf-8") as file:
                    file.write(content)
                log_info(f"Updated content written to: {filename}")
            except Exception as e:
                log_error(f"Error processing file {filename}: {e}")
    log_info("All markdown files processed successfully.")
except Exception as e:
    log_error(f"Script failed: {e}")
