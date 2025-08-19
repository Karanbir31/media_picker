import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../video_picker/presentation/video_picker_screen.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePickerScreen> {
  File? galleryImageFile;
  final imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Image picker"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            onPressed: () {
              Get.to(VideoPickerScreen());
            },
            icon: Icon(Icons.play_circle_outline),
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Flexible(
                      child: Text(
                        "Pick Image: ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    MaterialButton(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey),
                      ),

                      onPressed: () {
                        myImagePicker(source: ImageSource.gallery);
                      },
                      child: Text("From Gallery"),
                    ),

                    MaterialButton(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey),
                      ),

                      onPressed: () {
                        myImagePicker(source: ImageSource.camera);
                      },
                      child: Text("From Camera"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Flexible(
                child: galleryImageFile == null
                    ? const Center(child: Text('Sorry nothing selected!!'))
                    : FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Image.file(galleryImageFile!),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void myImagePicker({required ImageSource source}) async {
    final pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile == null) {
      Get.snackbar(
        "Null",
        "please select a valid image",
        backgroundColor: Colors.red[100],
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
      );

      return;
    } else {
      setState(() {
        galleryImageFile = File(pickedFile.path);
      });
    }
  }
}
