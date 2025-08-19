import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePickerScreen> {
  File? galleryFile;
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
      ),

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
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

              const SizedBox(height: 20),

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

              const SizedBox(height: 20),
              SizedBox(
                height: 200.0,
                width: 300.0,
                child: galleryFile == null
                    ? const Center(child: Text('Sorry nothing selected!!'))
                    : Center(child: Image.file(galleryFile!)),
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
      Get.snackbar("error", "please select a valid image");
      return;
    } else {
      setState(() {
        galleryFile = File(pickedFile.path);
      });
    }
  }
}
