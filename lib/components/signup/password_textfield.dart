import 'package:flutter/material.dart';
import 'package:the_validator/the_validator.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField(
      {Key key,
      this.editController,
      this.myFocus,
      this.nextFocus,
      this.validate})
      : super(key: key);

  final TextEditingController editController;
  final FocusNode myFocus;
  final FocusNode nextFocus;
  final bool validate;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: editController,
        keyboardType: TextInputType.visiblePassword,
        decoration: const InputDecoration(
          labelText: 'パスワード',
          icon: Icon(Icons.security),
        ),
        obscureText: true,
        autocorrect: false,
        autofocus: false,
        validator: (validate == null || validate)
            ? FieldValidator.password(
                minLength: 8,
                shouldContainNumber: true,
                shouldContainCapitalLetter: true,
                // shouldContainSpecialChars: true,
                errorMessage: 'パスワードは必要な形式と一致する必要があります',
                isNumberNotPresent: () {
                  return 'パスワードには数字が必要です';
                },
                // isSpecialCharsNotPresent: () {
                //   return 'パスワードには特殊文字を含める必要があります';
                // },
                isCapitalLetterNotPresent: () {
                  return 'パスワードには大文字を含める必要があります';
                })
            : null,
        focusNode: myFocus,
        onFieldSubmitted: (v) {
          if (nextFocus == null) {
            myFocus.unfocus();
          } else {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        });
  }
}

class ConfirmPasswordTextField extends StatelessWidget {
  const ConfirmPasswordTextField(
      {Key key,
      this.editController,
      this.passwordController,
      this.myFocus,
      this.nextFocus})
      : super(key: key);

  final TextEditingController editController;
  final TextEditingController passwordController;
  final FocusNode myFocus;
  final FocusNode nextFocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: editController,
        keyboardType: TextInputType.visiblePassword,
        decoration: const InputDecoration(
          labelText: '確認用パスワード',
          icon: Icon(Icons.security),
        ),
        obscureText: true,
        autocorrect: false,
        autofocus: false,
        validator: FieldValidator.equalTo(passwordController.text,
            message: 'パスワードが一致していません'),
        focusNode: myFocus,
        onFieldSubmitted: (v) {
          if (nextFocus == null) {
            myFocus.unfocus();
          } else {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        });
  }
}
