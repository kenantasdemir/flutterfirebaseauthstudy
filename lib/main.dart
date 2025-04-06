import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase'i başlat
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FirebaseAuthStudy(),
    );
  }
}

class FirebaseAuthStudy extends StatelessWidget {
  FirebaseAuthStudy({super.key});

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }


Future<UserCredential> signInWithFacebook() async {
  final LoginResult loginResult = await FacebookAuth.instance.login();

  final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

  return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
}


  Future<void> profileInfos() async{
    var user = FirebaseAuth.instance.currentUser;
    if(user != null){
      var displayName = user.displayName;
      var email = user.email;
      var phoneNumber = user.phoneNumber;
      var photoURL = user.photoURL;
        debugPrint("$displayName $email $phoneNumber $photoURL");
    }
    await user?.updateDisplayName("Kenan Taşdemir");
    await user?.updatePassword("reallyStrongPwd123");
    await user?.updatePhotoURL("url");

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Auth Study")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                auth.createUserWithEmailAndPassword(
                  email: "ornekmail@hotmail.com",
                  password: "reallyStongPassword159",
                );
              },
              child: Text("Email ile kullanıcı oluşturma"),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                auth.signInWithEmailAndPassword(
                  email: "email",
                  password: "password",
                );
              },
              child: Text("Email ile giriş"),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                auth.signInWithPhoneNumber("5423452435423");
              },
              child: Text("Şifre ile giriş yap"),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                auth.sendPasswordResetEmail(email: "email");
              },
              child: Text("parola sıfırlama email gönder"),
            ),
            SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                auth.signOut();
              },
              child: Text("Çıkış yap"),
            ),
            SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                auth.confirmPasswordReset(
                  code: "code",
                  newPassword: "newPassword",
                );
              },
              child: Text("Parola sıfırlama işlemini onayla"),
            ),
            SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                signInWithGoogle();
              },
              child: Text("gmail ile giriş yap"),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: '+90 123 456 78 90',
                  verificationCompleted: (PhoneAuthCredential credential) {},
                  verificationFailed: (FirebaseAuthException e) {},
                  codeSent: (String verificationId, int? resendToken) {},
                  codeAutoRetrievalTimeout: (String verificationId) {},
                );
              },
              child: Text("Telefon numarası onayla"),
            ),
             SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                signInWithFacebook();
              },
              child: Text("Facebook ile giriş yap"),
            ),
          ],
        ),
      ),
    );
  }
}
