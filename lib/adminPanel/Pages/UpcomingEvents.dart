import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_web/flutter_google_places_web.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';
class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents({Key? key}) : super(key: key);

  @override
  State<UpcomingEvents> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  bool _isUploading = false; // Add this variable to track whether data is being uploaded

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  TextEditingController eventDetailsController = TextEditingController(),
      organizerNameController = TextEditingController(),
      priceController = TextEditingController(),
      dateController = TextEditingController(),
      timeController = TextEditingController(),
      locationController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
      TextEditingController aboutController = TextEditingController();

  html.File? eventImageFile;
  html.File? logoImageFile;

  void chooseEventImage() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        setState(() {
          eventImageFile = files[0];
        });
      }
    });
  }

  void chooseLogoImage() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        setState(() {
          logoImageFile = files[0];
        });
      }
    });
  }
  void _showUploadSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Successful'),
          content: Text('Your event has been uploaded successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<Map<String, dynamic>> coordindates(String address) async {
    final apiKey = 'AIzaSyCvlE2XcxEXl5B3nrOQkwlkQ4Wnn_8oUPI';
    final encodedAddress = Uri.encodeQueryComponent(address);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return {
          'latitude': location['lat'],
          'longitude': location['lng'],
        };
      }
    }
    throw Exception('Failed to fetch coordinates for the provided address.');
  }
  Future<void> uploadUpcomingEvents() async {
    try {
      if (organizerNameController.text.isEmpty ||
          eventDetailsController.text.isEmpty ||
          priceController.text.isEmpty ||
          dateController.text.isEmpty ||
          aboutController.text.isEmpty ||
          timeController.text.isEmpty ||
          locationController.text.isEmpty ||
          categoryController.text.isEmpty ||
          eventImageFile == null || // Check if event image is provided
          logoImageFile == null) { // Check if logo image is provided) {
        return;
      }
      final coordinates = await coordindates(locationController.text);
      final double latitude = coordinates['latitude'];
      final double longitude = coordinates['longitude'];
      String eventImage = await uploadImageEvents(eventImageFile!);
      String logoImageURL = await uploadImage(logoImageFile!);

      String eventId = Uuid().v4();

      await _firestore.collection('UpcomingEventData').add({
        'eventId': eventId, // Store the event ID
        'organizerName': organizerNameController.text,
        'eventDetails': eventDetailsController.text,
        'price': priceController.text,
        'date': dateController.text,
        'time': timeController.text,
        'location': locationController.text,
        'latitude': latitude, // Add latitude to Firestore
        'longitude': longitude, // Add longitude to Firestore
        'eventImage': eventImage,
        'logoImage': logoImageURL,
        'about': aboutController.text,
        'category': categoryController.text,
        'timestamp': FieldValue.serverTimestamp(), // Add timestamp field
        // Add other fields as needed
      });

      _showUploadSuccessDialog(context);

      organizerNameController.clear();
      eventDetailsController.clear();
      priceController.clear();
      dateController.clear();
      timeController.clear();
      locationController.clear();
      aboutController.clear();
      categoryController.clear();

      // Clear image file names
      setState(() {
        eventImageFile = null;
        logoImageFile = null;
      });
    } catch (error) {
      // Show snackbar with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload data: $error'),
        ),
      );
    }
  }



  Future<String> uploadImageEvents(html.File imageFile) async {
    final url = html.Url.createObjectUrlFromBlob(imageFile);

    Reference ref = _storage.ref().child('event_images').child(imageFile.name);
    UploadTask uploadTask = ref.putBlob(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    // Revoke the blob URL after uploading
    html.Url.revokeObjectUrl(url);

    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadImage(html.File imageFile) async {
    final url = html.Url.createObjectUrlFromBlob(imageFile);

    Reference ref = _storage.ref().child('logo_images').child(imageFile.name);
    UploadTask uploadTask = ref.putBlob(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    // Revoke the blob URL after uploading
    html.Url.revokeObjectUrl(url);

    return await snapshot.ref.getDownloadURL();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 41, 41, 1),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Upcoming Events',
                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
              ),
            ),
            buildFilePicker('Event Image', chooseEventImage),
            buildFilePicker('Organizer Logo', chooseLogoImage),
            Row(
              children: [
                buildTextField('Event Category', categoryController),
                buildTextField('Organizer Name', organizerNameController),
              ],
            ),
            Container(
                width: double.infinity,
                child: buildTextField('Event Details', eventDetailsController)),

            Row(
              children: [
                // buildTextField('Location', locationController),
                SizedBox(width: 20,),
                Container(
                  width: 350,
                  child:
                  FlutterGooglePlacesWeb(
                    apiKey: 'AIzaSyCvlE2XcxEXl5B3nrOQkwlkQ4Wnn_8oUPI',
                    proxyURL: 'https://cors-anywhere.herokuapp.com/',
                    decoration:  InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.brown.shade300,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.17)),
                      ),


                      labelText: 'Location',
                      labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
                      // hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      // Customize other properties as needed
                    ),
                    controller: locationController,
                    required: true,
                  ),



                ),
                buildTextField('Price', priceController, addDollarSign: true),

              ],
            ),
            Row(

              children: [
                buildTextField('Date', dateController, onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                  }
                }),

                buildTextField('Time', timeController, onTap: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    timeController.text = selectedTime.format(context);
                  }
                }),

              ],
            ),
            Container(
                width: double.infinity,
                child: buildTextField('About Event', aboutController)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (organizerNameController.text.isEmpty ||
                    eventDetailsController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    dateController.text.isEmpty ||
                    aboutController.text.isEmpty ||
                    timeController.text.isEmpty ||
                    categoryController.text.isEmpty ||
                    locationController.text.isEmpty ||
                    eventImageFile == null || // Check if event image is provided
                    logoImageFile == null) { // Check if logo image is provided) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // Stop further execution
                }
                // Set _isUploading to true to show loader
                setState(() {
                  _isUploading = true;
                });
                // Call the upload function without passing context
                uploadUpcomingEvents().then((_) {
                  // Set _isUploading to false when upload is complete
                  setState(() {
                    _isUploading = false;
                  });
                });
              },
              child: _isUploading
                  ? CircularProgressIndicator() // Show loader if uploading
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Add Your Event',style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600,fontSize: 20),),
              ), // Show button text if not uploading // Show button text if not uploading
            ),



          ],
        ),
      ),
    );
  }
  Widget buildTextField(String labelText, TextEditingController controller, {bool addDollarSign = false, String? errorText, Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: SizedBox(
        width: 350,
        child: TextField(
          controller: controller,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.17)),
              borderRadius: BorderRadius.circular(10),
            ),
            errorText: errorText, // Display error text if it's not null
            prefixText: addDollarSign ? '\$' : null, // Prefix with dollar sign if required
            prefixStyle: TextStyle(color: Colors.black),
            filled: true, // Add this line to enable filling the background
            fillColor: Colors.brown.shade300, // Set the background color
          ),
          onTap: onTap, // Call the onTap function when the text field is tapped
          readOnly: onTap != null, // Make the text field read-only if onTap is provided
        ),
      ),
    );
  }


  Widget buildFilePicker(String label, VoidCallback onPressed) {
    bool isFileChosen = label == 'Event Image'
        ? eventImageFile != null
        : logoImageFile != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: Colors.grey.withOpacity(0.17)),

        ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 40),
                    Text(
                      isFileChosen
                          ? label == 'Event Image'
                          ? eventImageFile!.name
                          : logoImageFile!.name
                          : 'No Image chosen',
                      style: TextStyle(
                        color: isFileChosen ? Colors.white : Colors.red,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: onPressed,
                       icon: Image.asset('assets/images/add.png',width: 30, height: 30,color: Colors.white,),

                    ),
                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }

}