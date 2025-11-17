import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../modelos/veiculos.dart';
import 'veiculos_form.dart';

class VeiculoListPage extends StatefulWidget {
  const VeiculoListPage({super.key});

  @override
  State<VeiculoListPage> createState() => _VeiculoListPageState();
}

class _VeiculoListPageState extends State<VeiculoListPage> {
  final _fs = FirestoreService();
  List<Veiculo> _lista = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    listar();
  }

  Future<void> listar() async {
    final dados = await _fs.getVeiculos();
    setState(() {
      _lista = dados;
      _loading = false;
    });
  }

  void _abrirForm({Veiculo? veiculo}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VeiculoFormPage(veiculo: veiculo),
      ),
    );
    listar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meus Veículos")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _abrirForm(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _lista.isEmpty
              ? const Center(child: Text("Nenhum veículo cadastrado"))
              : ListView.builder(
                  itemCount: _lista.length,
                  itemBuilder: (_, i) {
                    final v = _lista[i];
                    return Card(
                      child: ListTile(
                        title: Text("${v.marca} ${v.modelo}"),
                        subtitle: Text("${v.placa} - ${v.ano}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _abrirForm(veiculo: v),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _fs.deleteVeiculo(v.id!);
                                listar();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
