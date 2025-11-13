import requests
import base64

IMGBB_API_KEY = "e0ced2c1a8ca604b7780f01b08b00f29"
IMGBB_URL = "https://api.imgbb.com/1/upload"

print("🧪 Testing ImgBB API...")
print("=" * 80)

# Create a tiny test image (1x1 pixel PNG)
test_image_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

try:
    payload = {
        'key': IMGBB_API_KEY,
        'image': test_image_base64,
        'name': 'test_image'
    }
    
    response = requests.post(IMGBB_URL, data=payload, timeout=10)
    
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text[:200]}")
    
    if response.status_code == 200:
        result = response.json()
        if result.get('success'):
            print("\n✅ ImgBB API is WORKING!")
            print("✅ Rate limit has RESET!")
            print("✅ You can upload images NOW!")
        else:
            print("\n❌ API Error:", result.get('error'))
    else:
        print("\n❌ Rate limit still active OR API issue")
        print("⏰ Need to wait more time")
        
except Exception as e:
    print(f"\n❌ Error: {e}")

print("=" * 80)
