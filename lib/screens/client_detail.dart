import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/widgets/botom_nav.dart';
import 'package:travail_fute/widgets/foab.dart';
import 'package:travail_fute/widgets/main_card.dart';


/// YOOOOOO CAPTAIN....
/// YOU MIGHT WANT TO ADJUST SOME OF THE FIGURES ON THIS PAGE 
/// BECAUSE i WAS FLYING BLIND, COULDN'T CREATE A NEW CLIENT TO TEST


class ClientDetail extends StatelessWidget {
  const ClientDetail({
    super.key,
    required this.client,
  });

  final Map<String, dynamic> client;

  @override
  Widget build(BuildContext context) {
    // LOCAL VARIABLES
    var size = MediaQuery.of(context).size;
    var width = size.width;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Container(),
      ),
      backgroundColor: kBackgroundColor,
      body: Column(children: [
        MainSection(client: client),
        Container(
            margin:  EdgeInsets.all(width * 0.045),
            // padding: EdgeInsets.all(value),
            // decoration: BoxDecoration(color: kWhiteColor),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: MainCard(
                        // onPress: playRecord,
                        label: 'Devis',
                        number: '5 ',
                        icon: Icons.euro,
                        value: 1,
                        completed: 5,
                        cardColor: kWhiteColor,
                      ),
                    ),
                     SizedBox(
                      width: width * 0.015,
                    ),
                    Expanded(
                      child: MainCard(
                          onPress: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const ClientsList()),
                            // );
                          },
                          label: 'Factures',
                          number: '15',
                          icon: Icons.receipt,
                          value: 89,
                          cardColor: kWhiteColor,
                          completed: 89),
                    ),
                  ],
                ),
                 SizedBox(
                  height: width * 0.015,
                ),
                Row(
                  children: [
                    Expanded(
                      child: MainCard(
                          onPress: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const ClientsList()),
                            // );
                          },
                          label: 'Tâches',
                          number: '0',
                          icon: Icons.task,
                          value: 89,
                          cardColor: kWhiteColor,
                          completed: 89),
                    ),
                     SizedBox(
                      width: width * 0.015,
                    ),
                    const Expanded(
                      child: MainCard(
                        // onPress: playRecord,
                        label: 'Gestion',
                        cardColor: kTravailFuteMainColor,
                        number: '5 ',
                        addOption: false,
                        icon: Icons.folder,
                        value: 1,
                        completed: 5,
                        textColor: kWhiteColor,
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ]),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: const RecordFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class MainSection extends StatelessWidget {
  const MainSection({
    super.key,
    required this.client,
  });

  final Map<String, dynamic> client;

  @override
  Widget build(BuildContext context) {
    // LOCAL VARIABLES
    var size = MediaQuery.of(context).size;
    var width = size.width;

    return Container(
      padding:  EdgeInsets.all(width * 0.075),
      margin:  EdgeInsets.all(width * 0.015),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.025),
        color: kWhiteColor,
        boxShadow: const [
          BoxShadow(
            color: kTravailFuteSecondaryColor,
            // offset: Offset(0, 0.2),
            // blurRadius: 0.4,
            // spreadRadius: 0.0,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: width * 0.05,
            backgroundColor: kTravailFuteMainColor,
            child: Text(
              client['first_name'][0].toUpperCase() +
                  client['last_name'][0].toUpperCase(),
              style:  TextStyle(
                color: kWhiteColor,
                fontWeight: FontWeight.bold,
                fontSize: width * 0.035,
              ),
            ),
          ),
           SizedBox(
            height: width * 0.015,
          ),
          Text(
            client['first_name'] + ' ' + client['last_name'],
            style:  TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                color: kTravailFuteSecondaryColor,
                fontSize: width * 0.05),
          ),
           SizedBox(
            height: width * 0.015,
          ),
          Text(
            client['email'].toString(),
            style:  TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: width * 0.04),
          ),
           SizedBox(
            height: width * 0.025,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.green,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.phone,
                    color: kWhiteColor,
                  ),
                  color: Colors.green,
                ),
              ),
               SizedBox(
                width: width * 0.015,
              ),
              CircleAvatar(
                backgroundColor: Colors.amber,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mail,
                    color: kWhiteColor,
                  ),
                  color: Colors.green,
                ),
              ),
               SizedBox(
                width: width * 0.015,
              ),
              CircleAvatar(
                backgroundColor: Colors.indigo,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.location_on,
                    color: kWhiteColor,
                  ),
                  color: Colors.green,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
