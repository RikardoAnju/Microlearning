import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tambah_konten.dart'; // Import halaman tambah konten
import 'daftar_konten.dart'; // Import halaman daftar konten

class KelolahKonten extends StatefulWidget {
  const KelolahKonten({super.key});

  @override
  KelolahKontenState createState() => KelolahKontenState();
}

class KelolahKontenState extends State<KelolahKonten> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch data dari Firestore
  Future<List<Map<String, dynamic>>> fetchLessons() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('pengajar').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Tambahkan ID dokumen ke data
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLessons(),
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
              child: Text('Tidak ada data.', style: TextStyle(fontSize: 16)),
            );
          }

          List<Map<String, dynamic>> lessons = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
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
                  child: Center(
                    child: Text(
                      'Kelola Konten',
                      style: GoogleFonts.poppins(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lesson Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    children: lessons.map((lesson) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: buildLessonCard(
                          lesson['mataPelajaran'] ?? 'Tidak Ada Mata Pelajaran',
                          lesson['kelas'] ?? 'Tidak Ada Kelas',
                          lesson['namaGuru'] ?? 'Tidak Ada Guru',
                          lesson['id'], // Kirimkan ID dokumen
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build individual lesson card
  Widget buildLessonCard(
      String subject, String grade, String teacher, String lessonId) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke daftar konten berdasarkan lessonId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DaftarKonten(lessonId: lessonId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFD55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    grade,
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    teacher,
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 24),
              onPressed: () {
                // Navigasi ke halaman TambahKonten dengan lessonId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TambahKonten(lessonId: lessonId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
