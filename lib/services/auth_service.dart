import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<User?> registerIsletme({
    required String email,
    required String password,
    required String isletmeAdi,
    required String yetkiliAdSoyad,
    required String telefon,
    required String adres,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı oluşturulduktan sonra Firestore'a kayıt ekle
      if (userCredential.user != null) {
        await _firestoreService.addUser({
          'email': email,
          'isletmeAdi': isletmeAdi,
          'yetkiliAdSoyad': yetkiliAdSoyad,
          'telefon': telefon,
          'adres': adres,
          'rol': 'isletme',
          'userType': 'business',
          'createdAt': FieldValue.serverTimestamp(),
        }, userCredential.user!.uid);
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Kayıt hatası: ${e.message}');
      rethrow;
    }
  }

  Future<User?> registerKurye({
    required String email,
    required String password,
    required String adSoyad,
    required String telefon,
    required String plaka,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestoreService.addUser({
          'email': email,
          'adSoyad': adSoyad,
          'telefon': telefon,
          'plaka': plaka,
          'rol': 'kurye',
          'userType': 'courier',
          'isOnline': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, userCredential.user!.uid);
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Kurye kayıt hatası: ${e.message}');
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Giriş hatası: ${e.message}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('remembered_role');
    } catch (_) {}
  }

  // Kullanıcının rolünü getirir: 'courier' veya 'business'
  Future<String?> getUserRole(String userId) async {
    try {
      final doc = await _firestoreService.getUser(userId);
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      final dynamic userTypeValue = data['userType'];
      final dynamic rolValue = data['rol'];

      // Öncelikle userType alanını kullan (courier/business)
      if (userTypeValue is String && userTypeValue.isNotEmpty) {
        return userTypeValue;
      }

      // Eski alan desteği: 'kurye' -> courier, 'isletme' -> business
      if (rolValue is String && rolValue.isNotEmpty) {
        if (rolValue == 'kurye') return 'courier';
        if (rolValue == 'isletme') return 'business';
        return rolValue;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
