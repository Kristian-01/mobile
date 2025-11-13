"""
Test Cloudinary Connection
"""

try:
    import cloudinary
    print("✅ Cloudinary installed")
except:
    print("❌ Cloudinary not installed")
    print("Run: pip install cloudinary")
    exit(1)

# Your credentials
CLOUDINARY_CLOUD_NAME = "dskjwr7g4"
CLOUDINARY_API_KEY = "665786365357986"
CLOUDINARY_API_SECRET = "NMMdgKxtdqvgfRENMtmFgqB8BbM"

print(f"Cloud Name: {CLOUDINARY_CLOUD_NAME}")
print(f"API Key: {CLOUDINARY_API_KEY}")
print(f"API Secret: {CLOUDINARY_API_SECRET[:10]}...")

cloudinary.config(
    cloud_name=CLOUDINARY_CLOUD_NAME,
    api_key=CLOUDINARY_API_KEY,
    api_secret=CLOUDINARY_API_SECRET,
    secure=True
)

print("\n✅ Cloudinary configured successfully!")
print("Ready to upload!")
