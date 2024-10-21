import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Database/Database.dart';
import '../api/User.dart';
import '../widgets/Button/ResuableButton.dart';
import '../widgets/customAppBar.dart';
import 'AddFeedback.dart';

class FeedbackReview extends StatefulWidget {
  final FeedbackData feedback; // The feedback you are reviewing
  final List<FeedbackData> feedbackList; // List of all feedbacks

  const FeedbackReview(
      {super.key, required this.feedback, required this.feedbackList});

  @override
  State<FeedbackReview> createState() => _FeedbackReviewState();
}

class _FeedbackReviewState extends State<FeedbackReview>
    with SingleTickerProviderStateMixin {
  UserApi userApi = UserApi();
  late String name = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: customAppBar("Feedback Reviews",
            onPressed: () {},
            backgroundColor: Colors.green.shade900,
            textColor: Colors.white),
        body: Container(
          color: Colors.grey.shade50, // Soft light grey background
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: widget.feedbackList.length,
            itemBuilder: (context, index) {
              final feedbackItem = widget.feedbackList[index];

              // Compare latitude and longitude of feedbackItem with the current location's feedback
              bool isSameLocation = widget.feedback.location['latitude'] ==
                      feedbackItem.location['latitude'] &&
                  widget.feedback.location['longitude'] ==
                      feedbackItem.location['longitude'];

              if (isSameLocation) {
                print("Feedback ${feedbackItem.userName}");
                String? name = feedbackItem.userName ??
                    feedbackItem.guardianName ??
                    'Unknown';
                String? role = feedbackItem.userRole ??
                    feedbackItem.guardianRole ??
                    'Unknown';

                return GestureDetector(
                  onTap: () {
                    // Optional: Add some action on tap
                  },
                  child: Card(
                    elevation: 5, // Increased elevation for a bold look
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
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 4), // Shadow position
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        // Consistent padding
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 25, // Larger avatar
                              backgroundImage: NetworkImage(
                                  "https://cdn.icon-icons.com/icons2/1378/PNG/512/avatardefault_92824.png"),
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
                                          "$name ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            // Larger font size for names
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (role!.isNotEmpty)
                                        Text(
                                          "($role)",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.green.shade900,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Review:",
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          feedbackItem.comments,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            // Consistent font size
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
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
          child: AdvanceButton(
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
            // Increase vertical padding
          ),
        ),
      ),
    );
  }
}
