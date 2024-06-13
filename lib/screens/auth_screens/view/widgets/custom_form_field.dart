import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';

class CustomFormField extends StatelessWidget {
  CustomFormField(
      {super.key,
      required this.label,
      required this.controller,
      this.isEmail = false,
      this.validator,
      required this.isPassword});

  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool isEmail;
  String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.08, vertical: 7),
      child: isPassword
          ? PassFormField(
              controller: controller,
              label: label,
              validator: validator,
            )
          : TextFormField(
              // cursorErrorColor: ,
              cursorErrorColor: Colors.red,
              cursorColor: primaryColor,
              cursorHeight: 25,
              controller: controller,
              validator: (value) {
                if (value!.isEmpty) {
                  return '$label is required';
                } else if (isEmail && !value.contains('@')) {
                  return 'Invalid email';
                }

                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                // error: Text('data'),
                errorMaxLines: 1,
                // focusedErrorBorder: InputBorder.none,
                errorStyle: TextStyle(
                    color: whiteColor, fontSize: 12, fontFamily: fontFamily),
                constraints: const BoxConstraints(maxHeight: 70, minHeight: 30),
                contentPadding: const EdgeInsets.only(
                  left: 20,
                  // bottom: 10,
                ),
                fillColor: whiteColor,

                filled: true,
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(25)),
                alignLabelWithHint: true,
                hintText: label,
                hintStyle: TextStyle(
                    fontFamily: fontFamily, color: primaryColor, fontSize: 14),
                // label: Text(
                //   label,
                //   style: TextStyle(
                //       fontFamily: fontFamily,
                //       color: primaryColor,
                //       fontSize: 14),
                // ),
              ),
            ),
    );
  }
}

class PassFormField extends StatefulWidget {
  PassFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  String? Function(String?)? validator;

  @override
  State<PassFormField> createState() => _PassFormFieldState();
}

class _PassFormFieldState extends State<PassFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      controller: widget.controller,
      cursorColor: primaryColor,
      cursorErrorColor: Colors.red,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorHeight: 25,
      validator: widget.validator,
      decoration: InputDecoration(
        errorStyle:
            TextStyle(color: whiteColor, fontSize: 12, fontFamily: fontFamily),
        constraints: const BoxConstraints(maxHeight: 70, minHeight: 30),

        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: primaryColor,
            size: 20,
          ),
        ),

        contentPadding: const EdgeInsets.only(left: 20),

        fillColor: whiteColor,
        filled: true,
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(25)),
        hintText: widget.label,
        hintStyle: TextStyle(
            fontFamily: fontFamily, color: primaryColor, fontSize: 14),
        //
      ),
    );
  }
}
