import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String groupName;
  final VoidCallback onTap;

  const GroupCard({Key? key, required this.groupName, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(groupName),
        onTap: onTap,
      ),
    );
  }
} 