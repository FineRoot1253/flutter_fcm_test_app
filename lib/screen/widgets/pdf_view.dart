import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFView extends StatelessWidget {

  final String url;

  PDFView({this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:PDF().cachedFromUrl(this.url,placeholder: (progress)=>Center(child: CircularProgressIndicator(value: progress/100,),))
    );
  }
}
