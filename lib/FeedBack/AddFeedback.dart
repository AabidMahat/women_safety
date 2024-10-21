import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety/FeedBack/FeedBackMap.dart';
import 'package:women_safety/api/FeedbackApi.dart';
import 'package:women_safety/api/mapApi.dart';

import '../widgets/Button/ResuableButton.dart';
import '../widgets/TextField/TextField.dart';
import '../widgets/customAppBar.dart';


class AddFeedback extends StatefulWidget {
  final LatLng position;

  const AddFeedback({super.key, required this.position});

  @override
  State<AddFeedback> createState() => _AddFeedbackState();
}

class _AddFeedbackState extends State<AddFeedback> {
  MapApi mapApi = MapApi();
  FeedbackApi feedbackApi = FeedbackApi();
  TextEditingController placeName = TextEditingController();
  String? category;
  bool isSubmitted = false;
  TextEditingController review = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPlaceName(); // Fetch place name asynchronously
  }

  Future<void> _fetchPlaceName() async {
    String fetchedPlaceName = await mapApi.getPlace(
        widget.position.latitude, widget.position.longitude);
    setState(() {
      placeName.text = fetchedPlaceName;
    });
    print(fetchedPlaceName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Add Feedback",onPressed: (){},),
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
            AdvanceTextField(
              controller: review,
              type: TextInputType.text,
              label: "Review",
              prefixIcon: Icon(Icons.location_on),
            ),
            DropdownButtonFormField<String>(
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
              height: 20,
            ),
            AdvanceButton(
              onPressed: () async {
                await feedbackApi.createFeedback(
                    widget.position, review.text, category!);

                Navigator.pop(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FeedbackScreen(
                              currentPosition: LatLng(widget.position.latitude,
                                  widget.position.longitude),
                            )));
              },
              buttonText: "Add Review",
              backgroundColor: Colors.green.shade900,
            )
          ],
        ),
      )),
    );
  }
}
