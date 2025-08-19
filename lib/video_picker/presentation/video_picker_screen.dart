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
                        : myVideoPlayerWidget();
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget myVideoPlayerWidget() {
    final videoController = controller.myVideoPlayerController;

    if (videoController == null || !videoController.value.isInitialized) {
      // Prevent aspectRatio=0 crash
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: videoController.value.aspectRatio,
          child: VideoPlayer(videoController),
        ),

        // play pause button (center)
        GetBuilder<MyVideoController>(
          builder: (controller) {
            return IconButton(
              color: Colors.blueAccent,
              iconSize: 48,
              onPressed: controller.playPauseVideo,
              icon: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: controller.animatedIconController,
                color: Colors.white,
              ),
            );
          },
        ),

        // move backward 5 sec
        Positioned(
          left: 10,
          child: IconButton(
            color: Colors.white,
            onPressed: () => controller.moveForwardBackward(
              direction: VideoMovementDirection.backward,
              autoPlay: true,
            ),
            icon: const Icon(Icons.keyboard_double_arrow_left),
          ),
        ),

        // move forward 5 sec
        Positioned(
          right: 10,
          child: IconButton(
            color: Colors.white,
            onPressed: () => controller.moveForwardBackward(
              direction: VideoMovementDirection.forward,
              autoPlay: true,
            ),
            icon: const Icon(Icons.keyboard_double_arrow_right),
          ),
        ),

        // progress bar (fix value scaling 0-1)
        Obx(
          () => Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    controller.formatDuration(
                      controller.videoCurrentPosition.value,
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),

                Flexible(
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: controller.currentVideoPosition.value / 100,
                    // scale 0–1
                    color: Colors.blue,
                    backgroundColor: Colors.red[200],
                  ),
                ),
              ],
            ),
          ),
        ),

        // current position
        Positioned(
          right: 10,
          top: 10,
          child: Text(
            controller.formatDuration(
              controller.myVideoPlayerController!.value.duration,
            ),
            style: const TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ),
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
