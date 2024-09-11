import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';

class HashtagSelectionWidget extends StatefulWidget {
  final List<String> recommended;
  final int maxSelections;

  const HashtagSelectionWidget({
    Key? key,
    required this.recommended,
    this.maxSelections = 10,
  }) : super(key: key);

  @override
  _HashtagSelectionWidgetState createState() => _HashtagSelectionWidgetState();
}

class _HashtagSelectionWidgetState extends State<HashtagSelectionWidget> {
  final Set<String> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SizedBox(
        height: 100, // Increased height to accommodate two lines
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(left: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: _buildHashtagRows(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHashtagRows() {
    final int halfLength = (widget.recommended.length / 2).ceil();
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHashtagRow(widget.recommended.sublist(0, halfLength)),
          const SizedBox(height: 10),
          _buildHashtagRow(widget.recommended.sublist(halfLength)),
        ],
      ),
    ];
  }

  Widget _buildHashtagRow(List<String> hashtags) {
    return Row(
      children: hashtags.map((hashtag) {
        final isSelected = _selectedOptions.contains(hashtag);
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IntrinsicWidth(
            child: InkWell(
              onTap: () => _toggleHashtag(hashtag),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? whiteColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: whiteColor, width: 1),
                ),
                child: Text(
                  hashtag,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? blackColor : whiteColor,
                    fontFamily: khulaRegular,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleHashtag(String hashtag) {
    setState(() {
      if (_selectedOptions.contains(hashtag)) {
        _selectedOptions.remove(hashtag);
      } else if (_selectedOptions.length < widget.maxSelections) {
        _selectedOptions.add(hashtag);
      } else {
        showWhiteOverlayPopup(
          context,
          null,
          'assets/icons/Info (1).svg',
          null,
          title: 'Error',
          message: 'You can only select ${widget.maxSelections} hashtags.',
          isUsernameRes: false,
        );
      }
    });
  }
}
