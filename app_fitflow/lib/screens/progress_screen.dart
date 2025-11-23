import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Biblioteca de gráficos
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;

  // Dados padrão (vazios) para não quebrar se a API falhar
  List<String> _labels = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sab", "Dom"];
  List<int> _aguaData = [0, 0, 0, 0, 0, 0, 0];
  List<int> _exercicioData = [0, 0, 0, 0, 0, 0, 0];
  List<dynamic> _historico = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosGraph();
  }

  void _carregarDadosGraph() async {
    final dados = await _api.getProgressData();
    if (dados != null) {
      if (mounted) {
        setState(() {
          // Converte os dados da API para as listas locais
          _labels = List<String>.from(dados['labels']);
          _aguaData = List<int>.from(dados['agua_semanal']);
          _exercicioData = List<int>.from(dados['exercicio_semanal']);
          _historico = dados['historico_atividades'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text("Progresso & Relatórios", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- GRÁFICO DE HIDRATAÇÃO ---
                  Text("Hidratação (Últimos 7 dias)", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 10),
                  _buildChartContainer(
                    color: Colors.blue,
                    data: _aguaData,
                    labels: _labels,
                    maxY: 4000, // Meta de 4 litros como teto
                  ),

                  const SizedBox(height: 24),

                  // --- GRÁFICO DE EXERCÍCIO ---
                  Text("Exercício (Minutos)", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 10),
                  _buildChartContainer(
                    color: Colors.greenAccent,
                    data: _exercicioData,
                    labels: _labels,
                    maxY: 120, // Meta de 2 horas como teto
                  ),

                  const SizedBox(height: 24),

                  // --- HISTÓRICO RECENTE ---
                  Text("Atividades Recentes", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true, // Importante para funcionar dentro do ScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _historico.length,
                    itemBuilder: (context, index) {
                      final item = _historico[index];
                      return Card(
                        color: const Color(0xFF161B22),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.fitness_center, color: Colors.green),
                          ),
                          title: Text(item['tipo_atividade'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text("${item['duracao_minutos']} min - ${item['intensidade']}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                          trailing: Text("Hoje", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)), // Simplificado
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  // --- WIDGET AUXILIAR PARA CRIAR O GRÁFICO ---
  Widget _buildChartContainer({required Color color, required List<int> data, required List<String> labels, required double maxY}) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1, dashArray: [5, 5]),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Esconde numeros na esquerda
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(labels[index], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
                interval: 1,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.toDouble());
              }).toList(),
              isCurved: true, // Linha suave
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1), // Sombra abaixo da linha
              ),
            ),
          ],
        ),
      ),
    );
  }
}