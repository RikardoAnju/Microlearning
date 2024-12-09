import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/kelas_page.dart'; 

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 253, 240, 69),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(150),
                bottomRight: Radius.circular(150),
              ),
            ),
            child: Center(
              child: Text(
                'Mata Pelajaran',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildMateriContent(),
          ),
        ],
      ),
    );
  }

  // Menampilkan daftar mata pelajaran
  Widget _buildMateriContent() {
    // Daftar mata pelajaran
    List<String> mataPelajaranList = [
      'MATEMATIKA',
      'BIOLOGI',
      'PKN',
      'FISIKA'
    ];

    return FutureBuilder<QuerySnapshot>(
      // Mengambil data semua materi dari Firestore
      future: FirebaseFirestore.instance
          .collection('konten') // Nama koleksi di Firestore
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Materi tidak ditemukan'));
        }

        // Mendapatkan semua dokumen dari Firestore
        var materiList = snapshot.data!.docs;

        // Debugging: Print data materi untuk verifikasi
        for (var materi in materiList) {
          print("Materi: ${materi['mataPelajaran']}"); // Debugging field `mataPelajaran`
        }

        return SingleChildScrollView(
          child: Column(
            children: mataPelajaranList.map((mataPelajaran) {
              // Menyaring data berdasarkan `mataPelajaran`
              var filteredMateri = materiList
                  .where((materi) => materi['mataPelajaran'] == mataPelajaran)
                  .toList();

              // Debugging: Print jumlah materi untuk setiap mata pelajaran
              print("Filtered materi for $mataPelajaran: ${filteredMateri.length}");

              if (filteredMateri.isEmpty) {
                return const SizedBox(); 
              }

              // Mendapatkan `idlesson` dari data pertama hasil filter
              var idlesson = filteredMateri[0]['lessonId'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _buildMateriBox(mataPelajaran, idlesson),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Widget untuk menampilkan setiap mata pelajaran
  Widget _buildMateriBox(String mataPelajaran, String lessonId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KelasPage(
              mataPelajaran: mataPelajaran, // Menggunakan `mataPelajaran`
              idlesson: lessonId, // Menyertakan `idlesson`
            ),
          ),
        );
      },
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF13ADDE),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            mataPelajaran,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
