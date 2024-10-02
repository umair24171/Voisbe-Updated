import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_notes/review_services/in_app_review.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();

  factory ReviewService() {
    return _instance;
  }

  ReviewService._internal();

  static const String _lastReviewRequestKey = 'last_review_request';
  static const int _minDaysBetweenReviews = 30;

  Future<void> considerRequestingReview() async {
    if (await _shouldRequestReview()) {
      final bool launched = await InAppReview.requestReview();
      if (launched) {
        await _updateLastReviewRequest();
      }
    }
  }

  Future<bool> _shouldRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRequest = prefs.getInt(_lastReviewRequestKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSinceLastRequest = (now - lastRequest) / (1000 * 60 * 60 * 24);

    return daysSinceLastRequest >= _minDaysBetweenReviews &&
        await InAppReview.isEligibleForReview();
  }

  Future<void> _updateLastReviewRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _lastReviewRequestKey, DateTime.now().millisecondsSinceEpoch);
  }
}
