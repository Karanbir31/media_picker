import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_video_picker/video_picker/controller/my_video_controller.dart';
import 'package:video_player/video_player.dart';

class VideoPickerScreen extends StatelessWidget {
  final controller = Get.put(MyVideoController());

  final imagePicker = ImagePicker();

  VideoPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Video picker"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
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
                        "Pick Video: ",
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
                        myVideoPicker(source: ImageSource.gallery);
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
                        myVideoPicker(source: ImageSource.camera);
                      },
                      child: Text("From Camera"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Flexible(
                child: GetBuilder<MyVideoController>(
                  builder: (_) {
                    return controller.myVideoPlayerController == null
                        ? const Center(child: Text('Sorry nothing selected!!'))
                        : !controller
                              .myVideoPlayerController!
                              .value
                              .isInitialized
                        ? const Center(child: CircularProgressIndicator())
                        : myVideoPlayerWidget();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget myVideoPlayerWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: controller.myVideoPlayerController!.value.aspectRatio,
          child: VideoPlayer(controller.myVideoPlayerController!),
        ),

        IconButton(
          color: Colors.blueAccent,
          onPressed: () {
            controller.playPauseVideo();
          },
          icon: GetBuilder<MyVideoController>(
            builder: (controller) {
              return AnimatedIcon(
                size: 48,
                icon: AnimatedIcons.play_pause,
                progress: controller.animatedIconController,
                color: Colors.white,
              );
            },
          ),
        ),
        //
        // Obx(
        //   () => IconButton(
        //     color: Colors.red,
        //     onPressed: () {
        //       controller.playPauseVideo();
        //     },
        //     icon: AnimatedIcon(
        //       size: 48,
        //       icon: AnimatedIcons.play_pause,
        //       progress: controller.animatedIconController,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  void myVideoPicker({required ImageSource source}) async {
    final pickedFile = await imagePicker.pickVideo(source: source);
    if (pickedFile == null) {
      Get.snackbar(
        "Null",
        "please select a valid video",
        backgroundColor: Colors.red[100],
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
      );

      return;
    } else {
      controller.initVideoPlayerController(
        galleryVideoFile: File(pickedFile.path),
      );
    }
  }
}
