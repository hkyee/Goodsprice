import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:goodsprice/services/priceTagBox.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Models
import 'package:goodsprice/models/7eleven.dart';
// import 'package:goodsprice/models/KK.dart' as kk;

class cameraScreen extends StatefulWidget {
  const cameraScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<cameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<cameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<String> _extractedText = [];
  String _extractedPrice = "";
  String _extractedItemName = "";
  List<TextBlock> textBlocks = [];
  List<int> imageRes = [];
  List<int> imageResCropped = [];

//   // Must update to call different models' functions
//   final Map<String, String> modelsPrefix = {
//   '7 Eleven': 'sevenE',
//   'NSK Trade City': 'nsk',
//   'KK Mart': 'kk',
//   '99 Speedmart': 'nnsm',
//   'Supervalue': 'superValue'
// };

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize().then((_) async {
      await _controller.setZoomLevel(1.5);
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  // Future<XFile> takePicture() async {
  //   try {
  //     final XFile file = await _controller!.takePicture();
  //     return file;
  //   } on PlatformException catch (e) {
  //     _controller!.value = _controller!.value.copyWith(isTakingPicture: false);
  //     throw CameraException(e.code, e.message);
  //   }
  // }

  // A function to get Image Resolution
  Future<List<int>> getImageResolution(File? imageFile) async {
    final bytes = await imageFile!.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);

    // debugPrint(
    // "Image Resolution: ${decodedImage.width} × ${decodedImage.height}");
    return [decodedImage.height, decodedImage.width];
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    double? scanBoxWidth = args['width'];
    double? scanBoxHeight = args['height'];
    String storeName = args['storeName'];
    // Get screen width = 360
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("Scan Price Tag"),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Container(
              color: Colors.amber,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CameraPreview(_controller),
                  ),
                  Center(
                    child: Container(
                      width: scanBoxWidth,
                      height: scanBoxHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: () async {
                              // Take the Picture in a try / catch block. If anything goes wrong,
                              // catch the error.
                              try {
                                // Ensure that the camera is initialized.

                                await _initializeControllerFuture;

                                // Attempt to take a picture and get the file `image`
                                // where it was saved.
                                XFile image = await _controller.takePicture();

                                if (!context.mounted) return;

                                // If the picture was taken, display it on a new screen.

                                // Crop it
                                // Read image bytes
                                // Uint8List imageBytes =
                                // await image.readAsBytes();
                                // debugPrint("Image bytes 2: $imageBytes");

                                // [0] : Height : 1920
                                // [1] : Width  : 1080
                                imageRes =
                                    await getImageResolution(File(image.path));

                                double ratio = imageRes[0] / imageRes[1];
                                int left =
                                    (((screenWidth / 2) - (scanBoxWidth! / 2)) *
                                            (imageRes[1] / screenWidth))
                                        .toInt();
                                int top = (((ratio * screenWidth / 2) -
                                            (scanBoxWidth! / 2)) *
                                        (imageRes[0] / (ratio * screenWidth)))
                                    .toInt();
                                int width =
                                    (scanBoxWidth! * imageRes[1] / screenWidth)
                                        .toInt();
                                int height = (scanBoxHeight! *
                                        imageRes[0] /
                                        (ratio * screenWidth))
                                    .toInt();

                                File imageCropped = await cropImageFromFile(
                                    image, left, top, width, height);

                                imageResCropped =
                                    await getImageResolution(imageCropped);
                                Rect priceTagBox =
                                    getPriceTagBox(imageCropped.path);
                                // DEBUG
                                // debugPrint("Left: $left");
                                // debugPrint("Top: $top");
                                // debugPrint("Width: $width");
                                // debugPrint("Height: $height");

                                // final File imagePath = File('/sdcard/Download/cropped_image2.jpg');
                                // imagePath.writeAsBytesSync(imageCropped.readAsBytesSync());
                                // Check for imageCropped
                                // V imageCropped is different

                                // Get Text Block
                                textBlocks = await getTextBlocks(
                                    File(imageCropped.path));

                                // Scan Text
                                _extractedText =
                                    await scanText(File(imageCropped.path));
                                _extractedPrice =
                                    extractPriceData(_extractedText);

                                _extractedItemName = extractItemName(
                                    _extractedText,
                                    textBlocks,
                                    priceTagBox,
                                    imageResCropped,
                                    screenWidth);

                                await Navigator.pushNamed(
                                  context,
                                  '/result',
                                  arguments: {
                                    'imagePath': imageCropped.path,
                                    'price': _extractedPrice,
                                    'priceTagBox': priceTagBox,
                                    'textBlocks': textBlocks,
                                    'imageRes': imageResCropped,
                                    'itemName': _extractedItemName,
                                    'storeName': storeName,
                                  }, // Pass imagePath as an argument
                                );
                              } catch (e) {
                                // If an error occurs, log the error to the console.
                                print(e);
                              }
                            },
                            child: const Text("Scan"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
