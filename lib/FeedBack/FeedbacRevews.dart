import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety/api/FeedbackApi.dart';
import 'package:women_safety/api/User.dart';

import '../Database/Database.dart';
import '../widgets/Button/ResuableButton.dart';
import '../widgets/customAppBar.dart';
import 'AddFeedback.dart';
import 'EditReview.dart';

class FeedbackReview extends StatefulWidget {
  final FeedbackData feedback;
  final List<FeedbackData> feedbackList;

  const FeedbackReview(
      {super.key, required this.feedback, required this.feedbackList});

  @override
  State<FeedbackReview> createState() => _FeedbackReviewState();
}

class _FeedbackReviewState extends State<FeedbackReview>
    with SingleTickerProviderStateMixin {
  late String name = "";
  Map<String, dynamic> output = {};
  FeedbackData? currentFeedback;
  bool isPresent = false;
  Set<int> expandedItems = {}; // Holds the indices of expanded items

  @override
  void initState() {
    super.initState();
    checkFeedbackPresent();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Dangerous':
        return Colors.red.shade700;
      case 'Suspicious':
        return Colors.orange.shade600;
      case 'Safe':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade400;
    }
  }

  Future<void> checkFeedbackPresent() async {
    output = await FeedbackApi().checkFeedbackAlreadyPresent(
      LatLng(
        widget.feedback.location['latitude']!,
        widget.feedback.location['longitude']!,
      ),
    );

    setState(() {
      isPresent = output['isPresent'];
      currentFeedback = FeedbackData.fromJson(output['data']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: customAppBar("Feedback Reviews", onPressed: () {
          Navigator.pop(context);
        },
            backgroundColor: Colors.green.shade900,
            leadingIcon: Icons.arrow_back,
            textColor: Colors.white),
        body: Container(
          color: Colors.grey.shade50,
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: widget.feedbackList.length,
            itemBuilder: (context, index) {
              final feedbackItem = widget.feedbackList[index];

              bool isSameLocation = widget.feedback.location['latitude'] ==
                  feedbackItem.location['latitude'] &&
                  widget.feedback.location['longitude'] ==
                      feedbackItem.location['longitude'];

              if (isSameLocation) {
                String name = feedbackItem.userName ??
                    feedbackItem.guardianName ??
                    'Unknown';

                String avatar = feedbackItem.userAvatar ??
                    feedbackItem.guardianAvatar ??
                    "https://cdn.icon-icons.com/icons2/1378/PNG/512/avatardefault_92824.png";

                String role = feedbackItem.userRole ??
                    feedbackItem.guardianRole ??
                    'Unknown';

                bool isExpanded = expandedItems.contains(index);

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(avatar),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (role.isNotEmpty)
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "($role)",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                  height: 15,
                                ),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final text = feedbackItem.comments;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Review:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade800,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          text,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),


                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(
                                          feedbackItem.category)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      feedbackItem.category,
                                      style: TextStyle(
                                        color: _getCategoryColor(
                                            feedbackItem.category),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: isPresent
              ? AdvanceButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditReview(
                          position: LatLng(
                              widget.feedback.location['latitude']!,
                              widget.feedback.location['longitude']!),
                          feedback:currentFeedback!)));
            },
            buttonText: "Edit Review",
            backgroundColor: Colors.green.shade900,
          )
              : AdvanceButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddFeedback(
                          position: LatLng(
                              widget.feedback.location['latitude']!,
                              widget.feedback.location['longitude']!))));
            },
            buttonText: "Add New Review",
            backgroundColor: Colors.green.shade900,
          ),
        ),
      ),
    );
  }
}

