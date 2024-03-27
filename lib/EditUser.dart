import 'package:flutter/material.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EditUserScreen extends StatefulWidget {
  final User? user;
  final Function onUserEdited;

  EditUserScreen({required this.user,required this.onUserEdited});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Populate controllers with user data
    if (widget.user != null) {
      idController.text = widget.user!.id;
      firstNameController.text = widget.user!.firstName;
      lastNameController.text = widget.user!.lastName;
      nationalIdController.text = widget.user!.nationalId;
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: nationalIdController,
              decoration: InputDecoration(labelText: 'National ID'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                editUser();
              },
              child: Text('edit user'),
            ),
          ],
        ),
      ),
    );
  }



  void editUser() async {
    // Get values from controllers
    String id = idController.text;
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String nationalId = nationalIdController.text;

    // Prepare the data to be sent in the request body
    Map<String, dynamic> userData = {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'nationalId': nationalId,
    };

    // Convert the data to JSON format
    String jsonData = jsonEncode(userData);

    // Send a PUT request to update the user on the API
    Uri apiUrl = Uri.parse('http://192.168.1.189:3000/users/$id');
    http.Response response = await http.put(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );

    // Check the response status
    if (response.statusCode == 200) {
      // User updated successfully
      widget.onUserEdited();
      Navigator.pop(context);
    } else {
      // Handle error, display a message, etc.
      print('Failed to update user. Status code: ${response.statusCode}');
      // You might want to show an error message to the user here
    }
  }
}