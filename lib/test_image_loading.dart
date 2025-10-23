// Test if network images work
// Run: flutter run lib/test_image_loading.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const ImageTestApp());
}

class ImageTestApp extends StatelessWidget {
  const ImageTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Image Loading Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Testing Network Image Loading:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              
              // Test Image 1
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2)),
                child: Image.network(
                  'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=300',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('ERROR: $error');
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 50),
                          Text('Failed to load', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('If you see image above = Internet works ✅'),
              const Text('If you see error icon = Internet blocked ❌'),
            ],
          ),
        ),
      ),
    );
  }
}
