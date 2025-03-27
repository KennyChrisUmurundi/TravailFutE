import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/clients.dart';
import 'package:travail_fute/screens/new_invoice_screen.dart';
import 'package:intl/intl.dart';
import 'package:travail_fute/screens/pdf_viewer_screen.dart';
import 'package:travail_fute/services/invoice_service.dart';
import 'package:travail_fute/services/receipt_service.dart';
import 'package:travail_fute/utils/logger.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReceiptScreen extends StatefulWidget {
  final List<dynamic>? bills;
  final bool isEstimate;
  const ReceiptScreen({super.key,this.bills,this.isEstimate = false});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Map<String, dynamic>> _receipts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.bills != null) {
      _receipts = widget.bills!.cast<Map<String, dynamic>>();
      _isLoading = false;
    } else if(widget.bills == null && widget.isEstimate){
      fetchEstimates();  
    }
    else{
      fetchReceipts();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fetchReceipts() async {
    try {
      final receipts = await ReceiptService().fetchReceipts(context);
      if(mounted){
        setState(() {
          _receipts = receipts.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Échec du chargement des factures';
        _isLoading = false;
      });
    }
  }

  void fetchEstimates()async{
    try {
      final estimates = await InvoiceService().getInvoiceList(context);
      logger.i("Estimates: $estimates");
      if(mounted){
        setState(() {
          _receipts = estimates.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Échec du chargement des devis';
        _isLoading = false;
      });
    }
  }

  void _navigateToNewInvoice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientsList(),
      ),
    );
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
              _buildHeader(size),
              Expanded(child: _buildContent(size)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(Size size) {
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
            child: FadeTransition(
              opacity: _animation,
                child: Text(
                widget.isEstimate ? 'Devis' : 'Factures',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kTravailFuteMainColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Size size) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: kTravailFuteMainColor,));
    } else if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    } else {
      return _buildReceiptList(size);
    }
  }

  Widget _buildReceiptList(Size size) {
    if (_receipts.isEmpty) {
      return _buildEmptyState(size, size.width);
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(size.width * 0.04),
      itemCount: _receipts.length,
      itemBuilder: (context, index) {
      final receipt = _receipts[index];
      return FadeTransition(
        opacity: _animation,
        child: _buildReceiptCard(size, receipt),
      );
      },
    );
  }

  Widget _buildReceiptCard(Size size, Map<String, dynamic> receipt) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(billOrEstimateId: receipt['id'].toString(), isEstimate: widget.isEstimate),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.03),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                     widget.isEstimate ? 'Devis #${receipt['id']}' : 'Facture #${receipt['id']}',
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      'Client: ${receipt['client']}',
                      style: TextStyle(fontSize: size.width * 0.04, color: Colors.grey[600]),
                    ),
                    Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(receipt['created_at']))}',
                      style: TextStyle(fontSize: size.width * 0.04, color: Colors.grey[600]),
                    ),
                    if (!widget.isEstimate)
                      Text(
                      'Total: €${receipt['amount']}',
                      style: TextStyle(fontSize: size.width * 0.04, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.visibility, color: kTravailFuteMainColor),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(billOrEstimateId: receipt['id'].toString(),isEstimate: widget.isEstimate)
                        ,
                      ),
                    );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildEmptyState(Size size, double width) {
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: EdgeInsets.all(width * 0.06),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction,
                size: width * 0.15,
                color: Colors.grey[400],
              ),
              SizedBox(height: width * 0.04),
              Text(
                widget.isEstimate? 'Aucun devis trouvé': 'Aucune facture trouvée' ,
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: width * 0.02),
              Text(
                widget.isEstimate? 'Ajoutez un nouveau devis pour commencer':'Ajoutez une nouvelle facture pour commencer !',
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _navigateToNewInvoice,
      backgroundColor: kTravailFuteMainColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ScaleTransition(
        scale: _animation,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
