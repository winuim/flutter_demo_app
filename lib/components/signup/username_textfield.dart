import 'package:flutter/material.dart';
import 'package:the_validator/the_validator.dart';

class UsernameTextField extends StatelessWidget {
  const UsernameTextField(
      {Key key, this.editController, this.myFocus, this.nextFocus})
      : super(key: key);

  final TextEditingController editController;
  final FocusNode myFocus;
  final FocusNode nextFocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: editController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'ユーザ名',
          icon: Icon(Icons.account_circle),
        ),
        autocorrect: false,
        autofocus: true,
        validator: FieldValidator.minLength(1, message: 'ユーザ名が入力されていません'),
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
