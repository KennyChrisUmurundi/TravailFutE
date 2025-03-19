import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:travail_fute/utils/logger.dart';

class PdfViewerScreen extends StatelessWidget {
  final String billOrEstimateId; // Renamed to be more generic
  final String pdfUrl;
  final bool isEstimate;

  PdfViewerScreen({
    required this.billOrEstimateId,
    required this.isEstimate,
    super.key,
  }) : pdfUrl = isEstimate
            ? "$apiUrl/invoice/$billOrEstimateId/pdf/"
            : "$apiUrl/bill/$billOrEstimateId/pdf/";

  Future<bool> _checkPdfUrl(BuildContext context, String url, String token) async {
    try {
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to load PDF: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
    }
  }

  Future<void> _sharePdf(BuildContext context, String url, String token) async {
    try {
      // Fetch the PDF
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Token $token'});
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${isEstimate ? 'estimate' : 'bill'}_$billOrEstimateId.pdf';

      // Write PDF to file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Share the PDF with pre-filled options
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'application/pdf')],
        text: isEstimate
            ? 'Bonjour, voici le devis #$billOrEstimateId. Merci de vérifier.'
            : 'Bonjour, voici la facture #$billOrEstimateId. Merci de vérifier et de procéder au paiement.',
        subject: isEstimate
            ? 'Devis #$billOrEstimateId - Votre Entreprise'
            : 'Facture #$billOrEstimateId - Votre Entreprise', // For email
      );

      // Clean up the file after sharing
      await file.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    logger.i('PDF URL: $pdfUrl');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEstimate ? 'Devis PDF' : 'Facture PDF'),
        backgroundColor: kTravailFuteMainColor,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _sharePdf(context, pdfUrl, token),
            tooltip: isEstimate ? 'Envoyer le devis' : 'Envoyer la facture',
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _checkPdfUrl(context, pdfUrl, token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
            return Center(child: Text('Failed to load PDF'));
          } else {
            return Container(
              constraints: BoxConstraints.expand(),
              child: SfPdfViewer.network(
                pdfUrl,
                headers: {'Authorization': 'Token $token'},
                onDocumentLoadFailed: (details) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load PDF: ${details.description}')),
                  );
                },
                onDocumentLoaded: (details) {
                  logger.i('Document loaded');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF loaded successfully')),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}