import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiledev_ecowaste/models/user_model.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late final TextEditingController _textController;
  XFile? _postImage;
  bool _isPostButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(() {
      final isEnabled = _textController.text.trim().isNotEmpty;
      if (isEnabled != _isPostButtonEnabled) {
        setState(() {
          _isPostButtonEnabled = isEnabled;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _postImage = image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _postImage = null;
    });
  }

  // --- THIS METHOD IS MODIFIED ---
  void _submitPost() {
    // In a real app, this is where you would upload the data to your backend.
    print('Submitting Post...');
    print('Text: ${_textController.text}');
    if (_postImage != null) {
      print('Image Path: ${_postImage!.path}');
    }

    if (mounted) {
      // After successful submission, close the page and return a 'success' message.
      Navigator.of(context).pop('posted_successfully');
    }
  }

  Future<void> _onPostButtonPressed() async {
    final bool? shouldPost = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Post to Community?'),
          content: const Text('Your post will be visible to everyone in the community feed.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A86FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldPost == true) {
      _submitPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D3557),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create a Post',
          style: GoogleFonts.splineSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isPostButtonEnabled ? _onPostButtonPressed : null,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _isPostButtonEnabled ? const Color(0xFF3A86FF) : Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Post'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildUserInfoHeader(),
          _buildTextField(),
          if (_postImage != null) _buildImagePreview(),
        ],
      ),
      bottomNavigationBar: _buildActionBar(),
    );
  }

  Widget _buildUserInfoHeader() { return Row( children: [ CircleAvatar( radius: 24, backgroundImage: NetworkImage(currentUser.avatarUrl), ), const SizedBox(width: 12), Text( currentUser.name, style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 16, ), ), ], ); }
  Widget _buildTextField() { return Padding( padding: const EdgeInsets.symmetric(vertical: 8.0), child: TextField( controller: _textController, autofocus: true, maxLines: null, keyboardType: TextInputType.multiline, decoration: const InputDecoration( hintText: "What's on your mind?", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, ), style: const TextStyle(fontSize: 18), ), ); }
  Widget _buildImagePreview() { return Padding( padding: const EdgeInsets.only(top: 16.0), child: Stack( clipBehavior: Clip.none, children: [ ClipRRect( borderRadius: BorderRadius.circular(12), child: Image.file( File(_postImage!.path), fit: BoxFit.cover, width: double.infinity, ), ), Positioned( top: 8, right: 8, child: GestureDetector( onTap: _removeImage, child: Container( decoration: BoxDecoration( color: Colors.black.withOpacity(0.6), shape: BoxShape.circle, ), child: const Icon(Icons.close, color: Colors.white, size: 20), ), ), ), ], ), ); }
  Widget _buildActionBar() { return Container( padding: const EdgeInsets.symmetric(horizontal: 8.0), decoration: BoxDecoration( color: Colors.white, border: Border( top: BorderSide(color: Colors.grey.shade200, width: 1.0), ), ), child: Row( mainAxisAlignment: MainAxisAlignment.start, children: [ IconButton( icon: const Icon(Icons.photo_library_outlined, color: Color(0xFF3A86FF)), onPressed: _pickImage, tooltip: 'Add a photo', ), ], ), ); }
}