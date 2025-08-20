import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                Get.to(VideoPickerScreen());
              },
              icon: Icon(Icons.play_circle_outline),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                if (galleryImageFile != null) {
                  shareImageFile(
                    fileToShare: XFile(galleryImageFile!.path),
                    context: context,
                  );
                } else {

                  showSnackBar(msg: "required file path is null call shear text");
                  sharePlainText();
                }
              },
              icon: Icon(Icons.share),
            ),
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

  Future<void> shareImageFile({
    required XFile fileToShare,
    required BuildContext context,
  }) async {
    try{

      final shareParams = ShareParams(
        title: "file to share ",
        files: [fileToShare],
      );

      var result = await SharePlus.instance.share(shareParams);

      if (result.status == ShareResultStatus.success) {
        showSnackBar(msg: "success");
      } else {
        showSnackBar(msg: "unsuccess");
      }
    }catch(error){
      debugPrint("Error in shareImageFile -- $error");
    }
  }

  Future<void> sharePlainText() async {

    try{

      final shareParams = ShareParams(
          title: "file to share ",
          text: "hello from share plus",
          subject: "subject form share plus"
      );

      var result = await SharePlus.instance.share(shareParams);

      if (result.status == ShareResultStatus.success) {
        showSnackBar(msg: "success");
      } else {
        showSnackBar(msg: "unsuccess");
      }
    }catch(error){
      debugPrint("Error in share -- $error");
    }
  }



  void showSnackBar({required String msg}) {
    Get.snackbar(
      msg,
      "",
      backgroundColor: Colors.black,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      margin: EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
