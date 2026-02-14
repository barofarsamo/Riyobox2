import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riyobox/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:riyobox/models/movie.dart';
import 'package:riyobox/core/constants.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _r2Files = [];
  bool _isLoadingR2 = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _backdropUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _yearController = TextEditingController();
  final _genreController = TextEditingController();
  final _durationController = TextEditingController();
  final _contentRatingController = TextEditingController();
  String _videoSourceType = 'upload'; // upload, url, library
  bool _isUploading = false;
  double _posterUploadProgress = 0;
  double _videoUploadProgress = 0;
  List<Movie> _movies = [];
  bool _isLoadingMovies = false;

  static const String _backendUrl = Constants.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMovies();
    _fetchR2Files();
  }

  Future<void> _fetchR2Files() async {
    setState(() => _isLoadingR2 = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/upload'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _r2Files = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching R2 files: $e');
    } finally {
      setState(() => _isLoadingR2 = false);
    }
  }

  void _deleteR2File(String key) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      final response = await http.delete(
        Uri.parse('$_backendUrl/upload/$key'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File deleted')));
        _fetchR2Files();
      }
    } catch (e) {}
  }

  Future<void> _fetchMovies() async {
    setState(() => _isLoadingMovies = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/admin/movies'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _movies = data.map((json) => Movie.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error fetching movies: $e');
    } finally {
      setState(() => _isLoadingMovies = false);
    }
  }

  Future<String?> _uploadFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type == 'poster' ? FileType.image : FileType.video,
    );

    if (result == null) return null;

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final file = result.files.first;

    dio.Dio client = dio.Dio();
    dio.MultipartFile multipartFile;

    if (kIsWeb) {
      multipartFile = dio.MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name
      );
    } else {
      multipartFile = await dio.MultipartFile.fromFile(
        file.path!,
        filename: file.name
      );
    }

    dio.FormData formData = dio.FormData.fromMap({
      "file": multipartFile,
    });

    try {
      final response = await client.post(
        "$_backendUrl/upload",
        data: formData,
        options: dio.Options(headers: {"Authorization": "Bearer $token"}),
        onSendProgress: (sent, total) {
          setState(() {
            if (type == 'poster') _posterUploadProgress = sent / total;
            else _videoUploadProgress = sent / total;
          });
        },
      );

      if (response.statusCode == 201) {
        return response.data['url'];
      }
    } catch (e) {
      print("Upload error: $e");
    }
    return null;
  }

  void _addMovie() async {
    if (_titleController.text.isEmpty) return;
    if (_posterUrlController.text.isEmpty || _videoUrlController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload files first')));
       return;
    }

    setState(() => _isUploading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/admin/movies'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'posterUrl': _posterUrlController.text,
          'backdropUrl': _backdropUrlController.text,
          'videoUrl': _videoUrlController.text,
          'year': int.tryParse(_yearController.text),
          'genre': _genreController.text.split(',').map((e) => e.trim()).toList(),
          'duration': _durationController.text,
          'contentRating': _contentRatingController.text,
          'isTrending': true, // New uploads are usually trending
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movie added successfully!')));
        _titleController.clear();
        _descriptionController.clear();
        _posterUrlController.clear();
        _backdropUrlController.clear();
        _videoUrlController.clear();
        _yearController.clear();
        _genreController.clear();
        _durationController.clear();
        _contentRatingController.clear();
        setState(() {
           _posterUploadProgress = 0;
           _videoUploadProgress = 0;
        });
        _fetchMovies();
        _tabController.animateTo(1);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _deleteMovie(String? id) async {
    if (id == null) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
     try {
      final response = await http.delete(
        Uri.parse('$_backendUrl/admin/movies/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movie removed')));
        _fetchMovies();
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('ADMIN PANEL', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF141414),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurpleAccent,
          isScrollable: true,
          tabs: const [
            Tab(text: 'UPLOAD MOVIE'),
            Tab(text: 'MOVIE LIST'),
            Tab(text: 'MEDIA LIBRARY'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadTab(),
          _buildManageTab(),
          _buildMediaLibraryTab(),
        ],
      ),
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      builder: (context) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('SELECT FROM STORAGE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _r2Files.isEmpty
                ? const Center(child: Text('No files found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _r2Files.length,
                    itemBuilder: (context, index) {
                      final file = _r2Files[index];
                      if (!file['key'].toString().endsWith('.mp4')) return const SizedBox();
                      return ListTile(
                        leading: const Icon(Icons.video_file, color: Colors.purpleAccent),
                        title: Text(file['key'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () {
                          _videoUrlController.text = file['url'];
                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Media selected')));
                        },
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('ADD NEW MOVIE', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildTextField(_titleController, 'Title'),
          const SizedBox(height: 16),
          _buildTextField(_descriptionController, 'Description', maxLines: 3),
          const SizedBox(height: 24),
          _buildFileUploadSection('poster', 'POSTER IMAGE', _posterUploadProgress, _posterUrlController),
          const SizedBox(height: 24),
          const Text('VIDEO SOURCE', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _sourceChip('upload', 'UPLOAD', Icons.upload_file),
              const SizedBox(width: 8),
              _sourceChip('url', 'URL', Icons.link),
              const SizedBox(width: 8),
              _sourceChip('library', 'STORAGE', Icons.folder_shared),
            ],
          ),
          const SizedBox(height: 16),
          if (_videoSourceType == 'upload')
            _buildFileUploadSection('video', 'VIDEO FILE', _videoUploadProgress, _videoUrlController)
          else if (_videoSourceType == 'url')
            _buildTextField(_videoUrlController, 'Enter direct video URL (MP4/HLS)')
          else
            Row(
              children: [
                Expanded(child: _buildTextField(_videoUrlController, 'No file selected', enabled: false)),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _showMediaPicker,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
                  child: const Text('PICK'),
                ),
              ],
            ),
          const SizedBox(height: 24),
          _buildTextField(_backdropUrlController, 'Backdrop Image URL (Optional)'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(_yearController, 'Year (e.g. 2024)', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_durationController, 'Duration (e.g. 1h 45m)')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(_genreController, 'Genres (Comma separated)'),
          const SizedBox(height: 16),
          _buildTextField(_contentRatingController, 'Maturity Rating (e.g. 13+, R)'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isUploading ? null : _addMovie,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isUploading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('UPLOAD MOVIE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaLibraryTab() {
    if (_isLoadingR2) return const Center(child: CircularProgressIndicator());
    if (_r2Files.isEmpty) return const Center(child: Text('No files in R2 storage.', style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      itemCount: _r2Files.length,
      itemBuilder: (context, index) {
        final file = _r2Files[index];
        final sizeMB = (file['size'] / (1024 * 1024)).toStringAsFixed(2);

        return ListTile(
          leading: Icon(
            file['key'].toString().contains('mp4') ? Icons.video_library : Icons.image,
            color: Colors.white54,
          ),
          title: Text(file['key'], style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('$sizeMB MB', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _deleteR2File(file['key']),
          ),
        );
      },
    );
  }

  Widget _buildManageTab() {
    if (_isLoadingMovies) return const Center(child: CircularProgressIndicator());
    if (_movies.isEmpty) return const Center(child: Text('No movies uploaded yet.', style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return ListTile(
          leading: Image.network(movie.posterPath, width: 50, height: 75, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.movie, color: Colors.grey)),
          title: Text(movie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(movie.releaseDate, style: const TextStyle(color: Colors.grey)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteMovie(movie.backendId),
          ),
        );
      },
    );
  }

  Widget _buildFileUploadSection(String type, String label, double progress, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(controller, 'URL will appear here...', enabled: false),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                final url = await _uploadFile(type);
                if (url != null) {
                  controller.text = url;
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
              child: const Text('SELECT'),
            ),
          ],
        ),
        if (progress > 0 && progress < 1.0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(value: progress, color: Colors.deepPurpleAccent, backgroundColor: Colors.white10),
          ),
      ],
    );
  }

  Widget _sourceChip(String type, String label, IconData icon) {
    final isSelected = _videoSourceType == type;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 10)),
        avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.grey),
        selected: isSelected,
        onSelected: (val) {
           if (val) setState(() => _videoSourceType = type);
        },
        selectedColor: Colors.deepPurpleAccent,
        backgroundColor: Colors.white10,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
      ),
    );
  }
}
