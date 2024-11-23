
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddExpandableButtons extends StatefulWidget {
  @override
  _AddExpandableButtonsState createState() => _AddExpandableButtonsState();
}

class _AddExpandableButtonsState extends State<AddExpandableButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);  // Save picked image to the _image variable
      });
    }
  }

  // Function to take a photo with the camera
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);  // Save the captured photo to the _image variable
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  void _toggleExpand() {
    setState(() {
      if (_isExpanded) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated Buttons (Camera and Gallery)
        SizeTransition(
          sizeFactor: _expandAnimation,
          axis: Axis.horizontal,
          child: Row(
            children: [
              // Camera Button
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.grey[700]),
                onPressed: _pickImageFromCamera,
              ),
              // Image Gallery Button
              IconButton(
                icon: Icon(Icons.photo, color: Colors.grey[700]),
                onPressed: _pickImageFromGallery,
              ),
            ],
          ),
        ),
        // Main Plus/Left Arrow Button
        IconButton(
          icon: Icon(
            _isExpanded ? Icons.arrow_left : Icons.add,
            color: const Color(0xFF6C63FF),
          ),
          onPressed: _toggleExpand,
        ),
      ],
    );
  }
}
