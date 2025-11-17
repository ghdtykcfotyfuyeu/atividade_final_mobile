import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../modelos/veiculos.dart';

class VeiculoFormPage extends StatefulWidget {
  final Veiculo? veiculo;

  const VeiculoFormPage({super.key, this.veiculo});

  @override
  State<VeiculoFormPage> createState() => _VeiculoFormPageState();
}

class _VeiculoFormPageState extends State<VeiculoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fs = FirestoreService();

  final _modelo = TextEditingController();
  final _marca = TextEditingController();
  final _placa = TextEditingController();
  final _ano = TextEditingController();
  String _tipoCombustivel = "Gasolina";

  @override
  void initState() {
    super.initState();
    if (widget.veiculo != null) {
      _modelo.text = widget.veiculo!.modelo;
      _marca.text = widget.veiculo!.marca;
      _placa.text = widget.veiculo!.placa;
      _ano.text = widget.veiculo!.ano.toString();
      _tipoCombustivel = widget.veiculo!.tipoCombustivel;
    }
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final veiculo = Veiculo(
      id: widget.veiculo?.id,
      modelo: _modelo.text,
      marca: _marca.text,
      placa: _placa.text,
      ano: int.parse(_ano.text),
      tipoCombustivel: _tipoCombustivel,
    );

    if (widget.veiculo == null) {
      await _fs.addVeiculo(veiculo);
    } else {
      await _fs.updateVeiculo(veiculo);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.veiculo == null ? "Novo Veículo" : "Editar Veículo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _modelo,
                decoration: const InputDecoration(labelText: "Modelo"),
                validator: (v) => v!.isEmpty ? "Informe o modelo" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marca,
                decoration: const InputDecoration(labelText: "Marca"),
                validator: (v) => v!.isEmpty ? "Informe a marca" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placa,
                decoration: const InputDecoration(labelText: "Placa"),
                validator: (v) => v!.isEmpty ? "Informe a placa" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ano,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Ano"),
                validator: (v) => v!.isEmpty ? "Informe o ano" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipoCombustivel,
                decoration:
                    const InputDecoration(labelText: "Tipo de Combustível"),
                items: const [
                  DropdownMenuItem(value: "Gasolina", child: Text("Gasolina")),
                  DropdownMenuItem(value: "Etanol", child: Text("Etanol")),
                  DropdownMenuItem(value: "Diesel", child: Text("Diesel")),
                ],
                onChanged: (v) => _tipoCombustivel = v!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text("Salvar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
