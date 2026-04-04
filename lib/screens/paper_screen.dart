import 'package:flutter/material.dart';

class PaperScreen extends StatelessWidget {
  const PaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paper Analysis')),
      body: const Center(child: Text('Paper Analysis Screen')),
    );
  }
}
