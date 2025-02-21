import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/clients_service.dart';
import 'package:travail_fute/widgets/botom_nav.dart';
import 'package:travail_fute/widgets/main_card.dart';
import 'package:travail_fute/screens/edit_client.dart'; // Import the edit screen
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class ClientDetail extends StatefulWidget {
  const ClientDetail({super.key, required this.client, this.phoneNumber});
  final String? phoneNumber;
  final Map<String, dynamic> client;

  @override
  State<ClientDetail> createState() => _ClientDetailState();
}

class _ClientDetailState extends State<ClientDetail> {

  final ClientService clientService = ClientService();

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      clientService.getClientByPhone(context, widget.phoneNumber!).then((client) {
        setState(() {
          widget.client.addAll(client);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: kWhiteColor,
        foregroundColor: kTravailFuteSecondaryColor,
        title: Text(
          "Détails du Client",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: kTravailFuteSecondaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditClient(client: widget.client),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            children: [
              _buildHeaderSection(context, width),
              SizedBox(height: width * 0.05),
              _buildStatsSection(context, width),
              // Add further sections as needed.
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(onMenuPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeaderSection(BuildContext context, double width) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width * 0.03,
          horizontal: width * 0.04,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: width * 0.1,
              backgroundColor: kTravailFuteMainColor,
              child: Icon(Icons.person, color: kWhiteColor),
            ),
            SizedBox(height: width * 0.04),
            // Text(
            //   "${client['first_name'] ?? ''} ${client['last_name'] ?? ''}",
            //   style: TextStyle(
            //     fontFamily: "Poppins",
            //     fontWeight: FontWeight.bold,
            //     color: kTravailFuteSecondaryColor,
            //     fontSize: width * 0.06,
            //   ),
            // ),
            // SizedBox(height: width * 0.02),
            Text(
              widget.client['phone_number']?.toString().replaceFirst('+32', '0').replaceAllMapped(RegExp(r'(\d{4})(\d{2})(\d{2})(\d{2})'), (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}') ?? '',
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: width * 0.045,
              ),
            ),
            SizedBox(height: width * 0.04),
            Text(
                "${widget.client['address_street'] ?? 'Pas d\'adresse enregistrée'}, ${widget.client['address_town'] ?? ''} ${widget.client['postal_code'] ?? ''}",
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontSize: width * 0.03,
              ),
            ),
            SizedBox(height: width * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                _buildIconButton(Icons.phone, Colors.green, () {
                  final phoneNumber = widget.client['phone_number']?.toString();
                  if (phoneNumber != null && phoneNumber.isNotEmpty) {
                  final Uri launchUri = Uri(
                    scheme: 'tel',
                    path: phoneNumber,
                  );
                  _launchURL(launchUri);
                  }
                }),
                _buildIconButton(Icons.sms, Colors.blue, () {
                  final phoneNumber = widget.client['phone_number']?.toString();
                  if (phoneNumber != null && phoneNumber.isNotEmpty) {
                  final Uri smsUri = Uri(
                    scheme: 'sms',
                    path: phoneNumber,
                  );
                  _launchURL(smsUri);
                  }
                }),
                _buildIconButton(Icons.location_on, Colors.indigo, () {
                  final address = "${widget.client['address_street'] ?? ''}, ${widget.client['address_town'] ?? ''} ${widget.client['postal_code'] ?? ''}";
                  final Uri mapsUri = Uri.parse("geo:0,0?q=$address");
                  _launchURL(mapsUri);
                }),
                // _buildIconButton(Icons.airline_seat_flat_angled_outlined, const Color.fromARGB(255, 192, 63, 12), () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color background, VoidCallback onPressed) {
    return CircleAvatar(
      backgroundColor: background,
      radius: 20,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, color: kWhiteColor, size: 20),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, double width) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MainCard(
                onPress: () {},
                label: 'Devis',
                // number: '5',
                icon: Icons.euro,
                value: 1,
                completed: 5,
                cardColor: kWhiteColor,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: MainCard(
                onPress: () {},
                label: 'Factures',
                // number: '15',
                icon: Icons.receipt,
                value: 89,
                cardColor: kWhiteColor,
                completed: 89,
              ),
            ),
          ],
        ),
        SizedBox(height: width * 0.03),
        Row(
          children: [
            Expanded(
              child: MainCard(
                onPress: () {},
                label: 'Interventions',
                // number: '0',
                icon: Icons.task,
                value: 89,
                cardColor: kWhiteColor,
                completed: 89,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: MainCard(
                onPress: () {},
                label: 'Gestion',
                // number: '5',
                icon: Icons.folder,
                value: 1,
                completed: 5,
                cardColor: kTravailFuteMainColor,
                textColor: kWhiteColor,
                addOption: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void _launchURL(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}