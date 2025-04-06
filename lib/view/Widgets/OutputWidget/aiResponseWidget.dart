import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class AIResponseWidget extends StatefulWidget {
  final String filePath;

  const AIResponseWidget({Key? key, required this.filePath}) : super(key: key);

  @override
  _AIResponseWidgetState createState() => _AIResponseWidgetState();
}

class _AIResponseWidgetState extends State<AIResponseWidget> {
  late String _markdownContent;
  late bool _hasContent;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() {
    final directory = Directory(widget.filePath);
    final outputFile = File("${widget.filePath}/output.md");

    setState(() {
      _hasContent = directory.existsSync() && outputFile.existsSync();
      _markdownContent = _hasContent ? outputFile.readAsStringSync() : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!_hasContent) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    "Processing, Check back after a few seconds",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.black,
                    size: 50,
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(50, 30),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.black),
                ),
                onPressed: () async {
                  final pdfPath = "${widget.filePath}/output.pdf";
                  if (!File(pdfPath).existsSync()) {
                    try {
                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.grey,
                          content: Text("Generating PDF..."),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Prepare the request
                      final response = await http.post(
                        Uri.parse('https://md-to-pdf.fly.dev'),
                        body: {
                          'markdown': _markdownContent,
                          'engine': 'weasyprint',
                        },
                      );

                      if (response.statusCode == 200) {
                        // Save the PDF file
                        await File(pdfPath).writeAsBytes(response.bodyBytes);

                        // Show success message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text("PDF generated successfully"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }

                        // Share the generated PDF
                        await Share.shareXFiles(
                          [XFile(pdfPath)],
                          subject: 'Generated PDF',
                        );
                      } else {
                        throw Exception(
                            'Failed to generate PDF: ${response.statusCode}');
                      }
                    } catch (e) {
                      debugPrint("Error generating PDF: $e");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content:
                                Text("Error generating PDF: ${e.toString()}"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  } else {
                    // If PDF already exists, just share it
                    await Share.shareXFiles(
                      [XFile(pdfPath)],
                      subject: 'Generated PDF',
                    );
                  }
                },
                label: Text(
                  "Export to PDF",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                icon: Icon(Icons.download),
              ),
              Divider(
                color: Colors.black12,
              ),
              Container(
                decoration: const BoxDecoration(),
                child: Markdown(
                  data: _markdownContent,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.tinos(color: Colors.black),
                    h1: GoogleFonts.tinos(color: Colors.black),
                    h2: GoogleFonts.tinos(color: Colors.black),
                    listBullet: GoogleFonts.tinos(color: Colors.black),
                  ),
                  // Add these parameters to help with layout
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
