import 'package:flutter/material.dart';
import '../utils/commons.dart';

class HorizontalRoomButtons extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final Function(Map<String, dynamic> room) onRoomSelected;
  final Map<String, dynamic> selectedRoom;

  const HorizontalRoomButtons({
    Key? key,
    required this.rooms,
    required this.onRoomSelected,
    required this.selectedRoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: rooms.map<Widget>((room) {
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Commons.buildButton(
              context,
              room['name'],
              Icons.computer,
              () => onRoomSelected(room),
              selectedRoom['name'],
            ),
          );
        }).toList(),
      ),
    );
  }
}
