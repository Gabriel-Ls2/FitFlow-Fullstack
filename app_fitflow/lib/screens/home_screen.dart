import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'progress_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  
  String _username = "Usuário";
  // Variáveis
  Map<String, dynamic> _dados = {
    "agua_hoje": 0,
    "exercicio_hoje": 0,
    "sono_hoje": 0.0,
    "refeicoes_hoje": 0
  };
  
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _tempoFormatado = "00:00:00";

  @override
  void initState() {
    super.initState();
    _carregarDados();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          _tempoFormatado = _formatarTempo(_stopwatch.elapsedMilliseconds);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _carregarDados() async {
    final dashboardData = await _api.getDashboardData();
    final userData = await _api.getUserData();

    if (mounted) {
      setState(() {
        if (dashboardData != null) {
          _dados = dashboardData;
        }
        if (userData != null) {
          _username = userData['username'];
        }
      });
    }
  }

  // --- NOVA FUNÇÃO: MODAL DE ÁGUA ---
  void _mostrarModalAgua() {
    int quantidadeSelecionada = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161B22), // Fundo escuro do modal
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text("Adicionar Água", style: GoogleFonts.poppins(color: Colors.white)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Texto Grande com o valor atual
                  Text("${quantidadeSelecionada}ml", 
                    style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent)
                  ),
                  const SizedBox(height: 20),
                  
                  // Grid de Botões (+250, +500...)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [250, 500, 750, 1000].map((valor) {
                      return ElevatedButton(
                        onPressed: () {
                          setModalState(() {
                            quantidadeSelecionada += valor;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text("+$valor ml", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar", style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (quantidadeSelecionada > 0) {
                      // 1. Fecha o modal
                      Navigator.pop(context);
                      
                      // 2. Envia para o Django
                      bool sucesso = await _api.registrarAgua(quantidadeSelecionada);
                      
                      // 3. Se deu certo, atualiza a tela
                      if (sucesso) {
                        _carregarDados(); // <--- Recarrega os gráficos
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Hidratação registrada! 💧"), backgroundColor: Colors.green),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
                  child: Text("Adicionar", style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _mostrarModalExercicio() {
    String atividade = 'Caminhada';
    String intensidade = 'Moderada';
    final duracaoController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161B22),
            title: Text("Registrar Exercício", style: GoogleFonts.poppins(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown Atividade
                DropdownButtonFormField<String>(
                  value: atividade,
                  dropdownColor: const Color(0xFF161B22),
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Atividade'),
                  items: ['Caminhada', 'Corrida', 'Musculação', 'Natação', 'Outro']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setModalState(() => atividade = v!),
                ),
                // Input Duração
                TextField(
                  controller: duracaoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duração (minutos)'),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                // Dropdown Intensidade
                DropdownButtonFormField<String>(
                  value: intensidade,
                  dropdownColor: const Color(0xFF161B22),
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Intensidade'),
                  items: ['Baixa', 'Moderada', 'Intensa']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setModalState(() => intensidade = v!),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
                onPressed: () async {
                  int duracao = int.tryParse(duracaoController.text) ?? 0;
                  if (duracao > 0) {
                    Navigator.pop(context);
                    bool ok = await _api.registrarExercicio(atividade, duracao, intensidade);
                    if (ok) {
                       _carregarDados();
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exercício salvo! 💪")));
                    }
                  }
                },
                child: const Text("Registrar", style: TextStyle(color: Colors.white)),
              )
            ],
          );
        });
      },
    );
  }
  void _mostrarModalSono() {
    double horas = 8.0;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161B22),
            title: Text("Registrar Sono", style: GoogleFonts.poppins(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${horas.toStringAsFixed(1)} horas", style: GoogleFonts.poppins(fontSize: 32, color: Colors.purpleAccent)),
                Slider(
                  value: horas,
                  min: 0, max: 12, divisions: 24,
                  activeColor: Colors.purpleAccent,
                  onChanged: (v) => setModalState(() => horas = v),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
                onPressed: () async {
                  Navigator.pop(context);
                  bool ok = await _api.registrarSono(horas);
                  if (ok) {
                    _carregarDados();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Boa noite de sono! 🌙")));
                  }
                },
                child: const Text("Salvar", style: TextStyle(color: Colors.white)),
              )
            ],
          );
        });
      },
    );
  }
  void _mostrarModalRefeicao() {
    String tipo = 'Café da Manhã';
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161B22),
            title: Text("Registrar Refeição", style: GoogleFonts.poppins(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tipo,
                  dropdownColor: const Color(0xFF161B22),
                  style: GoogleFonts.poppins(color: Colors.white),
                  items: ['Café da Manhã', 'Almoço', 'Jantar', 'Lanche']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setModalState(() => tipo = v!),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'O que você comeu?'),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
                onPressed: () async {
                  Navigator.pop(context);
                  bool ok = await _api.registrarRefeicao(tipo, descController.text);
                  if (ok) {
                    _carregarDados();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Refeição registrada! 🥗")));
                  }
                },
                child: const Text("Salvar", style: TextStyle(color: Colors.white)),
              )
            ],
          );
        });
      },
    );
  }
  // ----------------------------------

  void _toggleCronometro() {
    setState(() {
      if (_stopwatch.isRunning) _stopwatch.stop();
      else _stopwatch.start();
    });
  }

  String _formatarTempo(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$minutesStr:$secondsStr";
  }

  void _logout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Olá, $_username! 👋", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Mantenha o foco.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(onPressed: _carregarDados, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.redAccent)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildInfoCard("Hidratação", "${_dados['agua_hoje']}ml", Icons.water_drop, Colors.blue, (_dados['agua_hoje'] / 3000).clamp(0.0, 1.0)),
                _buildInfoCard("Sono", "${_dados['sono_hoje']}h", Icons.bed, Colors.purpleAccent, (_dados['sono_hoje'] / 8).clamp(0.0, 1.0)),
                _buildInfoCard("Exercício", "${_dados['exercicio_hoje']}min", Icons.fitness_center, Colors.greenAccent, (_dados['exercicio_hoje'] / 60).clamp(0.0, 1.0)),
                _buildInfoCard("Refeições", "${_dados['refeicoes_hoje']}", Icons.restaurant, Colors.orangeAccent, (_dados['refeicoes_hoje'] / 5).clamp(0.0, 1.0)),
              ],
            ),
            const SizedBox(height: 24),

            // Cronômetro
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text("Cronômetro de Exercício", style: GoogleFonts.poppins(color: Colors.grey)),
                  Text(_tempoFormatado, style: GoogleFonts.jetBrainsMono(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _toggleCronometro,
                    icon: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_stopwatch.isRunning ? "Pausar" : "Iniciar"),
                    style: ElevatedButton.styleFrom(backgroundColor: _stopwatch.isRunning ? Colors.orange[800] : const Color(0xFF238636), foregroundColor: Colors.white),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botões de Ação Rápida
            Text("Adicionar Rápido", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildQuickAddButton("Água", Icons.water_drop, Colors.blue, _mostrarModalAgua)),
                const SizedBox(width: 10),
                Expanded(child: _buildQuickAddButton("Sono", Icons.bed, Colors.purple, _mostrarModalSono)), // <--- CORRIGIDO
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildQuickAddButton("Treino", Icons.fitness_center, Colors.green, _mostrarModalExercicio)), // <--- CORRIGIDO
                const SizedBox(width: 10),
                Expanded(child: _buildQuickAddButton("Comida", Icons.restaurant, Colors.orange, _mostrarModalRefeicao)), // <--- CORRIGIDO
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D1117),
        selectedItemColor: const Color(0xFF238636),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // Por enquanto fixo na Home
        onTap: (index) {
          if (index == 1) { 
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressScreen()));
          } else if (index == 2) { 
            Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsScreen()));
          } else if (index == 3) { // <--- NOVO: PERFIL (Índice 3)
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Progresso"),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: "Metas"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: color, size: 20), Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold))]),
          LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.2), color: color, minHeight: 4, borderRadius: BorderRadius.circular(2))
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(label, style: GoogleFonts.poppins(color: Colors.white70))]),
      ),
    );
  }
}