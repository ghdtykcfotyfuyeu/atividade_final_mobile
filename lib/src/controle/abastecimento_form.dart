import 'package:flutter/material.dart';
import '../modelos/abastecimento.dart';
import '../modelos/veiculos.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbastecimentoFormPage extends StatefulWidget {
  final Abastecimento? abastecimento;

  const AbastecimentoFormPage({super.key, this.abastecimento});

  @override
  State<AbastecimentoFormPage> createState() => _AbastecimentoFormPageState();
}

class _AbastecimentoFormPageState extends State<AbastecimentoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fs = FirestoreService();

  DateTime _data = DateTime.now();
  final _litros = TextEditingController();
  final _valor = TextEditingController();
  final _km = TextEditingController();
  String _combustivel = "Gasolina";
  String? _veiculoId;
  final _obs = TextEditingController();

  List<Veiculo> _veiculos = [];

  @override
  void initState() {
    super.initState();
    carregarVeiculos();

    if (widget.abastecimento != null) {
      final a = widget.abastecimento!;
      _data = a.data;
      _litros.text = a.quantidadeLitros.toString();
      _valor.text = a.valorPago.toString();
      _km.text = a.quilometragem.toString();
      _combustivel = a.tipoCombustivel;
      _veiculoId = a.veiculoId;
      _obs.text = a.observacao ?? "";
    }
  }

  Future<void> carregarVeiculos() async {
    _veiculos = await _fs.getVeiculos();
    setState(() {});
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final litros = double.parse(_litros.text);
    final km = double.parse(_km.text);
    final consumo = km / litros;

    final registro = Abastecimento(
      id: widget.abastecimento?.id,
      data: _data,
      quantidadeLitros: litros,
      valorPago: double.parse(_valor.text),
      quilometragem: km,
      tipoCombustivel: _combustivel,
      veiculoId: _veiculoId!,
      consumo: consumo,
      observacao: _obs.text,
      ownerUid: FirebaseAuth.instance.currentUser!.uid,
    );

    if (widget.abastecimento == null) {
      await _fs.addAbastecimento(registro);
    } else {
      await _fs.updateAbastecimento(registro);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(widget.abastecimento == null
            ? "Novo Abastecimento"
            : "Editar Abastecimento"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Data: ${_data.day}/${_data.month}/${_data.year}"),
              ElevatedButton(
                onPressed: () async {
                  final selecionada = await showDatePicker(
                    context: context,
                    initialDate: _data,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (selecionada != null) {
                    setState(() => _data = selecionada);
                  }
                },
                child: const Text("Selecionar Data"),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _veiculoId,
                decoration: const InputDecoration(labelText: "Veículo"),
                items: _veiculos.map((v) {
                  return DropdownMenuItem(
                    value: v.id,
                    child: Text("${v.marca} ${v.modelo} (${v.placa})"),
                  );
                }).toList(),
                validator: (v) => v == null ? "Selecione um veículo" : null,
                onChanged: (v) => setState(() => _veiculoId = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litros,
                decoration:
                    const InputDecoration(labelText: "Quantidade de Litros"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Informe os litros" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valor,
                decoration: const InputDecoration(labelText: "Valor Pago"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Informe o valor" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _km,
                decoration:
                    const InputDecoration(labelText: "Quilometragem rodada"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Informe a quilometragem" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _combustivel,
                decoration:
                    const InputDecoration(labelText: "Tipo de Combustível"),
                items: const [
                  DropdownMenuItem(value: "Gasolina", child: Text("Gasolina")),
                  DropdownMenuItem(value: "Etanol", child: Text("Etanol")),
                  DropdownMenuItem(value: "Diesel", child: Text("Diesel")),
                ],
                onChanged: (v) => _combustivel = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _obs,
                decoration:
                    const InputDecoration(labelText: "Observação (opcional)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
