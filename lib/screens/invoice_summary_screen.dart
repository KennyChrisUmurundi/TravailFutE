import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceSummaryScreen extends StatelessWidget {
  final String client;
  final List<Map<String, dynamic>> services;
  final double total;

  const InvoiceSummaryScreen({
    super.key,
    required this.client,
    required this.services,
    required this.total,
  });

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Client: $client'),
            pw.Text('Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}'),
            pw.SizedBox(height: 20),
            pw.Text('Services:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Description', 'Price'],
              data: services.map((s) => [s['description'], '\$${s['price'].toStringAsFixed(2)}']).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total: \$${total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kTravailFuteMainColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, size),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client: $client',
                        style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87),
                      ),
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                        style: TextStyle(fontSize: size.width * 0.045, color: Colors.black87),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Text(
                        'Services:',
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: kTravailFuteMainColor,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      ...services.map((service) => Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
                            child: Padding(
                              padding: EdgeInsets.all(size.width * 0.03),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    service['description'],
                                    style: TextStyle(
                                      fontSize: size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '\$${service['price'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: size.width * 0.045,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold,
                              color: kTravailFuteMainColor,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _generatePdf(context);
          Navigator.pop(context, {
            'id': 'REC${DateTime.now().millisecondsSinceEpoch}',
            'client': client,
            'date': DateTime.now(),
            'total': total,
          });
        },
        backgroundColor: kTravailFuteMainColor,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: kTravailFuteMainColor),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Invoice Summary',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: kTravailFuteMainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}