import 'package:ZipBee_Driver/features/google_map/widget/google_map_widget.dart';
import 'package:flutter/material.dart';

class GoogleMapScreen extends StatelessWidget {
  const GoogleMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: AppBar(title: Text('Map')),
      ),
      body: GoogleMapWidget(),
    );
  }
}
