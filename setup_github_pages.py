import os
import subprocess

print("🐙 Setting up GitHub Pages for images...")
print("=" * 80)

DEPLOY_FOLDER = r'c:\Projects\capstone\mobile3\netlify_deploy'
os.chdir(DEPLOY_FOLDER)

print("\n📋 INSTRUCTIONS:")
print("=" * 80)
print("\nOption 1: Use GitHub Desktop (EASIEST)")
print("-" * 80)
print("1. Download GitHub Desktop: https://desktop.github.com/")
print("2. Sign in with GitHub account")
print("3. Click 'Add' → 'Add Existing Repository'")
print(f"4. Browse to: {DEPLOY_FOLDER}")
print("5. Publish repository (make it PUBLIC)")
print("6. Your images will be at:")
print("   https://[username].github.io/[repo-name]/product_images/")
print()

print("\nOption 2: Use Git Commands")
print("-" * 80)
print("Run these commands:")
print()
print(f"cd {DEPLOY_FOLDER}")
print("git init")
print("git add .")
print('git commit -m "Add product images"')
print("git branch -M main")
print("git remote add origin https://github.com/[username]/[repo-name].git")
print("git push -u origin main")
print()

print("\nOption 3: Use ImgBB (If quota reset)")
print("-" * 80)
print("Wait 24 hours for ImgBB quota to reset")
print("Then run: python upload_remaining_images.py")
print()

print("=" * 80)
print("\n⚠️  EASIEST RIGHT NOW:")
print("=" * 80)
print("\nSince Netlify failed and files are large,")
print("Let me create a simpler solution using FREE CDN...")
print("=" * 80)
