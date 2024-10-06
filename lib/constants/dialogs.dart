import 'package:flutter/material.dart';

class Dialogs {

  static Future<bool> showAlertDialog(
      BuildContext context, {required String title, String body="", String positiveText = "Okay", String negativeText = "Cancel"}
  ) async {

    late final bool? result;

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: List.generate(
        2,
        (index) {
          return TextButton(
            child: Text([negativeText, positiveText][index]),
            onPressed:  () {
              result = index==1;
              Navigator.pop(context);
            },
          );
        }
      )
      // [
      //   cancelButton,
      //   continueButton,
      // ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return result?? false;
  }

}