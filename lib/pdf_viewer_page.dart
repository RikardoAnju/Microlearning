import 'package:flutter/material.dart';  // Pastikan ini diimpor
import 'package:flutter_pdfview/flutter_pdfview.dart'; // atau paket lain untuk melihat PDF jika diperlukan

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;  // Properti untuk menyimpan URL PDF

  // Konstruktor dengan parameter yang diharuskan
  const PdfViewerPage({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: Center(
        child: pdfUrl.isNotEmpty
            ? PDFView(
                filePath: pdfUrl,  // Gunakan PDFView atau paket lain yang sesuai
              )
            : const Text('URL PDF kosong atau tidak valid'),
      ),
    );
  }
}
