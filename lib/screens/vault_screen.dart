import 'package:flutter/material.dart';
import 'panic_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _locked = false;

  final List<Map<String, dynamic>> _photos = [
    {'name': 'Document_001.jpg', 'size': '2.4 MB', 'date': '06/03/2026'},
    {'name': 'Photo_privée.jpg', 'size': '1.8 MB', 'date': '05/03/2026'},
    {'name': 'Scan_ID.jpg', 'size': '3.1 MB', 'date': '01/03/2026'},
    {'name': 'Contrat_signé.jpg', 'size': '0.9 MB', 'date': '28/02/2026'},
  ];

  final List<Map<String, dynamic>> _notes = [
    {'title': 'Mots de passe', 'preview': '••••••••••', 'date': '06/03/2026'},
    {'title': 'Code PIN carte', 'preview': '••••••••••', 'date': '04/03/2026'},
    {'title': 'Numéros importants', 'preview': 'Assurance, Médecin...', 'date': '01/03/2026'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'photo' ? 'Ajouter une photo' : 'Nouvelle note',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (type == 'photo') ...[
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snack('Caméra non disponible en mode démo'),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snack('Galerie non disponible en mode démo'),
                      );
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerie'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ])
            ] else ...[
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Titre de la note',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Contenu (sera chiffré)...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      _snack('Note sauvegardée et chiffrée ✓', success: true),
                    );
                  },
                  child: const Text('Sauvegarder'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  SnackBar _snack(String msg, {bool success = false}) {
    return SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : const Color(0xFF2A2A3E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coffre-fort',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'AES-256-GCM chiffré',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PanicScreen()),
                        );
                      },
                      icon: const Icon(Icons.warning_amber, color: Colors.orange),
                      tooltip: 'Mode Panic',
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _locked = !_locked);
                        ScaffoldMessenger.of(context).showSnackBar(
                          _snack(_locked ? 'Coffre verrouillé' : 'Coffre déverrouillé'),
                        );
                      },
                      icon: Icon(
                        _locked ? Icons.lock : Icons.lock_open,
                        color: _locked ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Photos'),
                Tab(text: 'Notes'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Photos tab
                _locked
                    ? _LockedOverlay()
                    : Stack(
                        children: [
                          GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _photos.length,
                            itemBuilder: (ctx, i) {
                              final p = _photos[i];
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E2E),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(14),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: 48,
                                            color: Colors.white24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p['name'] as String,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${p['size']} • ${p['date']}',
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              onPressed: () => _showAddDialog(context, 'photo'),
                              backgroundColor: const Color(0xFF6C63FF),
                              child: const Icon(Icons.add_photo_alternate),
                            ),
                          ),
                        ],
                      ),

                // Notes tab
                _locked
                    ? _LockedOverlay()
                    : Stack(
                        children: [
                          ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _notes.length,
                            itemBuilder: (ctx, i) {
                              final n = _notes[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E2E),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C63FF)
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.note_outlined,
                                        color: Color(0xFF6C63FF),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n['title'] as String,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            n['preview'] as String,
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      n['date'] as String,
                                      style: const TextStyle(
                                        color: Colors.white24,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              onPressed: () => _showAddDialog(context, 'note'),
                              backgroundColor: const Color(0xFF6C63FF),
                              heroTag: 'note_fab',
                              child: const Icon(Icons.note_add),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'Coffre verrouillé',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Appuyez sur le cadenas pour déverrouiller',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
