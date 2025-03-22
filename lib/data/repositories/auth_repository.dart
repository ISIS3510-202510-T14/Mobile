import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Class to handle Firestore operations
class AuthRepository {
  final CollectionReference _authCollection =
      FirebaseFirestore.instance.collection('authdb');

  // Write email and token to Firestore
  Future<void> writeToken(String email, String token) async {
    try {
      await _authCollection.doc(email).set({
        'token': token,
        'timestamp': FieldValue.serverTimestamp(), // Optional: adds timestamp
      });
      print('Token written successfully');
    } catch (e) {
      print('Error writing token: $e');
      throw Exception('Failed to write token');
    }
  }

  // Read token from Firestore using email
  Future<String?> readToken(String email) async {
    try {
      DocumentSnapshot doc = await _authCollection.doc(email).get();
      
      if (doc.exists) {
        // Cast the data to Map<String, dynamic> and get the token
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['token'] as String?;
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error reading token: $e');
      throw Exception('Failed to read token');
    }
  }
}