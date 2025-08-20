import 'dart:io';

import 'package:flutter/cupertino.dart';
 import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

enum VideoState { playing, paused, completed }

enum VideoMovementDirection { forward, backward }

class MyVideoController extends GetxController
    with GetSingleTickerProviderStateMixin {
  Rx<Duration> videoCurrentPosition = Duration.zero.obs;

  late AnimationController animatedIconController;
  VideoPlayerController? myVideoPlayerController;
  File? _currentFilePath;

  RxBool showControls = true.obs;

  bool hasCompleted = false;

  @override
  void onInit() {
    super.onInit();
    animatedIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    animatedIconController.dispose();
    myVideoPlayerController?.dispose();
    super.onClose();
  }

  void initVideoPlayerController({required File galleryVideoFile}) async {
    _currentFilePath = galleryVideoFile;

    myVideoPlayerController?.dispose();

    myVideoPlayerController = VideoPlayerController.file(galleryVideoFile);
    myVideoPlayerController?.addListener(() {
      final controller = myVideoPlayerController!;

      videoCurrentPosition.value = controller.value.position;

      if (controller.value.position >= controller.value.duration) {
        if (!hasCompleted) {
          hasCompleted = true;
          animatedIconController.reverse();
        }
      } else {
        hasCompleted = false;
      }
    });

    await myVideoPlayerController!.initialize();
    myVideoPlayerController!.play();
    animatedIconController.forward();
    update();
  }

  VideoState get videoState {
    final controller = myVideoPlayerController;
    if (controller == null) return VideoState.paused;

    if (controller.value.isPlaying) return VideoState.playing;
    if (controller.value.position >= controller.value.duration) {
      return VideoState.completed;
    }
    return VideoState.paused;
  }

  void playPauseVideo() {
    final controller = myVideoPlayerController;
    if (controller == null) return;

    switch (videoState) {
      case VideoState.playing:
        debugPrint("myVideoPlayerController video is pause");
        controller.pause();
        animatedIconController.reverse();
        break;
      case VideoState.paused:
        debugPrint("myVideoPlayerController video is play");
        controller.play();
        animatedIconController.forward();
        break;
      case VideoState.completed:
        debugPrint("myVideoPlayerController video is completed");
        controller.seekTo(Duration.zero).then((_) => controller.play());
        animatedIconController.forward();
        break;
    }
    update();
  }

  void moveForwardBackward({
    required VideoMovementDirection direction,
    bool autoPlay = true,
  }) {
    final controller = myVideoPlayerController;
    if (controller == null) return;

    Duration targetPosition;
    if (direction == VideoMovementDirection.forward) {
      debugPrint("myVideoPlayerController target position plus 5 sec");
      targetPosition = controller.value.position + const Duration(seconds: 5);
    } else {
      debugPrint("myVideoPlayerController target position minus 5 sec");
      targetPosition = controller.value.position - const Duration(seconds: 5);
    }

    if (targetPosition < Duration.zero) {
      debugPrint("myVideoPlayerController target position is less than zero");
      targetPosition = Duration.zero;
    } else if (targetPosition > controller.value.duration) {
      debugPrint(
        "myVideoPlayerController target position is greater than  video duration",
      );
      targetPosition = controller.value.duration;
    }

    controller.seekTo(targetPosition).then((_) {
      debugPrint(
        "myVideoPlayerController change video position to $targetPosition",
      );
      if (autoPlay) {
        controller.play();
        animatedIconController.forward();
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void moveVideoToPosition({required int pos}) {
    final controller = myVideoPlayerController;
    if (controller == null) return;

    final maxSeconds = controller.value.duration.inSeconds;
    final safePos = pos.clamp(0, maxSeconds);
    controller.seekTo(Duration(seconds: safePos));
  }

  void toggleControls() {
    showControls.value = !showControls.value;

    if (showControls.value) {
      Future.delayed(const Duration(seconds: 3), () {
        if (showControls.value) showControls.value = false;
      });
    }
  }
/*
  Future _saveVideoToDevice() async {
    if (_currentFilePath != null) {
      try {
        await GallerySaver.saveVideo(
          _currentFilePath!.path,
          albumName: "fluter_image_picker${DateTime.now().millisecond}",
        );
        Get.snackbar(
          "Saved ",
          "video saved",
          backgroundColor: CupertinoColors.activeOrange,
          colorText: CupertinoColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (error) {
        Get.snackbar(
          "error",
          "video not saved",
          backgroundColor: CupertinoColors.activeOrange,
          colorText: CupertinoColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }*/

  Future<File?> saveFilePrivate({bool toDownloads = true}) async {
    var currentFile = _currentFilePath;
    if (currentFile == null) {
      toast(message: "file not exist");
      return null;
    }

    String newPath;

    if (toDownloads) {
      // 📂 Public Downloads folder (Android only)
      final downloadsDir = Directory("/storage/emulated/0/Download");

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      newPath = "${downloadsDir.path}/${currentFile.uri.pathSegments.last}";
    } else {
      // 📂 Private app directory
      final dir = await getApplicationDocumentsDirectory();
      newPath = '${dir.path}/${currentFile.uri.pathSegments.last}';
    }

    return currentFile.copy(newPath);


  }


  toast({message}){
    Get.snackbar(
      "error",
      message??"video not saved",
      backgroundColor: CupertinoColors.activeOrange,
      colorText: CupertinoColors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
