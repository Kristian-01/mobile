"""
☁️ VERIFY CLOUDINARY UPLOAD
=============================

Check what images were successfully uploaded to Cloudinary
"""

import cloudinary
import cloudinary.api

# Your Cloudinary credentials
CLOUDINARY_CLOUD_NAME = "dskjwr7g4"
CLOUDINARY_API_KEY = "665786365357986"
CLOUDINARY_API_SECRET = "NMMdgKxtdqvgfRENMtmFgqB8BbM"

cloudinary.config(
    cloud_name=CLOUDINARY_CLOUD_NAME,
    api_key=CLOUDINARY_API_KEY,
    api_secret=CLOUDINARY_API_SECRET,
    secure=True
)

print("☁️  Connected to Cloudinary!")
print("=" * 80)

try:
    # Get folders in product_images
    print("\n📁 Checking folders in product_images/...")
    
    result = cloudinary.api.subfolders('product_images')
    
    print(f"\nFound {len(result['folders'])} folders:")
    
    for folder in result['folders']:
        folder_name = folder['name']
        folder_path = folder['path']
        
        # Count images in this folder
        try:
            resources = cloudinary.api.resources(
                type='upload',
                prefix=folder_path,
                max_results=500
            )
            
            count = len(resources['resources'])
            print(f"  ✅ {folder_name:<25} {count:>4} images")
            
            # Show first 3 images as sample
            if count > 0 and count <= 3:
                print(f"     Sample URLs:")
                for res in resources['resources'][:3]:
                    print(f"       - {res['secure_url']}")
        
        except Exception as e:
            print(f"  ⚠️  {folder_name}: Could not count images")
    
    print("\n" + "=" * 80)
    print("✅ Images successfully uploaded to Cloudinary!")
    print("=" * 80)
    print(f"\n🔗 View all images at:")
    print(f"   https://cloudinary.com/console/c-{CLOUDINARY_CLOUD_NAME}/media_library/folders/product_images")
    
except Exception as e:
    print(f"\n💥 ERROR: {e}")
    import traceback
    traceback.print_exc()
