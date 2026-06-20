import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyorder/models/models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        _currentUser = null;
        _docSub?.cancel();
      } else {
        _listenToUserDoc(user.uid);
      }
    });
  }

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  StreamSubscription? _docSub;
  final _userController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get userStream => _userController.stream;

  void _listenToUserDoc(String uid) {
    _docSub?.cancel();
    _docSub = _db.collection('customers').doc(uid).snapshots().listen((doc) {
      if (doc.exists) {
        final d = doc.data()!;
        _currentUser = UserModel(
          id: doc.id,
          name: d['name'] ?? '',
          email: d['email'] ?? '',
          phone: d['phone'] ?? '',
        );
      } else {
        _currentUser = null;
      }
      _userController.add(_currentUser);
    });
  }

  Future<void> ensureLoaded() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_currentUser != null) return;
    final doc = await _db.collection('customers').doc(user.uid).get();
    if (doc.exists) {
      final d = doc.data()!;
      _currentUser = UserModel(
        id: doc.id,
        name: d['name'] ?? '',
        email: d['email'] ?? '',
        phone: d['phone'] ?? '',
      );
    }
    _listenToUserDoc(user.uid);
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String phone, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _db.collection('customers').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await ensureLoaded();
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      String msg = 'Registrasi gagal.';
      if (e.code == 'email-already-in-use') msg = 'Email sudah terdaftar.';
      if (e.code == 'weak-password') msg = 'Password terlalu lemah.';
      return {'success': false, 'message': msg};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await ensureLoaded();
      return {'success': true};
    } on FirebaseAuthException catch (_) {
      return {'success': false, 'message': 'Email atau password salah.'};
    }
  }

  Future<void> updateProfile(
      {String? name, String? email, String? phone}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    await _db.collection('customers').doc(user.uid).update(data);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('customers').doc(user.uid).delete();
    await user.delete();
  }

  Future<void> logout() async {
    await _docSub?.cancel();
    _currentUser = null;
    await _auth.signOut();
  }
}
