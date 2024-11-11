import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/FeedBack/FeedBackMap.dart';
import 'package:women_safety/api/FeedbackApi.dart';
import 'package:women_safety/api/mapApi.dart';
import 'package:women_safety/widgets/TextField/TestArea.dart';

import '../widgets/Button/ResuableButton.dart';
import '../widgets/TextField/TextField.dart';
import '../widgets/customAppBar.dart';

class EditReview extends StatefulWidget {
  final LatLng position;
  final FeedbackData feedback;

  const EditReview({super.key, required this.position, required this.feedback});

  @override
  State<EditReview> createState() => _EditReviewState();
}

class _EditReviewState extends State<EditReview> {
  MapApi mapApi = MapApi();
  FeedbackApi feedbackApi = FeedbackApi();
  TextEditingController placeName = TextEditingController();
  String? category;
  bool isSubmitted = false;
  TextEditingController review = TextEditingController();

  Future<void> _fetchPlaceName() async {
    String fetchedPlaceName = await mapApi.getPlace(
        widget.position.latitude, widget.position.longitude);
    setState(() {
      placeName.text = fetchedPlaceName;
    });
    print(fetchedPlaceName);
  }

  @override
  void initState() {
    super.initState();
    _fetchPlaceName(); // Fetch place name asynchronously
    setData();
  }

  void setData() {
    setState(() {
      review.text = widget.feedback.comments;
      category =
          widget.feedback.category ?? "Safe"; // Default to a value if null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Modify Feedback",
          onPressed: () {}, leadingIcon: Icons.arrow_back),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            children: [
              AdvanceTextField(
                controller: placeName,
                type: TextInputType.text,
                label: "Place",
                readOnly: true,
              ),
              SizedBox(
                height: 10,
              ),
              AdvanceTextArea(
                controller: review,
                label: "Review",
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: category,
                // Set the initial selected value
                decoration: InputDecoration(
                  labelText: "Type",
                  prefixIcon: Icon(Icons.merge_type),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF1F4F8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green.shade900,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF1F4F8),
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade900),
                items: ["Dangerous", "Suspicious", "Safe"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    category = newValue;
                  });
                },
              ),
              SizedBox(
                height: 25,
              ),
              AdvanceButton(
                onPressed: () async {
                  await feedbackApi.updateFeedback(
                    widget.feedback.id,
                    review.text,
                    category!,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackScreen(
                        currentPosition: LatLng(
                          widget.position.latitude,
                          widget.position.longitude,
                        ),
                      ),
                    ),
                  );
                },
                buttonText: "Edit Review",
                backgroundColor: Colors.green.shade900,
              ),


            ],
          ),
        ),
      ),
    );
  }
}
