import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:loginfacebook/src/services/auth_service.dart';

class AuthBloc {
  final authService = AuthService();
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  Stream<User> get currentUser => authService.currentUser;

  loginFacebook() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    final AuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken.token);

    //Firebase Sign in
    final resultSignIn = await authService.signInWhithCredential(credential);

    print('User - Display name${resultSignIn.user.displayName}');
    print('User - email: ${resultSignIn.user.email}');

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        getUserInfo(result);
        print('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  void getUserInfo(FacebookLoginResult result) async {
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
    final profile = json.decode(graphResponse.body);

    print('Email: ${profile['email']}');
    print('Nombre: ${profile['name']}');
  }

  Future<Null> logOut() async {
    await facebookSignIn.logOut();
    authService.logout();
    print('Logged out.');
  }
}
