import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

import '../services/cloudinary/cloudinary_service.dart';

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

  void _showEmptyPostAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      imageUrl = await CloudinaryService.uploadImageToCloudinary(_selectedImage!);
    }

    await Provider.of<DatabaseProvider>(context, listen: false)
        .postMessage(_messageController.text.trim(), imageUrl: imageUrl);

    setState(() => _isPosting = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _postMessage,
            child: _isPosting
                ? const CircularProgressIndicator()
                : const Text(
              'Post',
              style: TextStyle(
                color: Color(0xFF1DA1F2),
                fontWeight: FontWeight.bold,
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
                  const Icon(Icons.person, size: 40, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: "What's happening?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 200),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:twitter_clone/services/database/database_provider.dart';
//
// class PostMessagePage extends StatefulWidget {
//   const PostMessagePage({super.key});
//
//   @override
//   State<PostMessagePage> createState() => _PostMessagePageState();
// }
//
// class _PostMessagePageState extends State<PostMessagePage> {
//   final TextEditingController _messageController = TextEditingController();
//
//   // Show Alert Dialog for Empty Post
//   void _showEmptyPostAlert() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Empty Post'),
//         content: const Text("Please write something before posting."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Post message functionality
//   Future<void> _postMessage() async {
//     if (_messageController.text.trim().isEmpty) {
//       _showEmptyPostAlert(); // Show alert if post is empty
//     } else {
//       await Provider.of<DatabaseProvider>(context, listen: false)
//           .postMessage(_messageController.text.trim());
//       Navigator.pop(context); // Return to HomePage after posting
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('New Post'),
//         actions: [
//           TextButton(
//             onPressed: _postMessage,
//             child: const Text(
//               'Post',
//               style: TextStyle(
//                 color: Color(0xFF1DA1F2), // Twitter blue color
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(Icons.person, size: 40, color: Colors.grey), // Fixed Person Icon
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   controller: _messageController,
//                   maxLines: null,
//                   maxLength: 500,
//                   decoration: const InputDecoration(
//                     hintText: "What's happening?",
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
