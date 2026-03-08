import 'package:flutter/material.dart';

class MockGalleryScreen extends StatefulWidget {
  const MockGalleryScreen({super.key});

  @override
  State<MockGalleryScreen> createState() => _MockGalleryScreenState();
}

class _MockGalleryScreenState extends State<MockGalleryScreen> {
  // Simulate a list of 12 photos, initially none are locked
  final List<bool> _lockedStatus = List.generate(12, (index) => false);

  void _showLockOptions(BuildContext context, int index) {
    const Color beige = Color(0xFFE8E4C9);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131A2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _lockedStatus[index]
                    ? ListTile(
                        leading: const Icon(Icons.lock_open, color: beige),
                        title: const Text(
                          'Unlock this image / Déverrouiller cette image',
                          style: TextStyle(color: beige),
                        ),
                        onTap: () {
                          setState(() => _lockedStatus[index] = false);
                          Navigator.pop(context);
                        },
                      )
                    : ListTile(
                        leading: const Icon(Icons.lock, color: beige),
                        title: const Text(
                          'Lock this image / Verrouiller cette image',
                          style: TextStyle(color: beige, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          setState(() => _lockedStatus[index] = true);
                          Navigator.pop(context);
                        },
                      ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.white54),
                  title: const Text(
                    'Cancel / Annuler',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color beige = Color(0xFFE8E4C9);
    const Color nightBlue = Color(0xFF0B1021);

    return Scaffold(
      backgroundColor: nightBlue,
      appBar: AppBar(
        title: const Text(
          'My Photos Demo',
          style: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 1.2),
        ),
        backgroundColor: nightBlue,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Long press a photo to lock it.\nFaites un appui long pour verrouiller.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: beige.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _lockedStatus.length,
                itemBuilder: (context, index) {
                  final isLocked = _lockedStatus[index];

                  return GestureDetector(
                    onLongPress: () => _showLockOptions(context, index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isLocked ? nightBlue : const Color(0xFF131A2D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLocked ? beige.withOpacity(0.5) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isLocked ? Icons.lock : Icons.image,
                          size: 32,
                          color: isLocked ? beige : beige.withOpacity(0.2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
