import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/client_detail.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClientDetail()),
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: kTravailFuteMainColor,
              child: Text(
                "KN",
                style: TextStyle(
                  color: kWhiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.contacts,
                      size: 12,
                      color: kTravailFuteMainColor,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Kenny Chris Ndayikengurukiye",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          color: kTravailFuteSecondaryColor,
                          fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 12,
                      color: kTravailFuteMainColor,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Rue de la cooperation 49/13",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 12,
                      color: kTravailFuteMainColor,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "0467070914",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            // Text("numero"),
            // Text("email"),
            // Text("registered"),
          ],
        ),
      ),
    );
  }
}
