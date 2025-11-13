"""
Script to delete all wishlist-related files and folders
Run this from the mobile3 directory: python delete_wishlist_files.py
"""
import os
import shutil

def delete_path(path):
    """Delete a file or directory"""
    if os.path.exists(path):
        if os.path.isdir(path):
            shutil.rmtree(path)
            print(f"✅ Deleted folder: {path}")
        else:
            os.remove(path)
            print(f"✅ Deleted file: {path}")
    else:
        print(f"⚠️  Not found (already deleted?): {path}")

def main():
    print("🗑️  Deleting Wishlist/Favorites Files")
    print("=" * 60)
    
    # Paths to delete
    paths_to_delete = [
        'lib/features/wishlist',
        'lib/features/favourites',
        'lib/data/repository/favorites_repository',
        'lib/features/products/screens/favourite_icon.dart',
    ]
    
    print("\nThe following files/folders will be deleted:\n")
    for path in paths_to_delete:
        print(f"  - {path}")
    
    print("\n" + "=" * 60)
    confirm = input("\nAre you sure you want to delete these? (yes/no): ")
    
    if confirm.lower() in ['yes', 'y']:
        print("\n🗑️  Deleting files...\n")
        for path in paths_to_delete:
            delete_path(path)
        
        print("\n" + "=" * 60)
        print("✨ All wishlist files deleted successfully!")
        print("=" * 60)
        print("\n💡 Next steps:")
        print("   1. Hot restart your Flutter app (Shift + R)")
        print("   2. Test that the app works without errors")
        print("   3. If everything works, commit the changes")
    else:
        print("\n❌ Deletion cancelled. Files remain unchanged.")

if __name__ == '__main__':
    main()
