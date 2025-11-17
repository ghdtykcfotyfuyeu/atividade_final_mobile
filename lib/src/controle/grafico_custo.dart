import 'package:atividadefinal/src/modelos/abastecimento.dart';
import 'package:atividadefinal/src/modelos/veiculos.dart';
import 'package:atividadefinal/src/services/firestore_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoPage extends StatefulWidget {
  const GraficoPage({super.key});

  @override
  State<GraficoPage> createState() => _GraficoPageState();
}

class _GraficoPageState extends State<GraficoPage> {
  final _fs = FirestoreService();

  List<Abastecimento> _abastecimentos = [];
  List<Veiculo> _veiculos = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    _veiculos = await _fs.getVeiculos();
    _abastecimentos = await _fs.getAbastecimentos();

    setState(() => _loading = false);
  }

  Map<String, double> calcularGastosPorVeiculo() {
    Map<String, double> resultado = {};

    for (var v in _veiculos) {
      resultado[v.id!] = 0;
    }

    for (var a in _abastecimentos) {
      if (resultado.containsKey(a.veiculoId)) {
        resultado[a.veiculoId] = resultado[a.veiculoId]! + a.valorPago;
      }
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gráfico de Custos por Veículo"),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _veiculos.isEmpty
              ? const Center(child: Text("Nenhum veículo cadastrado"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Custo total de abastecimentos por veículo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 80),
                      Expanded(
                        child: BarChart(
                          gerarGrafico(calcularGastosPorVeiculo()),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  BarChartData gerarGrafico(Map<String, double> dados) {
    final bars = <BarChartGroupData>[];
    int index = 0;

    final veiculosPorId = {
      for (var v in _veiculos) v.id!: "${v.marca} ${v.modelo}"
    };

    dados.forEach((veiculoId, totalGasto) {
      bars.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: totalGasto,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
              width: 20,
            ),
          ],
        ),
      );
      index++;
    });

    return BarChartData(
      barGroups: bars,
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final vid = dados.keys.elementAt(value.toInt());
              final nome = veiculosPorId[vid] ?? "Veículo";

              return RotatedBox(
                quarterTurns: 0,
                child: Text(
                  nome,
                  style: const TextStyle(fontSize: 20),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
    );
  }
}
