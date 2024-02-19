// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appi The Pug',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        appBarTheme: const AppBarTheme(
          color: Colors.blue, // Cambia el color de fondo de la AppBar aquí
        ),
      ),
      home: const DogScreen(),
    );
  }
}

class DogScreen extends StatefulWidget {
  const DogScreen({Key? key}) : super(key: key);

  @override
  _DogScreenState createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  String _searchQuery = '';
  String _dogImageUrl = '';
  String _dogBreed = '';
  String _dogLifeSpan = '';
  final String _apiKey =
      'live_29xWJDuZAAfQc1Ymvt9E51MTd108iO4Igbaa2WZvyLbB7xa9XPrmkGiuehbJeyFb';

  Future<void> _fetchDogImage(String breedName) async {
    final response = await http.get(
      Uri.parse('https://api.thedogapi.com/v1/breeds/search?q=$breedName'),
      headers: {'x-api-key': _apiKey},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final breedId = data[0]['id'];
        final breedResponse = await http.get(
          Uri.parse(
              'https://api.thedogapi.com/v1/images/search?breed_id=$breedId'),
          headers: {'x-api-key': _apiKey},
        );
        if (breedResponse.statusCode == 200) {
          final List<dynamic> breedData = jsonDecode(breedResponse.body);
          if (breedData.isNotEmpty) {
            setState(() {
              _dogImageUrl = breedData[0]['url'];
              _dogBreed = breedData[0]['breeds'][0]['name'];
              _dogLifeSpan = breedData[0]['breeds'][0]['life_span'];
            });
            return;
          }
        }
      } else {
        setState(() {
          _dogImageUrl =
              'https://78.media.tumblr.com/2bc94b9eec2d00f5d28110ba191da896/tumblr_nyled8DYKd1qg9kado1_1280.jpg';
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Appi PUG'),
              content: const Text(
                  'No images found for the entered dog breed. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      throw Exception('Failed to load dog image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dogs Breed Search Appi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Dog breed'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _fetchDogImage(_searchQuery);
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),
            _dogImageUrl.isNotEmpty
                ? Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          _dogImageUrl,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Breed: $_dogBreed',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Life Span: $_dogLifeSpan',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
