import 'package:client_leger/classes/user_profil.dart';
import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/services/auth/sign_in_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:uuid/uuid.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // text field state
  SignInService signInService = SignInService();
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  final uuid = const Uuid().v1();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green[700],
        title: const Text('Connectez-vous à PolyScrabble'),
      ),
      body: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/scrabble-logo-client-web.png',
                    width: 500,
                    height: 200,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _controllerEmail,
                      decoration: const InputDecoration(
                        hintText: 'Entrez votre email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (_) {
                        if (_controllerEmail.text.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _controllerPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Entrez votre mot de passe',
                        border: OutlineInputBorder(),
                      ),
                      validator: (_) {
                        if (_controllerPassword.text.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 50),
                      backgroundColor: Colors.green[700],
                    ),
                    onPressed: () => signIn(),
                    child: const Text("Se connecter"),
                  ),
                  const SizedBox(height: 50.0),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute,
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Vous n\'avez pas de compte? S\'inscrire',
                      style: TextStyle(color: Colors.green[900]),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  signIn() async {
    if (!_formKey.currentState!.validate()) return;
    loadingIndicator();
    Navigator.of(context).pop();
    var res = await signInService.signInToAccount(
        _controllerEmail.text, _controllerPassword.text);
    switch (res) {
      case 'user-already-connected':
        displayErrorMessage("L'utilisateur est déjà connecté.");
        break;
      case 'user-incorrect-password':
        displayErrorMessage("Mot de passe erroné.");
        break;
      case 'user-not-exist':
        displayErrorMessage("Ce compte n'existe pas.");
        break;
      case 'unknown':
        displayErrorMessage("Erreur inconnue");
        break;
      default:
        UserProfile userProfile = res as UserProfile;

        await SessionManager().set("currentUser", userProfile);
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          mainMenuRoute,
          (route) => false,
        );
    }
    // Login success -> Go to Chat Room
    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil(mainMenuRoute, (route) => false);

    // var status = res.body.statusCode;
    //     .catchError((err) {
    //   switch (err.toString()) {
    //     case 'user-already-connected':
    //       displayErrorMessage("L'utilisateur est déjà connecté.");
    //       break;
    //     case 'user-incorrect-password':
    //       displayErrorMessage("Mot de passe erroné.");
    //       break;
    //     case 'user-not-exist':
    //       displayErrorMessage("Ce compte n'existe pas.");
    //       break;
    //     case 'unknown':
    //       displayErrorMessage("Erreur inconnue");
    //       break;
    //     default:
    //   }
    // ).then((userProfil) async {

    //   await SessionManager().set("currentUser", userProfil);
    //   if (!mounted) return;
    //   Navigator.of(context).pushNamedAndRemoveUntil(
    //     mainMenuRoute,
    //     (route) => false,
    //   );
    // });
    // Login success -> Go to Chat Room
    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil(mainMenuRoute, (route) => false);
  }

  void displayErrorMessage(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red.shade900,
      elevation: 5,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      action: SnackBarAction(
        label: 'Ok',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void loadingIndicator() {
    showDialog(
        // The user CANNOT close this dialog  by pressing outside it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text('Loading...')
                ],
              ),
            ),
          );
        });
  }
}
