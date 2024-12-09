import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'konten_subab.dart'; // Pastikan KontenSubab sudah didefinisikan dengan benar

class KelasPage extends StatelessWidget {
  final String mataPelajaran;
  final String idlesson; // Menambahkan idlesson di sini

  const KelasPage({super.key, required this.mataPelajaran, required this.idlesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 253, 240, 69),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(150),
                  bottomRight: Radius.circular(150),
                ),
              ),
              height: 150,
            ),
            Positioned(
              top: 20,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.black,
                iconSize: 30,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Text(
                  mataPelajaran,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              _buildKelasBox(context, "Kelas 10"),
              const SizedBox(height: 20),
              _buildKelasBox(context, "Kelas 11"),
              const SizedBox(height: 20),
              _buildKelasBox(context, "Kelas 12"),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildKelasBox(BuildContext context, String kelas) {
    return GestureDetector(
      onTap: () {
       
        print('Tapped on $kelas');
        
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KontenSubab(
              kelas: kelas,       
              mataPelajaran: mataPelajaran,   
              idlesson: idlesson, 
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
            kelas,
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
