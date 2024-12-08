import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  List<FileSystemEntity> _files = [];
  List<FileSystemEntity> _filteredFiles = [];
  bool _isLoading = true;
  FileSystemEntity? _copiedFile;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFiles();
    _searchController.addListener(_filterFiles);
  }

  // Load files from the directory
  Future<void> _loadFiles() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final files = Directory(directory!.path).listSync();
      setState(() {
        _files = files;
        _filteredFiles = files;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Permission Denied")));
    }
  }

  // Create a new folder
  Future<void> _createNewFolder() async {
    final directory = await getExternalStorageDirectory();
    final folderName = 'NewFolder_${DateTime.now().millisecondsSinceEpoch}';
    final folderPath = Directory('${directory!.path}/$folderName');
    folderPath.createSync();

    Fluttertoast.showToast(msg: "New folder created");

    _loadFiles(); // Refresh file list
  }

  // Delete a file/folder
  Future<void> _deleteFile(FileSystemEntity file) async {
    try {
      file.deleteSync(recursive: true); // Deletes file/folder
      Fluttertoast.showToast(msg: "File/Folder Deleted");
      _loadFiles(); // Refresh file list
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting file/folder");
    }
  }

  // Copy a file/folder
  Future<void> _copyFile(FileSystemEntity file) async {
    setState(() {
      _copiedFile = file;
    });
    Fluttertoast.showToast(msg: "File Copied! Now select a location to paste.");
  }

  // Paste the copied file/folder
  Future<void> _pasteFile() async {
    if (_copiedFile != null) {
      final directory = await getExternalStorageDirectory();
      final destination =
          File('${directory!.path}/${_copiedFile!.uri.pathSegments.last}');
      _copiedFile!.copySync(destination.path);
      Fluttertoast.showToast(msg: "File/Paste completed");
      _loadFiles(); // Refresh file list
    }
  }

  // Filter files based on search query
  void _filterFiles() {
    setState(() {
      _filteredFiles = _files
          .where((file) => file.uri.pathSegments.last
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredFiles.length,
              itemBuilder: (context, index) {
                final file = _filteredFiles[index];
                return ListTile(
                  title: Text(file.path.split('/').last),
                  onTap: () {
                    // Handle opening files here (optional)
                  },
                  onLongPress: () {
                    // Show context menu
                    _showContextMenu(file);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewFolder,
        tooltip: "Create New Folder",
        child: const Icon(Icons.create_new_folder),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                if (_copiedFile != null) {
                  _pasteFile();
                } else {
                  Fluttertoast.showToast(msg: "No file copied.");
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (_copiedFile != null) {
                  _deleteFile(_copiedFile!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Context menu for delete and copy options
  void _showContextMenu(FileSystemEntity file) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Action'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _copyFile(file);
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteFile(file);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

extension on FileSystemEntity {
  void copySync(String path) {}
}
