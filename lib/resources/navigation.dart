import 'package:flutter/material.dart';

navPush(String routeName, BuildContext context) {
  Navigator.of(context).pushNamed(routeName);
}

navPop(BuildContext context) {
  Navigator.pop(context);
}
