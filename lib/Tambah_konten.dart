import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TambahKonten extends StatefulWidget {
  final String lessonId;

  const TambahKonten({super.key, required this.lessonId});

  @override
  TambahKontenState createState() => TambahKontenState();
}

class TambahKontenState extends State<TambahKonten> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController subababController = TextEditingController();
  final TextEditingController linkvidioController = TextEditingController();

  String? pdfFileName;
  Uint8List? pdfBytes;
  String? videoUrl;
  bool _isSaving = false;

  // Data tambahan dari Firestore
  String? namaGuru;
  String? kelas;
  String? mataPelajaran;

  @override
  void initState() {
    super.initState();
    _fetchLessonDetails();
  }

  @override
  void dispose() {
    subababController.dispose();
    linkvidioController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil informasi lesson detail dari Firestore
  Future<void> _fetchLessonDetails() async {
    try {
      DocumentSnapshot lessonSnapshot = await FirebaseFirestore.instance
          .collection('pengajar')
          .doc(widget.lessonId)
          .get();

      if (lessonSnapshot.exists) {
        setState(() {
          namaGuru = lessonSnapshot['namaGuru'];
          kelas = lessonSnapshot['kelas'];
          mataPelajaran = lessonSnapshot['mataPelajaran'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data lesson: $e')),
      );
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
                  'Tambah Konten',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Form Input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Sub Bab
                    Text(
                      'Judul Sub Bab',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: subababController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Masukkan Judul Sub Bab',
                        labelStyle: GoogleFonts.poppins(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan judul sub bab';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Materi (PDF)
                    Text(
                      'Materi (PDF)',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _pickPdfFile,
                          child: const Text('Pilih PDF Materi'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            pdfFileName ?? 'Tidak ada file PDF',
                            style: GoogleFonts.poppins(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Link YouTube Video
                    Text(
                      'Link Video YouTube',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: linkvidioController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Masukkan Link YouTube',
                        labelStyle: GoogleFonts.poppins(),
                      ),
                      validator: (value) {
                        if ((value == null || value.isEmpty) && pdfBytes == null) {
                          return 'Masukkan link YouTube atau pilih file PDF';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        videoUrl = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Tombol Simpan
                    Center(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isSaving = true;
                                  });
                                  await _saveContent();
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                              },
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk memilih file PDF
  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      final platformFile = result.files.single;
      setState(() {
        pdfFileName = platformFile.name;
        pdfBytes = platformFile.bytes;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada file yang dipilih')),
      );
    }
  }

  // Fungsi untuk menyimpan data ke Firestore
  Future<void> _saveContent() async {
    try {
      // Pastikan pengguna terautentikasi
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna tidak terautentikasi')),
        );
        return;
      }

      String? pdfUrl;

      // Upload file PDF ke Firebase Storage jika ada
      if (pdfBytes != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('konten/${user.uid}/${widget.lessonId}_${pdfFileName!}');
        final uploadTask = await storageRef.putData(pdfBytes!);
        pdfUrl = await uploadTask.ref.getDownloadURL();
      }

      // Simpan data ke Firestore dengan userId dan data tambahan
      await FirebaseFirestore.instance.collection('konten').add({
        'userId': user.uid, // Simpan userId
        'lessonId': widget.lessonId,
        'judulSubBab': subababController.text,
        'linkVideo': videoUrl,
        'pdfUrl': pdfUrl,
        'namaGuru': namaGuru, // Simpan nama guru
        'kelas': kelas, // Simpan kelas
        'mataPelajaran': mataPelajaran, // Simpan mata pelajaran
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }
}
