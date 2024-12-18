import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DaftarKonten extends StatefulWidget {
  final String lessonId;

  const DaftarKonten({super.key, required this.lessonId});

  @override
  _DaftarKontenState createState() => _DaftarKontenState();
}

class _DaftarKontenState extends State<DaftarKonten> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _konten = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKonten();
  }

  Future<void> _fetchKonten() async {
    try {
      var kontenSnapshot = await _firestore
          .collection('konten')
          .where('lessonId', isEqualTo: widget.lessonId)
          .get();

      setState(() {
        _konten = kontenSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Tambahkan ID dokumen ke data
          return data;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching konten: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _hapusKonten(String id, String judulSubBab) async {
    try {
      await _firestore.collection('konten').doc(id).delete();
      setState(() {
        _konten.removeWhere((content) => content['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konten "$judulSubBab" berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus konten: $e')),
      );
    }
  }

  Widget buildContentCard(Map<String, dynamic> content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFFFD55),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content['mataPelajaran'] ?? 'Tidak Ada Pelajaran',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              content['kelas'] ?? 'Tidak Ada Kelas',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  content['judulSubBab'] ?? 'Tidak Ada Judul Sub Bab',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                Text(
                  content['namaGuru'] ?? 'Tidak Ada Pengajar',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    print('Edit content: ${content['judulSubBab']}');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Konfirmasi'),
                          content: Text('Apakah Anda yakin ingin menghapus konten "${content['judulSubBab']}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        );
                      },
                    ) ?? false;

                    if (confirmDelete) {
                      await _hapusKonten(content['id'], content['judulSubBab']);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFD55),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(150),
                bottomRight: Radius.circular(150),
              ),
            ),
            child: Stack(
              children: [
                // Title
                Center(
                  child: Text(
                    'Kelola Konten',
                    style: GoogleFonts.poppins(fontSize: 32),
                  ),
                ),
                // Back button
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // FutureBuilder untuk mengambil data konten
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _konten.isEmpty
                  ? const Center(
                      child: Text('Tidak ada konten.', style: TextStyle(fontSize: 16)),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _konten.length,
                        itemBuilder: (context, index) {
                          return buildContentCard(_konten[index]);
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
