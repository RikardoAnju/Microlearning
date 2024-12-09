import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DaftarKonten extends StatelessWidget {
  final String lessonId;

  DaftarKonten({super.key, required this.lessonId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch konten berdasarkan lessonId
  Future<List<Map<String, dynamic>>> fetchKonten() async {
    try {
      var kontenSnapshot = await _firestore
          .collection('konten')
          .where('lessonId', isEqualTo: lessonId) 
          .get();

      // Ubah data konten menjadi List Map
      return kontenSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; 
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching konten: $e');
      return [];
    }
  }

  // Membuat card untuk setiap konten
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
                    // Aksi saat tombol edit diklik
                    print('Edit content: ${content['judulSubBab']}');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Aksi saat tombol hapus diklik
                    print('Delete content: ${content['judulSubBab']}');
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
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchKonten(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Tidak ada konten.', style: TextStyle(fontSize: 16)),
                );
              }

              var konten = snapshot.data!;
              return Expanded(
                child: ListView.builder(
                  itemCount: konten.length,
                  itemBuilder: (context, index) {
                    return buildContentCard(konten[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
