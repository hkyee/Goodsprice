import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

final ImagePicker _picker = ImagePicker();
XFile? image; // Holds the Captures image (not to gallery)
String extractedText = "No text recognized";
String extractedPrice = "";
String extractedItemName = "";

// A function to opne camera and take picture
Future<XFile?> openCamera(BuildContext context) async {
  // ? means image can be null
  final image = await _picker.pickImage(source: ImageSource.camera);
  if (image != null) {
    return image;
  }
  return null;
}
// Function END

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
// String extractItemName(List<String> texts) {}
