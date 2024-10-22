import 'package:flutter/material.dart';
import 'api_services.dart';
import 'firestore_servicres.dart';
import 'image_model.dart'; // Import your image model

class ImageSearchScreen extends StatefulWidget {
  @override
  _ImageSearchScreenState createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  List<ImageModel> _images = [];
  List<String> _searchHistory = [];
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController(); // Add a ScrollController
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _perPage = 10;
  String _searchQuery = '';
  bool _isSearchFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _fetchImages(); // Call fetch images here for initial load

    // Add listener to the ScrollController
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchImages(); // Load more images when reaching the bottom
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  // Load search history from Firestore
  Future<void> _loadSearchHistory() async {
    try {
      final history = await _firestoreService.getSearchHistory();
      setState(() {
        _searchHistory = history;
      });
    } catch (error) {
      print("Error loading search history: $error");
    }
  }

  // Fetch images based on the current page
  Future<void> _fetchImages() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final images = await _apiService.fetchImages(page: _currentPage, perPage: _perPage);
      setState(() {
        _images.addAll(images);
        _currentPage++;
        _hasMore = images.length == _perPage; // Check if there are more images
      });
    } catch (error) {
      print("Error fetching images: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Search for images based on the query
  Future<void> _searchImages(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _searchQuery = query;
      _images.clear();
      _currentPage = 1;
      _hasMore = true;
      _isSearchFieldFocused = false;
    });

    _focusNode.unfocus(); // Hide keyboard

    try {
      final images = await _apiService.searchImages(query, page: _currentPage, perPage: _perPage);
      setState(() {
        _images.addAll(images);
        _hasMore = images.length == _perPage; // Check if more images are available
        _currentPage++;

        if (images.isEmpty) {
          _showNoResultsFoundDialog();
        }
      });

      await _firestoreService.saveSearchHistory(query);
      _loadSearchHistory(); // Refresh the search history
    } catch (error) {
      print("Error searching images: $error");
    } finally {
      setState(() {
        _isLoading = false; // End loading state
      });
    }
  }

  void _showNoResultsFoundDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Results Found'),
          content: Text('Sorry, no images match your search query.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unsplash Images'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onSubmitted: (query) {
                _searchImages(query);
                _searchController.clear(); // Clear the text field after search
              },
              decoration: InputDecoration(
                hintText: 'Search for images...',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onTap: () {
                setState(() {
                  _isSearchFieldFocused = true; // Show dropdown when search field is focused
                });
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isSearchFieldFocused && _searchHistory.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchHistory.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Text(
                          _searchHistory[index],
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        _searchImages(_searchHistory[index]);
                        _focusNode.unfocus(); // Unfocus the text field
                        _searchController.clear(); // Clear the text field after selection
                      },
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Use the ScrollController
              padding: EdgeInsets.all(15),
              itemCount: _images.length + (_isLoading ? 1 : 0), // Show loading indicator if loading
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return Center(child: CircularProgressIndicator()); // Loading indicator at the bottom
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        Image.network(
                          _images[index].urls.regular,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
