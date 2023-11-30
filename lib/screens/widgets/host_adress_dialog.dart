import 'dart:ui';
import 'package:flutter/material.dart';

class HostAdressDialog extends StatefulWidget {
  final String hostAdress;
  const HostAdressDialog({super.key, required this.hostAdress});

  @override
  State<HostAdressDialog> createState() => _HostAdressDialogState();
}

class _HostAdressDialogState extends State<HostAdressDialog> {
  late String hostAdress = widget.hostAdress;
  final formKey = GlobalKey<FormState>();
  bool get resultValid => formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: AlertDialog(
        title: const Text('Host address'),
        content: Form(key: formKey, child: hostField()),
        actions: [
          Opacity(
            opacity: resultValid ? 1 : 0.5,
            child: TextButton(
              onPressed: () => Navigator.pop(context, hostAdress),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField hostField() {
    return TextFormField(
      initialValue: hostAdress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (v) => setState(() => hostAdress = v),
      // inputFormatters: [AppFormatters.ipFormatter],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Input can\'t be empty';
        }
        // if (AppValidators.isValidIp(value) == false) {
        //   return 'Please enter a valid ip adress';
        // }
        return null;
      },
    );
  }
}
