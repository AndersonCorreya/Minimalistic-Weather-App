import 'package:flutter/material.dart';

class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Card(
            elevation: 6,
            child: Container(
              padding: EdgeInsets.all(10),
              width: 100,
              height: 100,
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 32,
                  ),
                  Text(label),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
