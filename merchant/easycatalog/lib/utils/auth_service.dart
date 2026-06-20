import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantUser {
  final String id;
  String ownerName;
  String email;
  String phone;
  String restaurantName;
  String restaurantLocation;
  Map<String, dynamic> menu;

  MerchantUser({
    required this.id,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.restaurantName,
    required this.restaurantLocation,
    this.menu = const {},
  });

  factory MerchantUser.fromMap(String id, Map<String, dynamic> d) =>
      MerchantUser(
        id: id,
        ownerName: d['ownerName'] ?? '',
        email: d['email'] ?? '',
        phone: d['phone'] ?? '',
        restaurantName: d['restaurantName'] ?? '',
        restaurantLocation: d['restaurantLocation'] ?? '',
        menu: Map<String, dynamic>.from(d['menu'] ?? {}),
      );
}

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

  MerchantUser? _currentUser;
  MerchantUser? get currentUser => _currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  StreamSubscription? _docSub;
  final _userController = StreamController<MerchantUser?>.broadcast();
  Stream<MerchantUser?> get userStream => _userController.stream;

  void _listenToUserDoc(String uid) {
    _docSub?.cancel();
    _docSub = _db.collection('merchants').doc(uid).snapshots().listen((doc) {
      if (doc.exists) {
        _currentUser = MerchantUser.fromMap(doc.id, doc.data()!);
      } else {
        _currentUser = null;
      }
      _userController.add(_currentUser);
    });
  }

  /// Dipanggil saat splash screen untuk memastikan data user sudah termuat
  /// sebelum masuk ke Dashboard.
  Future<void> ensureLoaded() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_currentUser != null) return;
    final doc = await _db.collection('merchants').doc(user.uid).get();
    if (doc.exists) {
      _currentUser = MerchantUser.fromMap(doc.id, doc.data()!);
    }
    _listenToUserDoc(user.uid);
  }

  Future<Map<String, dynamic>> register({
    required String ownerName,
    required String email,
    required String phone,
    required String password,
    required String restaurantName,
    required String restaurantLocation,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _db.collection('merchants').doc(cred.user!.uid).set({
        'ownerName': ownerName,
        'email': email,
        'phone': phone,
        'restaurantName': restaurantName,
        'restaurantLocation': restaurantLocation,
        'menu': {},
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
    } on FirebaseAuthException catch (e) {
      String msg = 'Login gagal.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        msg = 'Email atau password salah.';
      }
      return {'success': false, 'message': msg};
    }
  }

  Future<void> updateProfile({
    String? ownerName,
    String? email,
    String? phone,
    String? restaurantName,
    String? restaurantLocation,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final data = <String, dynamic>{};
    if (ownerName != null) data['ownerName'] = ownerName;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (restaurantName != null) data['restaurantName'] = restaurantName;
    if (restaurantLocation != null)
      data['restaurantLocation'] = restaurantLocation;
    await _db.collection('merchants').doc(user.uid).update(data);
  }

  Future<void> updateRestaurantInfo(String name, String location) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('merchants').doc(user.uid).set({
      'restaurantName': name,
      'restaurantLocation': location,
    }, SetOptions(merge: true));
  }

  Future<void> updateMenu(Map<String, dynamic> menu) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('merchants')
        .doc(user.uid)
        .set({'menu': menu}, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) return {'success': false, 'message': 'Tidak ada user.'};
    try {
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return {'success': true};
    } on FirebaseAuthException catch (_) {
      return {'success': false, 'message': 'Password lama salah.'};
    }
  }

  Future<void> logout() async {
    await _docSub?.cancel();
    _currentUser = null;
    await _auth.signOut();
  }

  Map<String, dynamic>? get restaurant {
    if (_currentUser == null) return null;
    return {
      'name': _currentUser!.restaurantName,
      'location': _currentUser!.restaurantLocation,
      'menu': _currentUser!.menu,
    };
  }
}
