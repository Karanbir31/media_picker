import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_video_picker/video_picker/controller/my_video_controller.dart';
import 'package:shimmer/shimmer.dart';
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

        actions: [
          IconButton(
            onPressed: () async {
              //controller.saveVideoToDevice
              controller.saveFilePrivate().then((v) {
                if (v != null) {
                  Get.snackbar(
                    "Saved ",
                    "video saved",
                    backgroundColor: CupertinoColors.activeOrange,
                    colorText: CupertinoColors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              });
            },
            icon: Icon(Icons.file_download_rounded),
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
                        ? Center(child: myShimmerLoadingScreen())
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

    if (!videoController!.value.isInitialized) {
      // Prevent aspectRatio=0 crash
      return Center(child: myShimmerLoadingScreen());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: videoController.value.aspectRatio > 0
              ? videoController.value.aspectRatio
              : 16 / 9,

          child: GestureDetector(
            onTap: controller.toggleControls,
            child: VideoPlayer(videoController),
          ),
        ),

        // play pause button (center)
        Obx(
          () => !controller.showControls.value
              ? const SizedBox.shrink()
              : IconButton(
                  color: Colors.blueAccent,
                  iconSize: 48,
                  onPressed: controller.playPauseVideo,
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: controller.animatedIconController,
                    color: Colors.white,
                  ),
                ),
        ),

        // move backward 5 sec
        Obx(
          () => !controller.showControls.value
              ? const SizedBox.shrink()
              : Positioned(
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
        ),

        // move forward 5 sec
        Obx(
          () => !controller.showControls.value
              ? const SizedBox.shrink()
              : Positioned(
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
        ),

        // progress bar (fix value scaling 0-1)
        Obx(() {
          final currentPosition = controller.videoCurrentPosition.value;
          final totalDuration =
              controller.myVideoPlayerController?.value.duration ??
              Duration.zero;

          return !controller.showControls.value
              ? const SizedBox.shrink()
              : Positioned(
                  bottom: 10,
                  left: 2,
                  right: 2,

                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          controller.formatDuration(
                            controller.videoCurrentPosition.value,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),

                      Flexible(
                        child: Slider(
                          activeColor: Colors.blue,
                          inactiveColor: Colors.blue.withValues(alpha: 0.33),

                          value: currentPosition.inSeconds.toDouble().clamp(
                            0,
                            totalDuration.inSeconds.toDouble(),
                          ),
                          onChanged: (pos) {
                            controller.moveVideoToPosition(pos: pos.toInt());
                          },

                          max: totalDuration.inSeconds.toDouble(),
                          min: 0,
                        ),
                      ),
                    ],
                  ),
                );
        }),

        Obx(
          () => !controller.showControls.value
              ? const SizedBox.shrink()
              : Positioned(
                  right: 10,
                  top: 10,
                  child: Text(
                    controller.formatDuration(
                      controller.myVideoPlayerController!.value.duration,
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
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

  Widget myShimmerLoadingScreen() {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.lightBlueAccent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Container(height: 200, width: 200, color: Colors.white),
          ),

          ListTile(title: Container(height: 120, color: Colors.white)),
        ],
      ),
    );
  }
}
