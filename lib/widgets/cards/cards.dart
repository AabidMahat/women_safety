import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdvancedCard extends StatelessWidget {
  final String cardTitle;
  final String cardInfo;
  final IconData cardIcons;
  final Widget? child; // Optional child parameter

  const AdvancedCard({
    super.key,
    required this.cardTitle,
    required this.cardInfo,
    required this.cardIcons,
    this.child, // Initialize child here
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.blue.shade100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                cardIcons,
                color: Colors.blue.shade700,
                size: 30,
              ),
              title: Text(
                cardTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                cardInfo,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            if (child != null) child!, // Display child if it exists
          ],
        ),
      ),
    );
  }
}
