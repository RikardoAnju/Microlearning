import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KontenPelajaran extends StatefulWidget {
  const KontenPelajaran({super.key});

  @override
  KontenPelajaranState createState() => KontenPelajaranState();
}

class KontenPelajaranState extends State<KontenPelajaran> {
  @override

  Widget build(BuildContext context ) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFD55),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(150),
                  bottomRight: Radius.circular(150),
                )
              ),
              child:  Center(
                child: Text(
                  'Konten Pelajaran',
                  style: GoogleFonts.poppins(
                    fontSize: 32
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
