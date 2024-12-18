import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:microlearning/daftar_siswa.dart';
import 'package:microlearning/kelolah_konten.dart';
import 'package:microlearning/materi_page.dart';
import 'profile_guru.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _pages = <Widget>[
    HomeContent(), // Beranda Home
    KelolahKonten(),
    MateriPage(),
    DaftarSiswa(), // Halaman Kuiz
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Header setengah lingkaran 
          if (_selectedIndex == 0)
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
                children: <Widget>[
                  Positioned(
                    top: -30,
                    left: 15,
                    width: 200,
                    height: 200,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo-ulilalbab.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 15,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileGuru(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.person,
                        size: 40,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Konten Utama
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
            backgroundColor: Color(0xFFFFFD55),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_open),
            label: 'Kelola Konten', 
            backgroundColor: Color(0xFFFFFD55),
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Materi',
            backgroundColor: Color(0xFFFFFD55),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Daftar Siswa',
            backgroundColor: Color(0xFFFFFD55),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: GoogleFonts.poppins(),  
        unselectedLabelStyle: GoogleFonts.poppins(), 
        showUnselectedLabels: true,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<bool> isHovered = List.generate(5, (index) => false);

  // Daftar gambar untuk setiap kartu
  final List<String> _images = [
    'assets/images/TPA_ua.png',
    'assets/images/Logo-TK.png',
    'assets/images/Logo-SDIT.jpg',
    'assets/images/Logo-SMPIT.png',
    'assets/images/Logo-SMAIT.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20), 
          const Center(
            child: CircleAvatar(
              radius: 100, // Logo size
              backgroundImage: AssetImage('assets/images/ASET-PPDB.png'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'YAYASAN ULIL ALBAB BATAM',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Merupakan Lembaga Pendidikan Islam Rujukan di Provinsi Kepulauan Riau, alhamdulillah saat ini masih diberi amanah mengelola jenjang Pendidikan Tingkat TKIT, SDIT, SMPIT Dan SMAIT. Adapun lembaga pendidikan ini menyelenggarakan Pendidikan yang Berlandaskan pada Nilai-Nilai Ajaran Islam Dengan Berorientasi pada Terbentuknya Generasi Rabbani yaitu Cerdas, Sholih dan Berkarakter Qur\'ani.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0), // Menambahkan padding dari kiri
              child: Text(
                "Jenjang Pendidikan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: _images.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildCard(
                  index: index,
                  image: _images[index],
                  title: index == 0
                      ? 'Taman Penitipan'
                      : index == 1
                          ? 'TKIT Anak Harapan'
                          : index == 2
                              ? 'SDIT'
                              : index == 3
                                  ? 'SMPIT'
                                  : 'SMAIT',
                );
              },
            ),
          ),
          const SizedBox(height: 50), // Jarak di bawah GridView
        ],
      ),
    );
  }

  Widget _buildCard({required int index, required String image, required String title}) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered[index] = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered[index] = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, isHovered[index] ? -10 : 0, 0),
        child: Card(
          elevation: isHovered[index] ? 10 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(image),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}