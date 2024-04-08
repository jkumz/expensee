import 'dart:io';

import 'package:expensee/components/dialogs/confirmation_dialog.dart';
import 'package:expensee/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ReceiptService {
  Future<String?> addReceipt(BuildContext context, int expenseId) async {
    return await _showImageSourceDialog(context, expenseId);
  }

  Future<String?> _handleImageSource(
      ImageSource imageSource, int expenseId) async {
    // Prompt user to take a photo or select from gallery
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(
      source: imageSource,
    );

    if (image == null) {
      // User canceled operation
      return null;
    }

// Upload image to Supabase Storage
    final file = File(image.path);
    final fileExtension = p.extension(file.path);
    final fileName = 'receipt_${expenseId}${fileExtension}';
    final response =
        await supabase.storage.from('receipts').upload(fileName, file);

    if (response.isEmpty) {
      // Error occurred while uploading // TODO
      print('Error uploading image');
      return null;
    }

    // Get URL of the uploaded image
    final imageUrl = response;

    // Add reference to Supabase file path URL in expenses table
    final updateResponse = await supabase.from('expenses').update(
      {'receipt_image_url': imageUrl},
    ).filter("id", "eq", expenseId);

//TODO - error handling

    // Success
    ConfirmationAlertDialog(
      title: "Receipt uploaded",
      content: "The receipt for expense ID $expenseId has been stored.",
    );
    return imageUrl;
  }

  Future<String?> _showImageSourceDialog(
      BuildContext context, int expenseId) async {
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
    }
  }
}
