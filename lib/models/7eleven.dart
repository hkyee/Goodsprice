import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

XFile? image; // Holds the Captures image (not to gallery)
String extractedText = "No text recognized";
String extractedPrice = "";
String extractedItemName = "";

// A function to opne camera and take picture
// Future<XFile?> openCamera(BuildContext context) async {
//   // ? means image can be null
//   final image = await _picker.pickImage(source: ImageSource.camera);
//   if (image != null) {
//     return image;
//   }
//   return null;
// }
// Function END

// A function to crop image based on scanBox
Future<File> cropImageFromFile(
  XFile imageFile,
  int left,
  int top,
  int width,
  int height,
) async {
  // Check for imageFile
  // V image is DIFFERENT
  // Uint8List bytes = await imageFile.readAsBytes();
  // saveToFileBytes(bytes);

  img.Image image = img.decodeImage(await imageFile.readAsBytes())!;
  // Check for image
  // V image is DIFFERENT
  // saveToFileImg(image);

  // debugPrint("Image bytes: ${await imageFile.readAsBytes()}");
  File croppedImageFile;
  if (image == null) {
    throw Exception("Failed to load image");
  }

  img.Image croppedImage = img.copyCrop(
    image,
    x: left,
    y: top,
    width: width,
    height: height,
  );
  // Check for CroppedImage
  // V croppedImage is different
  // saveToFileImg(croppedImage);

  // Convert the cropped image to a byte array
  Uint8List croppedBytes = Uint8List.fromList(img.encodeJpg(croppedImage));

  // Check for croppedBytes
  // V croppedBytes is different
  // saveToFileBytes(croppedBytes);

  // final directory = await getApplicationDocumentsDirectory();
  // final File imagePath = File('${directory.path}/cropped_image2.jpg');

  //Clear image cache
  imageCache.clear();

  // final directory = await getApplicationDocumentsDirectory();
  // final File imagePath = File('${directory.path}/cropped_image.jpg');
  // FOR DEBUGGING
  final File imagePath = File('/sdcard/Download/cropped_image.jpg');

  // Delete before writing
  if (await imagePath.exists()) {
    try {
      imagePath.delete();
      // debugPrint("File deleted: ${imagePath.path}");
    } catch (e) {
      debugPrint("Error deleting file : $e");
    }
  } else {
    debugPrint("File does not exist.");
  }

  croppedImageFile = await imagePath.writeAsBytes(croppedBytes);

  // imagePath.delete();
  // Check croppedImageFIle
  // V croppedImageFile is different

  // debugPrint("Written $croppedBytes");

  return croppedImageFile;
}

// A funciton to get TextBlocks
Future<List<TextBlock>> getTextBlocks(File imageFile) async {
  // Final is set to ensure it is set only once
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final inputImage = InputImage.fromFile(imageFile);

  final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

  textRecognizer.close();

  // Separate all by spaces, split them into a list
  return recognizedText.blocks;
}

// A function to scan text from images
Future<List<String>> scanText(File imageFile) async {
  // Final is set to ensure it is set only once
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final inputImage = InputImage.fromFile(imageFile);

  final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

  extractedText =
      recognizedText.text.isNotEmpty ? recognizedText.text : "No text found!";

  textRecognizer.close();

  // Separate all by spaces, split them into a list
  return extractedText.replaceAll("\n", " ").split(" ");
}

// Function to extract price data
String extractPriceData(List<String> texts) {
  // RegExp priceRegex = RegExp(r'(RM\s?)?\d+(\.\d{1,2})?');
  RegExp priceRegex = RegExp(r'(RM\s?)?\d+\.(\d{1,2})?$');

  for (String text in texts) {
    Match? match = priceRegex.firstMatch(text);
    if (match != null) {
      // Returns the whole matched group. If null, return "No Price found".
      return match.group(0) ?? "No Price found";
    }
  }

  // If null, return "No Price found".
  return "No Price found";
}
// extractPriceData End

// Function to extract Item Name
String extractItemName(List<String> texts, List<TextBlock> textBlocks,
    Rect priceTagBox, List<int> imageRes, double screenWidth) {
  // Convert to correct ratio
  double textBlockRatio = imageRes[1] / screenWidth;
  double priceTagBoxRatio = 1 / 2 * textBlockRatio;

  // Define the vertical threshold: item name to be at top 40% of the priceTagBox
  final double topBoundary = priceTagBox.top;
  final double heightThreshold = priceTagBox.height * 0.4;
  final double upperLimit = (topBoundary + heightThreshold) / priceTagBoxRatio;

  // Filter textBlocks that are within the top 20% of the priceTagBox
  List<TextBlock> potentialItemNames = textBlocks.where((block) {
    Rect? blockBox = block.boundingBox;
    if (blockBox == null) return false;
    return (blockBox.top / textBlockRatio >=
            priceTagBox.top / priceTagBoxRatio - 10) &&
        (blockBox.top + blockBox.height) / textBlockRatio <= upperLimit;
  }).toList();

  // DEBUGGING
  // for (TextBlock block in textBlocks) {
  //   debugPrint("Bounding Box ALL: ${block.boundingBox}  Text: ${block.text}");
  // }

  // for (TextBlock block in potentialItemNames) {
  //   debugPrint("Bounding Box: ${block.boundingBox}  Text: ${block.text}");
  // }

  // JOIN ALL TEXT BLOCK, inserting a space in between
  String itemName =
      potentialItemNames.map((block) => block.text.trim()).join(' ');

  String filteredItemName =
      itemName.replaceAll(RegExp(r'^\d+-\s*'), '').replaceAll('\n', ' ');
  debugPrint("item name = ${filteredItemName}");

  return filteredItemName;
}
