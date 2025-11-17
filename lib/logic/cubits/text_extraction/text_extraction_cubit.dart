import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_extraction_app/core/utils/connectivity_service.dart';
import 'package:text_extraction_app/data/models/extraction_history_model.dart';
import 'package:text_extraction_app/data/services/database_helper.dart';
import 'package:text_extraction_app/data/services/firebase_firestore_service.dart';
import 'package:text_extraction_app/data/services/storage_service.dart';
import 'package:text_extraction_app/logic/cubits/text_extraction/text_extraction_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextExtractionCubit extends Cubit<TextExtractionState> {
  final DatabaseHelper _databaseHelper;
  final FirebaseFirestoreService _firestoreService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;
  final ImagePicker _imagePicker;
  final TextRecognizer _textRecognizer;

  TextExtractionCubit(
    this._databaseHelper,
    this._firestoreService,
    this._storageService,
    this._connectivityService,
  ) : _imagePicker = ImagePicker(),
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin),
      super(TextExtractionInitial());

  Future<void> pickImagefromGallery() async {
    emit(TextExtractionLoading());
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        emit(TextExtractionImageSelected(imageFile));
      }
    } catch (e) {
      emit(TextExtractionError('Failed to pick image: ${e.toString()}'));
    }
  }

  Future<void> captureImageWithCamera() async {
    emit(TextExtractionLoading());
    try {
      final XFile? capturedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (capturedFile != null) {
        final File imageFile = File(capturedFile.path);
        emit(TextExtractionImageSelected(imageFile));
      }else  {
        emit(TextExtractionInitial());
      }
    } catch (e) {
      emit(TextExtractionError('Failed to capture image: ${e.toString()}'));
    }
  }

  Future<void> extractTextFromImage(File imageFile, String userId) async {
    emit(TextExtractionLoading());
        final bool isOnline = await _connectivityService.checkConnection();
    
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      final String extractedText = recognizedText.text;
      if (extractedText.trim().isEmpty) {
        emit(TextExtractionError('No text found in the image.'));
        return;
      }

      String? cloudImageUrl;

      // 2. Upload to cloud if online
      if (isOnline) {
        try {
          cloudImageUrl = await _storageService.uploadExtractionImage(
            userId,
            imageFile,
          );
        } catch (e) {
          // Continue even if cloud upload fails - save locally
          print('Cloud upload failed: $e');
        }
      }

      // 3. Save to local database with both URLs
      final extraction = ExtractionHistoryModel(
        userId: userId,
        imageUrl: imageFile.path, // Local path
        cloudImageUrl: cloudImageUrl, // Cloud URL (null if offline)
        extractedText: extractedText,
        createdAt: DateTime.now(),
      );
      await _databaseHelper.insertExtraction(extraction);

      // 4. Save to Firestore if online
      if (isOnline && cloudImageUrl != null) {
        try {
          await _firestoreService.saveExtractionToCloud(
            userId: userId,
            imageUrl: cloudImageUrl,
            extractedText: extractedText,
          );
        } catch (e) {
          print('Firestore save failed: $e');
        }
      }

      emit(TextExtractionSuccess(
        extractedText,
        imageFile,
        isOffline: !isOnline,
      ));
    } catch (e) {
      emit(TextExtractionError('Failed to extract text: ${e.toString()}'));
    }
  }

void reset() {
    emit(TextExtractionInitial());
  }

  @override
  Future<void> close() {
    _textRecognizer.close();
    return super.close();
  }
}
