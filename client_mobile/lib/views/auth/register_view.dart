import 'package:client_leger/services/auth/register_service.dart';
import 'package:client_leger/views/auth/avatar_option_view.dart';
import 'package:client_leger/views/auth/sign_in_view.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  final _controllerUser = TextEditingController();
  RegisterService registerService = RegisterService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // Init values when created
    super.initState();
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerUser.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Inscrivez-vous à PolyScrabble'),
        backgroundColor: Colors.green[900],
      ),
      body: Container(
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/scrabble-logo-client-web.png',
                    width: 400,
                    height: 150,
                  ),
                  const Text("Créer votre compte PolyScrabble"),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _controllerUser,
                      decoration: const InputDecoration(
                        hintText: "Nom d'utilisateur",
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom d\'utilisateur';
                        } else if (value.length < 3) {
                          return 'Le nom est trop court';
                        } else if (value.length > 12) {
                          return 'Le nom est trop long';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _controllerEmail,
                      decoration: const InputDecoration(
                        hintText: "adresse email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un email';
                        } else if (!value.contains("@") ||
                            !value.contains(".")) {
                          return 'Veuillez entrer un email valid';
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
                        hintText: "mot de passe",
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(200, 50),
                        backgroundColor: Colors.green[900]),
                    onPressed: () => registerUserWithEmail(_controllerUser.text,
                        _controllerEmail.text, _controllerPassword.text),
                    child: const Text("Créer"),
                  ),
                  const SizedBox(height: 40.0),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.green[900]),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    ),
                    child: const Text("Vous avez déja un compte ? Cliquez ici"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void registerUserWithEmail(username, email, password) async {
    if (!_formKey.currentState!.validate()) return;
    String registerStatus =
        await registerService.registerNewAccount(username, email, password);
    if (registerStatus == "success") {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: ((context) => AvatarOption(
                userName_: username,
                isNewAccount: true,
              )),
        ),
      );
    } else {
      displayError(registerStatus);
    }
  }

  void displayError(String message) {
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
}
