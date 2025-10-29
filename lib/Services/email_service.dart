import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:investmentpro/Services/keys.dart';
import 'package:firebase_auth/firebase_auth.dart';

class sendEmail {
  ///send mail to that user has logged in
  sendMail({message}) async {
    Map<String, dynamic> templateParams = {
      'name': 'PCL Updates',
      'message': message,
    };

    try {
      await emailjs.send(
        Constance.SERVICE_KEY,
        Constance.TEMPLATE_KEY,
        templateParams,
        const emailjs.Options(
          publicKey: Constance.PUBLIC_KEY,
          privateKey: Constance.PRIVATE_KEY,
          origin: 'http://localhost',
        ),
      );
      print('Email sent SUCCESS!');
    } catch (error) {
      print('$error');
    }
  }
}


// '''👋 A Client with Name (${fullName}) and email address ${FirebaseAuth.instance.currentUser!.email} is now active on your Krypto platform!
// And About to (${action})! Log in to see what he is doing.'''