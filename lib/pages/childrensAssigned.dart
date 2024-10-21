import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/widgets/customAppBar.dart';

import '../widgets/cards/cards.dart';

class ChildrenAssigned extends StatelessWidget {
  final List<Map<String, String>>? children;

  const ChildrenAssigned({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Children Assigned",
          backgroundColor: Colors.green.shade900, textColor: Colors.white),
      body: children == null || children!.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care, // You can use any icon representing children
              size: 80,
              color: Colors.grey.shade400, // A faint color for the icon
            ),
            const SizedBox(height: 20), // Spacing between icon and text
            Text(
              'No children assigned',
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade600, // A subtle color for the text
                fontWeight: FontWeight.w600, // Slightly bold for prominence
                letterSpacing: 1.0, // Slight letter spacing for readability
              ),
              textAlign: TextAlign.center, // Center align text
            ),
            const SizedBox(height: 10),
            Text(
              'Please assign children to view them here.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500, // Lighter color for secondary text
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )

          : ListView.builder(
              itemCount: children!.length,
              itemBuilder: (context, index) {
                var child = children![index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AdvancedCard(
                    cardTitle: child['name']!,
                    cardInfo: child['phone']!, // Use correct key 'phone'
                    cardIcons: Icons.girl,
                  ),
                );
              },
            ),
    );
  }
}
