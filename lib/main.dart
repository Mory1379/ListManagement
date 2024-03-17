import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'EditUser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }


  Future<void> loadUsers() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.200:3000/users'));

      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body);
        setState(() {
          users = usersJson.map((user) => User.fromJson(user)).toList();
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${users[index].firstName} ${users[index].lastName}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsScreen(user: users[index]),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder:(context) => EditUserScreen(
                            user: users[index],
                            onUserEdited: loadUsers,
                          ),
                      )
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                        title: Text('حذف کاربر'),
                        content: Text('آیا از حذف کاربر ${users[index].firstName} ${users[index].lastName} مطمئن هستید؟'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context,false);
                            },
                            child: Text('خیر'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await deleteUser(users[index]);
                              Navigator.pop(context, true);
                            },
                            child: Text('بله'),
                          )
                        ],
                        ),
                    ).then((result) {
                      if (result != null && result) {
                        //reload users after deletion
                        loadUsers();
                      }
                    });
                  },
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddUserScreen(onUserEdited: loadUsers, user: null,),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  deleteUser(User user) {}
}

Future<void> deleteUser(User user) async {
  try {
    final response = await http.delete(
      Uri.parse('http://192.168.1.200:3000/users/${user.nationalId}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('User deleted successfully');
    } else {
      // Handle unsuccessful response
      print('Failed to delete user. Status code: ${response.statusCode}');
      // Optionally, you can handle different status codes differently
      if (response.statusCode == 404) {
        print('User not found on the server');
      }
      // You might want to show an error message to the user here
      throw Exception('Failed to delete user');
    }
  } catch (e) {
    // Handle exceptions
    print('Error deleting user: $e');
    // You might want to show an error message to the user here
  }
}

class UserDetailsScreen extends StatelessWidget {
  final User user;

  UserDetailsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.firstName} ${user.lastName}'),
            Text('National ID: ${user.nationalId}'),
          ],
        ),
      ),
    );
  }
}

class AddUserScreen extends StatefulWidget {
  final User? user;
  final Function onUserEdited;

  AddUserScreen({required this.user,required this.onUserEdited});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
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
        title: Text('Add User'),
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
                addUser();
              },
              child: Text('Save user'),
            ),
          ],
        ),
      ),
    );
  }


  void addUser() async {
    String id = idController.text;
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String nationalId = nationalIdController.text;

    if (firstName.isNotEmpty && lastName.isNotEmpty && nationalId.isNotEmpty) {
      User newUser = User(
        id: id, // You may set an appropriate value for the ID or leave it empty if it's generated by the server.
        firstName: firstName,
        lastName: lastName,
        nationalId: nationalId,
      );
      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.200:3000/users'),
          body: json.encode(newUser.toJson()),
          headers: {'Content-Type': 'application/json'},
        );


        if (response.statusCode == 201) {
          widget.onUserEdited();
          Navigator.pop(context);
        } else {
          throw Exception('Failed to add user');
        }
      } catch (e) {
        print('Error adding user: $e');
        if (e is http.Response) {
          print('Response body: ${e.body}');
        }
      }
    } else {
      // Show an error message or handle empty fields.
    }
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String nationalId;

  User({required this.id,required this.firstName, required this.lastName, required this.nationalId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      nationalId: json['nationalId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'nationalId': nationalId,
    };
  }
}
