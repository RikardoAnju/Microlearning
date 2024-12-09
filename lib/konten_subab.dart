import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/konten_pelajaran.dart';

class KontenSubab extends StatefulWidget {
  final String kelas;
  final String mataPelajaran;
  final String idlesson;

  const KontenSubab({
    super.key,
    required this.kelas,
    required this.mataPelajaran,
    required this.idlesson,
  });

  @override
  KontenSubabState createState() => KontenSubabState();
}

class KontenSubabState extends State<KontenSubab> {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('konten');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Fungsi untuk mendapatkan subab yang sudah difilter berdasarkan kelas dan query pencarian
Stream<QuerySnapshot> _getFilteredSubab() {
  if (_searchQuery.isEmpty) {
    return userCollection
        .where('kelas', isEqualTo: widget.kelas) // Contoh: "kelas 10"
        .where('mataPelajaran', isEqualTo: widget.mataPelajaran.toUpperCase()) // Contoh: "FISIKA"
        .snapshots();
  } else {
    return userCollection
        .where('kelas', isEqualTo: widget.kelas) // Contoh: "kelas 10"
        .where('mataPelajaran', isEqualTo: widget.mataPelajaran.toUpperCase()) // Contoh: "FISIKA"
        .where('judulSubBab', isGreaterThanOrEqualTo: _searchQuery) // Filter pencarian
        .where('judulSubBab', isLessThanOrEqualTo: '$_searchQuery\uf8ff') // Filter pencarian
        .snapshots();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFD55),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Header untuk kelas
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
                  ' ${widget.kelas}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari subab...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // StreamBuilder untuk menampilkan data subab
            StreamBuilder<QuerySnapshot>(
              stream: _getFilteredSubab(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada subab ditemukan'));
                }

                var subabList = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subabList.length,
                  itemBuilder: (context, index) {
                    var subab = subabList[index];

                    
                    String judulSubBab = subab['judulSubBab'] ?? 'No Title';

                    return GestureDetector(
                      onTap: () {
                       
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KontenPelajaran(
                              subabId: subab.id, // Mengirimkan id subab
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13ADDE),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            judulSubBab, // Menampilkan judulSubBab yang valid
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
