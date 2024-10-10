import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'chat_page.dart'; // For kIsWeb

class SearchUserPage extends StatefulWidget {
  final String username;
  final String targetUser;

  const SearchUserPage({
    Key? key,
    required this.username,
    required this.targetUser,
  }) : super(key: key);
  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults =
      []; // Use List<Map<String, dynamic>>

  Future<void> _searchUsers() async {
    String searchQuery = _searchController.text;

    try {
      var url = kIsWeb
          ? 'http://localhost:3000/search?username=$searchQuery'
          : 'http://10.0.2.2:3000/search?username=$searchQuery';

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          if (responseData is List) {
            // If the response is a list, iterate over it
            _searchResults = responseData
                .map<Map<String, dynamic>>(
                  (item) => item as Map<String, dynamic>,
                )
                .toList();
          } //else if (responseData is Map) {
          // If the response is a single object, wrap it in a list
          //    _searchResults = [responseData as Map<String, dynamic>];
          // }
        });
        //setState(() {
        // _searchResults = jsonDecode(response.body);
        // });
      } else {
        print('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No users found')),
        );
      }
    } catch (e, stacktrace) {
      print('Error: $e');
      print('Stacktrace: $stacktrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _startChat(String targetUser) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(username: widget.username, targetUser: targetUser)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search for User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a user',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUsers,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    title: Text(user['username']),
                    onTap: () => _startChat(user['username']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
