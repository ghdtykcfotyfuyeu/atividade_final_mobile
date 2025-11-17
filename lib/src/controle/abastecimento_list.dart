import 'package:flutter/material.dart';
import '../modelos/abastecimento.dart';
import '../services/firestore_service.dart';
import 'abastecimento_form.dart';

class AbastecimentoListPage extends StatefulWidget {
  const AbastecimentoListPage({super.key});

  @override
  State<AbastecimentoListPage> createState() => _AbastecimentoListPageState();
}

class _AbastecimentoListPageState extends State<AbastecimentoListPage> {
  final _fs = FirestoreService();
  List<Abastecimento> _lista = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      final dados = await _fs.getAbastecimentos();
      setState(() {
        _lista = dados;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print("ERRO AO LISTAR ABASTECIMENTOS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Meus Abastecimentos")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.local_gas_station),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AbastecimentoFormPage(),
            ),
          );
          carregar();
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _lista.isEmpty
              ? const Center(child: Text("Nenhum abastecimento registrado"))
              : ListView.builder(
                  itemCount: _lista.length,
                  itemBuilder: (_, i) {
                    final a = _lista[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          "${a.data.day}/${a.data.month}/${a.data.year}",
                        ),
                        subtitle: Text(
                          "Litros: ${a.quantidadeLitros}  |  Consumo: ${a.consumo.toStringAsFixed(1)} km/L",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AbastecimentoFormPage(
                                      abastecimento: a,
                                    ),
                                  ),
                                );
                                carregar();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _fs.deleteAbastecimento(a.id!);
                                carregar();
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
