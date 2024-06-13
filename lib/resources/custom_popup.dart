import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';

class PopupMenuCreatePost extends StatefulWidget {
  const PopupMenuCreatePost({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PopupMenuCreatePost createState() => _PopupMenuCreatePost();
}

class _PopupMenuCreatePost extends State<PopupMenuCreatePost> {
  final GlobalKey _popupKey = GlobalKey();

  void _showPopupMenu() {
    final RenderBox popupRenderBox =
        _popupKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        popupRenderBox.localToGlobal(Offset.zero, ancestor: overlay),
        popupRenderBox.localToGlobal(
            popupRenderBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      color: const Color(0xffFFD2D4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      items: [
        PopupMenuItem(
          value: 'add_subscription',
          child: Row(
            children: [
              Container(
                  height: 36,
                  width: 36,
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                      color: Color(0xffFFBEC1), shape: BoxShape.circle),
                  child: const Icon(
                    Icons.diamond_rounded,
                    color: Color(0xffFF7D83),
                  )),
              const SizedBox(
                width: 7,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pinn Post',
                    style: TextStyle(fontFamily: fontFamily),
                  ),
                  Text(
                    'View Post',
                    style: TextStyle(fontFamily: fontFamily),
                  ),
                  Text(
                    'Delete Post',
                    style: TextStyle(fontFamily: fontFamily),
                  ),
                ],
              )
            ],
          ),
          onTap: () {},
        ),
        PopupMenuItem(
          value: 'create_post',
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                    color: Color(0xffFFBEC1), shape: BoxShape.circle),
              ),
              const SizedBox(
                width: 7,
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              )
            ],
          ),
          onTap: () {
            // if (Apis.userDetail.subscription == true) {
            //   PersistentNavBarNavigator.pushNewScreen(context,
            //       screen: CreatePost(), withNavBar: false);
            // } else {
            //   showDialog(
            //     context: context,
            //     builder: (context) {
            //       return Dialouge(
            //           onPressed: () {},
            //           buttonText: 'Subscribe',
            //           details:
            //               'Sorry you are unable to create a post. Only subscribers can create and publish posts. Please subscribe to the subscription now to connect!',
            //           image: Images.sadImage,
            //           message: 'Oooops');
            //     },
            //   );
            // }
          },
        ),
        // Add more PopupMenuItems as needed
      ],
    ).then((value) {
      if (value != null) {
        // Perform actions based on selected value if needed
        debugPrint('Selected: $value');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showPopupMenu,
      child: Container(
        key: _popupKey,
        alignment: Alignment.center,
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          size: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}
