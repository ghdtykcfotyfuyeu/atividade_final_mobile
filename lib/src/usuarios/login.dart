import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../home.dart';
import 'registrar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  bool _loading = false;

  String? _erroEmail;
  String? _erroSenha;
  String? _mensagemGeral;

  bool _mostrarSenha = false;

  void _realizarLogin() async {
    setState(() {
      _mensagemGeral = null;
      _erroEmail = null;
      _erroSenha = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    String email = _email.text.trim();
    String senha = _senha.text.trim();

    String? erro = await _auth.login(email, senha);

    setState(() => _loading = false);

    if (erro != null) {
      setState(() => _mensagemGeral = erro);

      if (erro.contains("email")) {
        _erroEmail = erro;
      } else if (erro.contains("senha")) {
        _erroSenha = erro;
      }

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Text(
                "Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (_mensagemGeral != null)
                Text(
                  _mensagemGeral!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  hintText: "Exemplo: usuario@gmail.com",
                  border: const OutlineInputBorder(),
                  errorText: _erroEmail,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Informe seu e-mail";
                  }
                  if (!v.contains("@") || !v.contains(".")) {
                    return "Formato de e-mail inválido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senha,
                obscureText: !_mostrarSenha,
                decoration: InputDecoration(
                  labelText: "Senha",
                  hintText: "Digite sua senha",
                  border: const OutlineInputBorder(),
                  errorText: _erroSenha,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarSenha ? Icons.visibility : Icons.visibility_off,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () {
                      setState(() {
                        _mostrarSenha = !_mostrarSenha;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Digite sua senha";
                  }
                  if (v.length < 6) {
                    return "A senha deve ter pelo menos 6 caracteres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _realizarLogin,
                      child: const Text("Entrar"),
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text("Criar conta"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistrarPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
