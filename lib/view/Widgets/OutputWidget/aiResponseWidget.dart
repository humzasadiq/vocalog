import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AIResponseWidget extends StatefulWidget {
  final String output;
  final Color calar;

  const AIResponseWidget({Key? key, required this.output, required this.calar})
      : super(key: key);

  @override
  _AIResponseWidgetState createState() => _AIResponseWidgetState();
}

class _AIResponseWidgetState extends State<AIResponseWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(50, 30),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: widget.calar),
                ),
                onPressed: () async {
                  final dir = await getApplicationDocumentsDirectory();
                  // Create a unique filename based on content hash
                  final String contentHash = widget.output.hashCode.toString();
                  final pdfPath = "${dir.path}/output_$contentHash.pdf";

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
                        'markdown': widget.output,
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

                      // Delete the file after sharing
                      await File(pdfPath).delete();
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
                },
                label: Text(
                  "Export to PDF",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.calar),
                ),
                icon: Icon(
                  Icons.download,
                  color: widget.calar,
                ),
              ),
              Container(
                width: constraints.maxWidth * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: MarkdownBody(
                  data: widget.output,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    h1: TextStyle(
                      color: widget.calar,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    h2: TextStyle(
                      color: widget.calar,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    h3: TextStyle(
                      color: widget.calar,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    listBullet: const TextStyle(
                      color: Colors.black87,
                    ),
                    blockquote: TextStyle(
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                    code: TextStyle(
                      color: widget.calar,
                      backgroundColor: Colors.black.withOpacity(0.05),
                      
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
