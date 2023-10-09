import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/widgets/botom_nav.dart';
import 'package:travail_fute/widgets/foab.dart';
import 'package:travail_fute/widgets/main_card.dart';

class ClientDetail extends StatelessWidget {
  const ClientDetail({
    super.key,
    required this.client,
  });

  final Map<String, dynamic> client;

  @override
  Widget build(BuildContext context) {
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
            margin: const EdgeInsets.all(15),
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
                    const SizedBox(
                      width: 5,
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
                const SizedBox(
                  height: 5,
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
                    const SizedBox(
                      width: 5,
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
      floatingActionButton: const MyCenteredFAB(),
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
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
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
            radius: 30,
            backgroundColor: kTravailFuteMainColor,
            child: Text(
              client['first_name'][0].toUpperCase() +
                  client['last_name'][0].toUpperCase(),
              style: const TextStyle(
                color: kWhiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            client['first_name'] + ' ' + client['last_name'],
            style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                color: kTravailFuteSecondaryColor,
                fontSize: 18),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            client['email'].toString(),
            style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12),
          ),
          const SizedBox(
            height: 10,
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
              const SizedBox(
                width: 5,
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
              const SizedBox(
                width: 5,
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
