import 'package:flutter/services.dart';

class InAppReview {
  static const MethodChannel _channel = MethodChannel('in_app_review');

  /// Requests an in-app review.
  ///
  /// Returns `true` if the review flow was launched successfully,
  /// `false` otherwise.
  static Future<bool> requestReview() async {
    try {
      final bool result = await _channel.invokeMethod('requestReview');
      return result;
    } on PlatformException catch (e) {
      print('Error requesting review: ${e.message}');
      return false;
    }
  }

  /// Checks if the app is eligible for in-app review.
  ///
  /// This is useful to avoid requesting reviews too frequently.
  static Future<bool> isEligibleForReview() async {
    try {
      final bool result = await _channel.invokeMethod('isEligibleForReview');
      return result;
    } on PlatformException catch (e) {
      print('Error checking review eligibility: ${e.message}');
      return false;
    }
  }
}
