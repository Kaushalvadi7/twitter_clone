import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/auth/auth_service.dart';
import '../services/cloudinary/cloudinary_service.dart';
import '../services/database/database_provider.dart';

class PostMessagePage extends StatefulWidget {
  const PostMessagePage({super.key});

  @override
  State<PostMessagePage> createState() => _PostMessagePageState();
}

class _PostMessagePageState extends State<PostMessagePage> {
  final TextEditingController _messageController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;
  final FocusNode _focusNode = FocusNode();

  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    //Request
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final uid = AuthService().getCurrentUserid();
    final user = await Provider.of<DatabaseProvider>(
      context,
      listen: false,
    ).userProfile(uid);
    setState(() {
      _currentUser = user;
    });
  }

  void _showEmptyPostAlert() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Empty Post'),
            content: const Text("Please write something before posting."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _postMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedImage == null) {
      _showEmptyPostAlert();
      return;
    }

    setState(() => _isPosting = true);

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await CloudinaryService.uploadImageToCloudinary(
        _selectedImage!,
      );
    }

    await Provider.of<DatabaseProvider>(
      context,
      listen: false,
    ).postMessage(_messageController.text.trim(), imageUrl: imageUrl);

    setState(() => _isPosting = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _postMessage,
            child:
                _isPosting
                    ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : const Text(
                      'Post',
                      style: TextStyle(
                        color: Color(0xFF1DA1F2),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _currentUser != null
                      ? (_currentUser!.profileImageUrl != null && _currentUser!.profileImageUrl!.isNotEmpty
                      ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(_currentUser!.profileImageUrl!),
                  )
                      : CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 30, color: Colors.black),
                  )
                  )
                      : CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 30, color: Colors.black),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _messageController,
                        maxLines: null,
                        maxLength: 750,
                        cursorColor: Color(0xFF1DA1F2),
                        decoration: const InputDecoration(
                          hintText: "Add a Comment..",
                          border: InputBorder.none,
                          counterText: "",
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_selectedImage != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, height: 190),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.image,
                      size: 28,
                      color: Color(0xFF1DA1F2),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    tooltip: 'Pick from gallery',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 28,
                      color: Color(0xFF1DA1F2),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                    tooltip: 'Open camera',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
