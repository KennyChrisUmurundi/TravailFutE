import 'package:flutter/material.dart';

class SearchEngine extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const SearchEngine({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(8),
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Poppins",
                ),
                hintText: "Recherche",
                contentPadding: EdgeInsets.all(7.0),
                border: InputBorder.none,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
