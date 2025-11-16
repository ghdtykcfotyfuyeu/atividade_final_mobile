import 'package:atividadefinal/src/usuarios/login.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistrarPage extends StatefulWidget {
  const RegistrarPage({super.key});

  @override
  State<RegistrarPage> createState() => _RegistrarPageState();
}

class _RegistrarPageState extends State<RegistrarPage> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  bool _loading = false;
  String? _mensagemGeral;
  bool _mostrarSenha = false;

  String? _erroEmail;
  String? _erroSenha;

  void _registrar() async {
    setState(() {
      _mensagemGeral = null;
      _erroEmail = null;
      _erroSenha = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    String email = _email.text.trim();
    String senha = _senha.text.trim();

    String? erro = await _auth.registrar(email, senha);

    setState(() => _loading = false);

    if (erro != null) {
      setState(() => _mensagemGeral = erro);

      if (erro.contains("email")) {
        _erroEmail = erro;
      } else if (erro.contains("senha") || erro.contains("caracteres")) {
        _erroSenha = erro;
      }

      return;
    }

    setState(() => _mensagemGeral = "Conta criada com sucesso!");
    Future.delayed(const Duration(seconds: 0), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_mensagemGeral != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _mensagemGeral!,
                    style: TextStyle(
                      color: _mensagemGeral!.contains("sucesso")
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                    return "Informe um e-mail válido";
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
                    hintText: "Mínimo de 6 caracteres",
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
                    )),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Digite uma senha";
                  }
                  if (v.length < 6) {
                    return "A senha deve ter pelo menos 6 caracteres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _registrar,
                      label: const Text("Criar Conta"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
