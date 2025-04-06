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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Auth Study")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
              createUserEmailAndPassword();
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
          loginWithPhoneNumber();
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

    void deleteUser() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      debugPrint('Kullanıcı oturum açmadığı için silinemez');
    }
  }

  
  void createUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      var _myUser = _userCredential.user;

      if (!_myUser!.emailVerified) {
        await _myUser.sendEmailVerification();
      } else {
        debugPrint('kullanıcın maili onaylanmış, ilgili sayfaya gidebilir.');
      }

      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }


  
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

   void googleIleGiris() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void changeEmail() async {
    try {
      await auth.currentUser!.updateEmail('emre@emre.com');
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        debugPrint('reauthenticate olunacak');
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updateEmail('emrealtunbilek@gmail.com');
        await auth.signOut();
        debugPrint('email güncellendi');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  
  void signOutUser() async {
    var _user = GoogleSignIn().currentUser;
    if (_user != null) {
      await GoogleSignIn().signOut();
    }
    await auth.signOut();
  }



  void changePassword() async {
    try {
      await auth.currentUser!.updatePassword('password');
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        debugPrint('reauthenticate olunacak');
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updatePassword('password');
        await auth.signOut();
        debugPrint('şifre güncellendi');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  
  void loginWithPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+905547126450',
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('verification completed tetiklendi');
        debugPrint(credential.toString());
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        String _smsCode = "123456";
        debugPrint('code sent tetiklendi');
        var _credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _smsCode);

        await auth.signInWithCredential(_credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('code auto retrieval timeout');
      },
    );
  }





  
}
