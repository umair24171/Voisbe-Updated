// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/screens/auth_screens/view/auth_screen.dart';
// import 'package:social_notes/screens/bookmark_screen/view/book_mark_screen.dart';

// class CustomDrawer extends StatelessWidget {
//   const CustomDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           const SizedBox(
//             height: 20,
//           ),
//           // const DrawerHeader(
//           //   decoration: BoxDecoration(
//           //     color: Colors.blue,
//           //   ),
//           //   child: Text(
//           //     'Sidebar Header',
//           //     style: TextStyle(
//           //       color: Colors.white,
//           //       fontSize: 24,
//           //     ),
//           //   ),
//           // ),
//           // ListTile(
//           //   leading: const Icon(Icons.notifications),
//           //   title: const Text('Notification Settings'),
//           //   onTap: () {
//           //     // Handle notification settings action
//           //   },
//           // ),
//           ListTile(
//             leading: const Icon(Icons.bookmark),
//             title: Text(
//               'Bookmarks',
//               style: TextStyle(fontFamily: fontFamily),
//             ),
//             onTap: () async {
//               Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) {
//                   return BookMarkScreen();
//                 },
//               ));
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.exit_to_app),
//             title: Text(
//               'Logout',
//               style: TextStyle(fontFamily: fontFamily),
//             ),
//             onTap: () async {},
//           ),
//         ],
//       ),
//     );
//   }
// }
