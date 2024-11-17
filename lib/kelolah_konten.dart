import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KelolahKonten extends StatefulWidget {
  const KelolahKonten({super.key});

  @override
  KelolahKontenState createState() => KelolahKontenState();
}

class KelolahKontenState extends State<KelolahKonten> {
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
                  'Kelolah Konten',
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
