import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class PersonMood extends StatefulWidget {
  const PersonMood({Key? key}) : super(key: key);

  @override
  _PersonMoodState createState() => _PersonMoodState();
}

class _PersonMoodState extends State<PersonMood> {
  String pathOfImage = "";
  String moodImagePath = "";
  String moodDetail = "";
  bool isVisible = false;

  FaceDetector detector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
    ),
  );

  @override
  void dispose() {
    super.dispose();
    detector.close();
  }

  bool isloading = false;
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Machine Learning Mood Detector"),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                // col/
                child: Image.asset(
                  "assets/mood.png",
                  fit: BoxFit.contain,
                  // height: 100,
                  // width: 100,
                ),
              ),
              isloading == true
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.teal,
                      ),
                    )
                  : Visibility(
                      visible: isVisible,
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Image.asset(
                          moodImagePath,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
              const SizedBox(
                height: 20,
              ),
              isloading == true
                  ? Container()
                  : Visibility(
                      visible: isVisible,
                      child: Text(
                        "Person Mood is $moodDetail",
                        style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: TextButton(
                  onPressed: () async {
                    pickImage();
                    setState(() {
                      isloading = true;
                    });
                    Future.delayed(const Duration(seconds: 7), () {
                      extractData(pathOfImage);
                      setState(() {});
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal,
                    ),
                    height: 50,
                    child: const Center(
                      child: Text(
                        "Choose Picture",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () async {
                    clickImage();
                    setState(() {
                      isloading = true;
                    });
                    Future.delayed(const Duration(seconds: 7), () {
                      extractData(pathOfImage);
                      setState(() {});
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal,
                    ),
                    height: 50,
                    child: const Center(
                      child: Text(
                        "Click Picture",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              image?.path == null
                  ? Container()
                  : const Text("Selected Image",
                      style: TextStyle(
                          color: Colors.teal,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
              image?.path == null
                  ? Container()
                  : Container(
                      color: Colors.black,
                      height: 200,
                      width: 200,
                      child: Image.file(
                        File(image!.path),
                        fit: BoxFit.contain,
                      ),
                    ),
            ],
          ),
        ));
  }

  // Image picked from the gallery
  void pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image?.path == null) {
      setState(() {
        isloading = false;
      });
    } else {
      setState(() {
        pathOfImage = image!.path;
      });
    }
  }

  // Image picked from the camera
  void clickImage() async {
    ImagePicker imagePicker = ImagePicker();
    image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image?.path == null) {
      setState(() {
        isloading = false;
      });
    } else {
      setState(() {
        pathOfImage = image!.path;
      });
    }
  }

// This is function will detect the mood of the given image path
  void extractData(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      List<Face>? faces = await detector.processImage(inputImage);

      if (faces.isNotEmpty && faces[0].smilingProbability != null) {
        double? prob = faces[0].smilingProbability;

        if (prob! > 0.8) {
          setState(() {
            moodDetail = "Happy";
            moodImagePath = "assets/happy.png";
          });
        } else if (prob > 0.3 && prob < 0.8) {
          setState(() {
            moodDetail = "Normal";
            moodImagePath = "assets/meh.png";
          });
        } else if (prob > 0.06152385 && prob < 0.3) {
          setState(() {
            // sad
            moodDetail = "Angry";
            moodImagePath = "assets/angry.png";
          });
        } else {
          setState(() {
            moodDetail = "Sad";
            moodImagePath = "assets/sad.png";
          });
        }
        setState(() {
          isVisible = true;
          isloading = false;
        });
      } else {
        setState(() {
          isVisible = false;
        });
        const snackBar = SnackBar(
          content:
              Text('Sorry ! not able to detect the mood in the given image.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        isloading = false;
      }
    } catch (e) {
      const snackBar = SnackBar(
        content: Text('Not able to detect, Please try again.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      isloading = false;
    }
  }
}
