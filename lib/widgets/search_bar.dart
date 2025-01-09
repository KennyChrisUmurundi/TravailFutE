import 'package:flutter/material.dart';
// import 'package:travail_fute/screens/clients.dart';

class SearchEngine extends StatefulWidget {
  const SearchEngine({super.key});

  @override
  State<SearchEngine> createState() => _SearchEngineState();
}

class _SearchEngineState extends State<SearchEngine> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(8),
      height: 45,
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: Colors.grey,
        //   width: 0.2,
        // ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: const Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Poppins",
                ),
                hintText: "Recherche",
                contentPadding: EdgeInsets.all(7.0),
                border: InputBorder.none,
                // icon: Icon(Icons.search)
              ),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {
          //     // Implement your search logic here
          //   },
          // ),
        ],
      ),
    );
  }
}
