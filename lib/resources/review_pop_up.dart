import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:in_app_review/in_app_review.dart';

class RatingPopup extends StatefulWidget {
  final Function(int) onRatingSubmitted;

  const RatingPopup({Key? key, required this.onRatingSubmitted})
      : super(key: key);

  @override
  _RatingPopupState createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  int _rating = 0;
  int _hoverRating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rate Your Experience',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontFamily: khulaRegular),
              ),
              // IconButton(
              //   icon: Icon(Icons.close),
              //   onPressed: () => Navigator.of(context).pop(),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'How would you rate your experience with our app?',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontFamily: khulaRegular),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverRating = index + 1),
                  onExit: (_) => setState(() => _hoverRating = 0),
                  child: Icon(
                    (_hoverRating > 0 ? _hoverRating : _rating) > index
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              fixedSize: const Size(150, 45),
              backgroundColor: blackColor,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              textStyle: TextStyle(
                  fontSize: 18, fontFamily: khulaRegular, color: whiteColor),
            ),
            onPressed: () {
              widget.onRatingSubmitted(_rating);
              Navigator.of(context).pop();
            },
            child: Text(
              'Submit Rating',
              style: TextStyle(
                  fontSize: 18, fontFamily: khulaRegular, color: whiteColor),
            ),
          ),
        ],
      ),
    );
  }
}

class AndroidRatingPopup extends StatefulWidget {
  final Function(int) onRatingSubmitted;

  const AndroidRatingPopup({Key? key, required this.onRatingSubmitted})
      : super(key: key);

  @override
  _AndroidRatingPopupState createState() => _AndroidRatingPopupState();
}

class _AndroidRatingPopupState extends State<AndroidRatingPopup> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Rate Your Experience',
            style: TextStyle(
                fontFamily: khulaRegular,
                fontWeight: FontWeight.w700,
                fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          'How would you rate our app?',
          style:
              TextStyle(fontFamily: khulaRegular, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                _rating > index ? Icons.star : Icons.star_border,
                color: primaryColor,
                size: 36,
              ),
              onPressed: () => setState(() => _rating = index + 1),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          _rating > 0 ? '$_rating / 5' : 'Tap a star to rate',
          style:
              TextStyle(fontFamily: khulaRegular, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(
                width: 5,
              ),
              ElevatedButton(
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                      fontFamily: khulaRegular,
                      fontWeight: FontWeight.w700,
                      color: whiteColor),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, elevation: 0
                    // p: Colors.white,
                    ),
                onPressed: _rating > 0
                    ? () {
                        widget.onRatingSubmitted(_rating);
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
            ],
          ),
        )
      ],
    );
  }
}

openReviewDialog(context) async {
  final InAppReview inAppReview = InAppReview.instance;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isRated = prefs.getBool('isRated') ?? false;
  if (isRated) return;

  String? installDateStr = prefs.getString('installDate');
  DateTime installDate;

  if (installDateStr == null) {
    installDate = DateTime.now();
    prefs.setString(
        'installDate', DateFormat('yyyy-MM-dd').format(installDate));
  } else {
    installDate = DateFormat('yyyy-MM-dd').parse(installDateStr);
  }

  DateTime currentDate = DateTime.now();
  int daysPassed = currentDate.difference(installDate).inDays;

  int randomDelay = Random().nextInt(2) + 2;

  if (daysPassed >= randomDelay) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 0,
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: whiteColor,
        content: Platform.isAndroid
            ? AndroidRatingPopup(
                onRatingSubmitted: (rating) {
                  if (rating >= 3) {
                    prefs.setBool('isRated', true); // Mark as rated
                    inAppReview
                        .requestReview(); // Trigger the in-app review request
                  }
                },
              )
            : RatingPopup(
                onRatingSubmitted: (rating) {
                  if (rating >= 3) {
                    prefs.setBool('isRated', true); // Mark as rated
                    inAppReview
                        .requestReview(); // Trigger the in-app review request
                  }
                },
              ),
      ),
    );
  }
}