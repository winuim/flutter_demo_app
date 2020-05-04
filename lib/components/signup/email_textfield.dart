import 'package:flutter/material.dart';
import 'package:the_validator/the_validator.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField(
      {Key key, this.editController, this.myFocus, this.nextFocus})
      : super(key: key);

  final TextEditingController editController;
  final FocusNode myFocus;
  final FocusNode nextFocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: editController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'メールアドレス',
          icon: Icon(Icons.email),
        ),
        autocorrect: false,
        autofocus: false,
        validator: FieldValidator.email(message: 'メールアドレスが正しくありません'),
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
