import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Explorer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FileExplorerPage(),
    );
  }
}

class FileExplorerPage extends StatefulWidget {
  const FileExplorerPage({super.key});

  @override
  _FileExplorerPageState createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage> {
  int _currentIndex = 0;
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search bar
  String _searchQuery = ''; // Search query to filter results
  final String _currentDirectory =
      '/storage/emulated/0'; // Example starting directory

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Explorer'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.toLowerCase(); // Update search query
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Storage line map (breadcrumb navigation)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.folder_open),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentDirectory, // Display current directory path
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _getSelectedPage(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Apps',
          ),
        ],
      ),
    );
  }

  // Get selected page content based on bottom navigation
  Widget _getSelectedPage() {
    switch (_currentIndex) {
      case 0:
        return ImageGallery(searchQuery: _searchQuery); // Pass search query
      case 1:
        return const VideoPlayerPage();
      case 2:
        return const InstalledAppsPage();
      default:
        return FileExplorer(
            searchQuery: _searchQuery,
            currentDirectory:
                _currentDirectory); // Pass search query and current directory
    }
  }
}

class FileExplorer extends StatefulWidget {
  final String searchQuery; // Accept search query
  final String currentDirectory; // Accept current directory path

  const FileExplorer(
      {super.key, required this.searchQuery, required this.currentDirectory});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  final List<String> _files = [
    'File1.txt',
    'File2.jpg',
    'File3.mp4',
    'File4.docx'
  ]; // Sample file names
  List<String> _filteredFiles = [];

  @override
  void initState() {
    super.initState();
    _filteredFiles = _files; // Initialize with all files
  }

  @override
  void didUpdateWidget(FileExplorer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Filter files whenever the search query changes
    setState(() {
      _filteredFiles = _files
          .where((file) =>
              file.toLowerCase().contains(widget.searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_filteredFiles[index]),
        );
      },
    );
  }
}

class ImageGallery extends StatelessWidget {
  final String searchQuery;

  const ImageGallery({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // Implement your gallery and filter images based on searchQuery
    return Center(child: Text('Images Gallery - Search: $searchQuery'));
  }
}

class VideoPlayerPage extends StatelessWidget {
  const VideoPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Video Player'));
  }
}

class InstalledAppsPage extends StatelessWidget {
  const InstalledAppsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Installed Apps'));
  }
}
