import 'package:flutter/material.dart';
import '../model/room.dart';

class SelectedRoomManager extends ChangeNotifier {
  static final SelectedRoomManager _instance = SelectedRoomManager._internal();
  factory SelectedRoomManager() => _instance;

  SelectedRoomManager._internal();

  Room? _selectedRoom;

  Room? get selectedRoom => _selectedRoom;

  set selectedRoom(Room? room) {
    _selectedRoom = room;
    notifyListeners();
  }
}
