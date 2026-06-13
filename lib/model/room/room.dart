import 'package:cloud_firestore/cloud_firestore.dart';

class Room {

  Room({required this.id, required this.number});

  final String id;
  final int number; 
}