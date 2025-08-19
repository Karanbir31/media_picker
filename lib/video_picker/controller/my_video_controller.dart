import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

enum VideoState { playing, paused, completed }

class MyVideoController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animatedIconController;

  VideoPlayerController? myVideoPlayerController;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    animatedIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    animatedIconController.dispose();
    myVideoPlayerController?.dispose();
    super.onClose();
  }

  void initVideoPlayerController({required File galleryVideoFile}) async {
    debugPrint("myVideoPlayerController called with file path ");

    if (myVideoPlayerController != null) {
      debugPrint("myVideoPlayerController previous controller dispose ");
      myVideoPlayerController?.dispose(); // dispose old controller if any
    }

    myVideoPlayerController = VideoPlayerController.file(galleryVideoFile);
    myVideoPlayerController?.addListener(() {
      if (myVideoPlayerController!.value.isCompleted) {
        animatedIconController.reverse();

        Get.snackbar(
          "to play again press play button",
          "message",
          colorText: CupertinoColors.white,

          backgroundColor: CupertinoColors.black,
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          maxWidth: Get.width * 0.8,
          margin: EdgeInsets.only(bottom: 16),
        );
      }
    });

    await myVideoPlayerController!.initialize().then((_) {
      debugPrint("myVideoPlayerController after initialize  ");
      myVideoPlayerController!.play();
      animatedIconController.forward();
      update();
    });
  }

  void playPauseVideo() {
    if (myVideoPlayerController == null) return;

    VideoState state;
    final controller = myVideoPlayerController!;

    if (controller.value.isPlaying) {
      state = VideoState.playing;
    } else if (controller.value.position >= controller.value.duration) {
      // there are two position controller.position and controller.value.position what is difference

      state = VideoState.completed;
    } else {
      state = VideoState.paused;
    }

    switch (state) {
      case VideoState.playing:
        myVideoPlayerController!.pause();
        animatedIconController.reverse(); // back to play icon

        break;
      case VideoState.paused:
        myVideoPlayerController!.play();
        animatedIconController.forward(); // move to pause icon

        break;
      case VideoState.completed:
        controller.seekTo(Duration.zero);
        controller.play();

        animatedIconController.forward(); // move to pause icon
        break;
    }

    update(); // make sure GetBuilder rebuilds
  }




}
