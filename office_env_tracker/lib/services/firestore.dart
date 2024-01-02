import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class FirestoreService {
  // Créez une instance privée statique de FirestoreService
  static final FirestoreService _instance = FirestoreService._internal();

  // Rendre le constructeur privé
  FirestoreService._internal();

  // Fournit un moyen d'accéder à l'instance
  static FirestoreService get instance => _instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRooms() async {
    log("Fetching rooms from Firestore");
    try {
      QuerySnapshot querySnapshot = await firestore.collection('rooms').get();
      return querySnapshot.docs
          .map((doc) => {
                'ipAddress': doc['ipAddress'],
                'name': doc['name'],
              })
          .toList();
    } catch (e) {
      log("Error fetching rooms: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRoomById(String roomId) async {
    try {
      DocumentSnapshot docSnapshot =
          await firestore.collection('rooms').doc(roomId).get();
      if (docSnapshot.exists) {
        log("Room found: ${docSnapshot.data()}");
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        log("No room found with id: $roomId");
        return null;
      }
    } catch (e) {
      log("Error fetching room: $e");
      return null;
    }
  }
}
