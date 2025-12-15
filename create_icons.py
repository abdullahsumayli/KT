from PIL import Image
import os

# Open the logo
logo_path = r"d:\KT\frontend\kitchentech_app\assets\images\logo.png"
logo = Image.open(logo_path)

# Output directory
output_dir = r"d:\KT\frontend\kitchentech_app\web"
icons_dir = os.path.join(output_dir, "icons")

# Create icons directory if not exists
os.makedirs(icons_dir, exist_ok=True)

# Sizes needed
sizes = {
    "favicon.png": 32,
    "icons/Icon-192.png": 192,
    "icons/Icon-512.png": 512,
    "icons/Icon-maskable-192.png": 192,
    "icons/Icon-maskable-512.png": 512,
}

print("Creating icons...")
for filename, size in sizes.items():
    output_path = os.path.join(output_dir, filename)
    
    # Resize logo
    resized = logo.copy()
    resized.thumbnail((size, size), Image.Resampling.LANCZOS)
    
    # Create new image with white background (in case logo has transparency)
    new_img = Image.new("RGB", (size, size), (255, 255, 255))
    
    # Paste logo in center
    if resized.mode == 'RGBA':
        new_img.paste(resized, ((size - resized.width) // 2, (size - resized.height) // 2), resized)
    else:
        new_img.paste(resized, ((size - resized.width) // 2, (size - resized.height) // 2))
    
    # Save
    new_img.save(output_path, "PNG", optimize=True)
    print(f"Created: {filename} ({size}x{size})")

print("\nDone! All icons created.")
