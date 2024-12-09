import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DaftarSiswa extends StatefulWidget {
  const DaftarSiswa({super.key});

  @override
  DaftarSiswaState createState() => DaftarSiswaState();
}

class DaftarSiswaState extends State<DaftarSiswa> {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  Timer? _debounce;
  List<QueryDocumentSnapshot> _userList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadUsers(); // Memuat data awal
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi untuk mengelola perubahan teks pada search box
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  
  Future<void> _loadUsers() async {
    final snapshot = await userCollection.where('role', isEqualTo: 'Student').get();
    setState(() {
      _userList = snapshot.docs;
    });
  }

  // Fungsi untuk mendapatkan data siswa berdasarkan pencarian
  List<QueryDocumentSnapshot> _getFilteredUsers() {
    if (_searchText.isEmpty) {
      return _userList;
    } else {
      return _userList.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data['name']?.toLowerCase().contains(_searchText) ?? false;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
                  'Daftar Siswa',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // TextField Pencarian
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari siswa...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // StreamBuilder untuk pengambilan data siswa dengan pencarian dinamis
            Builder(
              builder: (context) {
                final filteredUsers = _getFilteredUsers();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Tidak ada data siswa.',
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    var data = filteredUsers[index].data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(color: Colors.lightBlueAccent),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Foto profil
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: data['profile_image'] != null && data['profile_image'].isNotEmpty
                                    ? NetworkImage(data['profile_image'])
                                    : const AssetImage('assets/image/profile.jpg') as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              // Informasi Siswa
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? 'Nama tidak tersedia',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    data['nisn'] ?? 'NIS tidak tersedia',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Informasi Tambahan
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    data['gender'] ?? 'Gender tidak tersedia',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data['kelas'] ?? 'Kelas tidak tersedia',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
