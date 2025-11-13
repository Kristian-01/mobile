import os
import shutil

print("📦 Preparing files for Netlify deployment...")
print("=" * 80)

# Source and destination
SOURCE = r'c:\Projects\capstone\website\designnijess - Copy - Copy\product_images'
DEST = r'c:\Projects\capstone\mobile3\netlify_deploy'

# Create clean deploy folder
if os.path.exists(DEST):
    shutil.rmtree(DEST)
    print("  🗑️  Cleaned old deploy folder")

os.makedirs(DEST)
print(f"  ✅ Created: {DEST}")

# Copy product_images folder
dest_images = os.path.join(DEST, 'product_images')
shutil.copytree(SOURCE, dest_images)
print(f"  ✅ Copied images to deploy folder")

# Create index.html (required by Netlify)
index_html = os.path.join(DEST, 'index.html')
with open(index_html, 'w', encoding='utf-8') as f:
    f.write('''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Images</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        h1 {
            color: #333;
        }
        p {
            color: #666;
            line-height: 1.6;
        }
        .status {
            display: inline-block;
            background: #4CAF50;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🖼️ Product Images Server</h1>
        <div class="status">✅ Active</div>
        <p>This site hosts product images for the mobile app.</p>
        <p>Images are stored in the <code>/product_images</code> directory.</p>
    </div>
</body>
</html>
''')
print(f"  ✅ Created index.html")

# Create _redirects file for proper routing
redirects_file = os.path.join(DEST, '_redirects')
with open(redirects_file, 'w') as f:
    f.write('# Redirect rules\n')
    f.write('/product_images/*  /product_images/:splat  200\n')
print(f"  ✅ Created _redirects")

# Create netlify.toml for configuration
toml_file = os.path.join(DEST, 'netlify.toml')
with open(toml_file, 'w') as f:
    f.write('''[build]
  publish = "."

[[headers]]
  for = "/*"
  [headers.values]
    Access-Control-Allow-Origin = "*"
    Cache-Control = "public, max-age=31536000"
''')
print(f"  ✅ Created netlify.toml")

# Count files
total_files = 0
for root, dirs, files in os.walk(dest_images):
    total_files += len(files)

print("\n" + "=" * 80)
print("✅ PREPARATION COMPLETE!")
print("=" * 80)
print(f"📁 Deploy folder: {DEST}")
print(f"🖼️  Total images: {total_files}")
print("=" * 80)
print("\n📤 READY TO DEPLOY TO NETLIFY!")
print("=" * 80)
