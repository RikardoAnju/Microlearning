import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class KontenPelajaran extends StatefulWidget {
  const KontenPelajaran({super.key, required this.subabId});

  final String subabId;

  @override
  _KontenPelajaranState createState() => _KontenPelajaranState();
}

class _KontenPelajaranState extends State<KontenPelajaran> {
  late String currentUserId;
  String? imageUrl;
  String? name;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final TextEditingController _komentarController = TextEditingController();
  late Future<DocumentSnapshot> _kontenFuture;

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _kontenFuture = FirebaseFirestore.instance
        .collection('konten')
        .doc(widget.subabId)
        .get();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      currentUserId = user.uid;
      await _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(currentUserId).get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'] as String?; // Nama pengguna
          imageUrl = userDoc['profile_image'] as String?; // URL foto profil
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  void _tambahKomentar() {
    if (_komentarController.text.isNotEmpty) {
      String userName = name ?? 'Anonim';
      String userImage = imageUrl ??
          'https://www.example.com/default-avatar.png'; // Foto profil default
      FirebaseFirestore.instance.collection('komentar').add({
        'subabId': widget.subabId,
        'komentar': _komentarController.text,
        'name': userName,
        'profile_image': userImage,
        'uid': FirebaseAuth.instance.currentUser?.uid, // Menyimpan UID pengguna
        'timestamp': FieldValue.serverTimestamp(),
      });
      _komentarController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _kontenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String judulSubBab = data['judulSubBab'] ?? '';
          final String mataPelajaranUpperCase = data['mataPelajaran'] ?? '';
          final String namaGuru = data['namaGuru'] ?? '';
          final String kelas = data['kelas'] ?? '';
          final String pdfUrl = data['pdfUrl'] ?? '';
          final String linkVideo = data['linkVideo'] ?? '';

          String? videoId;
          if (linkVideo.isNotEmpty) {
            videoId = YoutubePlayer.convertUrlToId(linkVideo);
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black, size: 25),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const Spacer(),
                          // Menampilkan judulSubBab di tengah
                          Padding(
                            padding: const EdgeInsets.only(right: 70.0),
                            child: Center(
                              child: Text(
                                judulSubBab,
                                style: GoogleFonts.poppins(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mataPelajaranUpperCase,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            kelas,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            namaGuru,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.yellow, thickness: 1.5),
                    const SizedBox(height: 30),
                    // Materi PDF
                    if (pdfUrl.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          height: 300,
                          child: SfPdfViewer.network(
                            pdfUrl,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Tombol buka PDF
                    if (pdfUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PdfViewerPage(pdfUrl: pdfUrl),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 15.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.redAccent,
                                  size: 30,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    "Materi $judulSubBab.pdf",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.download, size: 25),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                    // YouTube Player
                    if (videoId != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: YoutubePlayer(
                          controller: YoutubePlayerController(
                            initialVideoId: videoId,
                            flags: const YoutubePlayerFlags(autoPlay: false),
                          ),
                          showVideoProgressIndicator: true,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'Video Materi $judulSubBab',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(
                      color: Colors.yellow,
                      thickness: 1.5,
                    ),
                    const SizedBox(height: 16),
                    // Forum Diskusi
                    

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF13ADDE)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Forum Diskusi',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            const Divider(
                              color: Colors.blue,
                              thickness: 1,
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('komentar')
                                  .where('subabId', isEqualTo: widget.subabId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return const Center(
                                    child: Text(
                                        'Terjadi kesalahan. Silakan coba lagi.'),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                      child: Text('Belum ada komentar.'));
                                }

                                String? userPhotoUrl =
                                    FirebaseAuth.instance.currentUser?.photoURL;

                               return SizedBox(
                                height: 300, // Sesuaikan tinggi sesuai kebutuhan
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                     var komentar = snapshot.data!.docs[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                         child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                             borderRadius: BorderRadius.circular(8.0),
                                             ),
                                             child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage: imageUrl != null 
                                                ? NetworkImage(imageUrl!)
                                                : const NetworkImage('https://www.example.com/default-avatar.png'),
                                                ),
                                                title: Text(
                                                  komentar['name'] ?? name,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    ),
                                                    ),
                                                    subtitle: Text(
              komentar['isi_komentar'] ?? '',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            trailing: FirebaseAuth.instance.currentUser?.uid == komentar['uid']
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool? confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Konfirmasi Hapus'),
                            content: const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal', style: TextStyle(color: Colors.black)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus', style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        await FirebaseFirestore.instance
                            .collection('komentar')
                            .doc(komentar.id)
                            .delete();
                      }
                    },
                  )
                : null,
          ),
        ),
      );
    },
  ),
);

            
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(fontSize: 14),
                                    controller: _komentarController,
                                    decoration: InputDecoration(
                                      hintText: 'Tambah Komentar',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF13ADDE),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF13ADDE),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF13ADDE),
                                          width: 2.0,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.send,
                                            color: Colors.blueAccent),
                                        onPressed: () async {
                                          if (_komentarController.text
                                              .trim()
                                              .isEmpty) return;
                                          await FirebaseFirestore.instance
                                              .collection('komentar')
                                              .add({
                                            'subabId': widget.subabId,
                                            'name': name,
                                            'isi_komentar':
                                                _komentarController.text.trim(),
                                            'uid': FirebaseAuth
                                                .instance
                                                .currentUser
                                                ?.uid, // Tambahkan UID pengguna yang mengirim komentar
                                            'timestamp':
                                                FieldValue.serverTimestamp(),
                                          });

                                          _komentarController.clear();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Halaman untuk menampilkan PDF
class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({super.key, required this.pdfUrl});

  final String pdfUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}