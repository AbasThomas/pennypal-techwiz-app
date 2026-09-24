import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_user.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._auth, this._db);
  final FirebaseAuth _auth; final FirebaseFirestore _db;
  Future<AuthUser> login(String email, String password) async { final credential=await _auth.signInWithEmailAndPassword(email: email,password: password); return _profile(credential.user!); }
  Future<AuthUser> register(Map<String,dynamic> data) async { final c=await _auth.createUserWithEmailAndPassword(email:data['email'],password:data['password']); await c.user!.updateDisplayName(data['fullName']); await _db.collection('users').doc(c.user!.uid).set({'email':data['email'],'fullName':data['fullName'],'phoneNumber':data['phoneNumber'],'role':'student','createdAt':FieldValue.serverTimestamp()}); await _db.collection('userProfiles').doc(c.user!.uid).set({'userId':c.user!.uid,'email':data['email'],'fullName':data['fullName'],'phoneNumber':data['phoneNumber'],'role':'student','createdAt':FieldValue.serverTimestamp()}); await c.user!.sendEmailVerification(); return _profile(c.user!); }
  Future<AuthUser?> restore() async => _auth.currentUser == null ? null : _profile(_auth.currentUser!);
  Future<AuthUser> _profile(User user) async { final doc=await _db.collection('userProfiles').doc(user.uid).get(); final v=doc.data() ?? {}; final names=(v['fullName']??user.displayName??'').toString().trim().split(RegExp(r'\s+')); return AuthUser(id:user.uid,email:user.email??'',firstName:names.isEmpty?'':names.first,lastName:names.length>1?names.skip(1).join(' '):'',isEmailVerified:user.emailVerified,role:(v['role']??'student').toString(),phoneNumber:v['phoneNumber'] as String?); }
  Future<void> logout()=>_auth.signOut();
  Future<void> forgot(String email)=>_auth.sendPasswordResetEmail(email:email);
  Future<void> verifyEmail() => _auth.currentUser!.sendEmailVerification();
}
