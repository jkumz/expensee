import 'dart:io';

import 'package:expensee/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ReceiptService {
  Future<String?> addReceipt(BuildContext context, int expenseId) async {
    try {
      logger.d("Adding receipt to expense $expenseId");
      return await _showImageSourceDialog(context, expenseId);
    } catch (e) {
      logger.e("Failed to add receipt for expense $expenseId");
      logger.e("$e");
    }
    return null;
  }

  Future<String?> _handleImageSource(
      ImageSource imageSource, int expenseId) async {
    try {
      // Prompt user to take a photo or select from gallery
      final imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(
        source: imageSource,
      );

      if (image == null) {
        // User canceled operation
        logger.d("User cancelled adding receipt");
        return null;
      }

// Upload image to Supabase Storage
      final file = File(image.path);
      final fileExtension = p.extension(file.path);
      final fileName = 'receipt_$expenseId$fileExtension';
      final response =
          await supabase.storage.from('receipts').upload(fileName, file);

      if (response.isEmpty) {
        // Error occurred while uploading
        logger.e('Error uploading image');
        return null;
      }

      // Get URL of the uploaded image
      final imageUrl = response;

      // Add reference to Supabase file path URL in expenses table
      final updateResponse = (await supabase
              .from('expenses')
              .update(
                {'receipt_image_url': imageUrl},
              )
              .filter("id", "eq", expenseId)
              .select() as List<dynamic>)
          .firstOrNull;

      if (updateResponse == null) {
        logger.e("Failed to upload receipt");
        return updateResponse;
      }

      // Success
      logger.e("Receipt uploaded");

      return imageUrl;
    } catch (e) {
      logger.e(
          "Failed finding source of image for uploading receipt to expense $expenseId");
      logger.e("$e");
    }
    return null;
  }

  Future<String?> _showImageSourceDialog(
      BuildContext context, int expenseId) async {
    try {
      ImageSource? source = await showDialog<ImageSource?>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Receipt'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from gallery'),
                    onTap: () {
                      Navigator.pop(context, ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take a photo'),
                    onTap: () {
                      Navigator.pop(context, ImageSource.camera);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (source != null) {
        return await _handleImageSource(source, expenseId);
      } else {
        return null;
      }
    } catch (e) {
      logger.e(
          "Failed to ask user for image source to upload receipt for expense $expenseId");
      logger.e("$e");
    }
    return null;
  }
}
