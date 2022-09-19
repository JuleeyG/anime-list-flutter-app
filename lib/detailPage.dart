import 'package:flutter/material.dart';

class detailPage extends StatelessWidget {
  const detailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
          child: Text('This is Second Page', style: TextStyle(fontSize: 40)),
        )
    );
  }
}
