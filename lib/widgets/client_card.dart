import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/client_detail.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.client,
  });

  final Map<String, dynamic> client;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientDetail(client: client)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(1),
        width: double.infinity,
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: kTravailFuteMainColor,
              child: Icon(Icons.person, color: kWhiteColor),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   children: [
                //     const Icon(
                //       Icons.contacts,
                //       size: 12,
                //       color: kTravailFuteMainColor,
                //     ),
                //     const SizedBox(
                //       width: 8,
                //     ),
                //     Text(
                //       (client['first_name'] ?? '') + ' ' + (client['last_name'] ?? ''),
                //       style: const TextStyle(
                //           fontFamily: "Poppins",
                //           fontWeight: FontWeight.bold,
                //           color: kTravailFuteSecondaryColor,
                //           fontSize: 14),
                //     ),
                //   ],
                // ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_city,
                      size: 12,
                      color: kTravailFuteMainColor,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                        "${client['address_street'] ?? ''} ${client['address_town'] ?? 'Addresse inconnue'}",
                      style: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 12,
                      color: kTravailFuteMainColor,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      "${client['phone_number'].replaceFirst('+32', '0').replaceAllMapped(RegExp(r'(\d{4})(\d{2})(\d{2})(\d{2})'), (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}')}",
                      style: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
