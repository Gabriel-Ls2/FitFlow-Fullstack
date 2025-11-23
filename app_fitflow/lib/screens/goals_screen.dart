import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  
  // Dados das Metas (Padrão inicial)
  int? _metaId; // Guardamos o ID para saber se é pra criar ou editar
  int _agua = 3000;
  double _sono = 8.0;
  int _exercicio = 60;
  int _refeicoes = 5;

  @override
  void initState() {
    super.initState();
    _fetchMetas();
  }

  void _fetchMetas() async {
    final dados = await _api.getMetas();
    if (mounted) {
      setState(() {
        if (dados != null) {
          _metaId = dados['id'];
          _agua = dados['meta_agua_ml'];
          _sono = dados['meta_sono_horas'];
          _exercicio = dados['meta_exercicio_min'];
          _refeicoes = dados['meta_refeicoes_qtd'];
        }
        _isLoading = false;
      });
    }
  }

  // Abre o modal para editar tudo de uma vez
  void _editarMetas() {
    // Controladores temporários para o modal
    final aguaCtrl = TextEditingController(text: _agua.toString());
    final sonoCtrl = TextEditingController(text: _sono.toString());
    final exercicioCtrl = TextEditingController(text: _exercicio.toString());
    final refeicoesCtrl = TextEditingController(text: _refeicoes.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text("Editar Metas Diárias", style: GoogleFonts.poppins(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildInput("Água (ml)", aguaCtrl),
              _buildInput("Sono (horas)", sonoCtrl),
              _buildInput("Exercício (min)", exercicioCtrl),
              _buildInput("Refeições (qtd)", refeicoesCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              await _api.salvarMetas(
                _metaId,
                int.tryParse(aguaCtrl.text) ?? 3000,
                double.tryParse(sonoCtrl.text) ?? 8.0,
                int.tryParse(exercicioCtrl.text) ?? 60,
                int.tryParse(refeicoesCtrl.text) ?? 5,
              );
              
              _fetchMetas(); // Recarrega a tela
            },
            child: const Text("Salvar", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text("Minhas Metas", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Botão Verde Grande
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _editarMetas,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: Text("Editar Meta", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Lista de Metas (Cards)
                  _buildMetaCard("Sono", "$_sono horas", Icons.bed_outlined, Colors.purpleAccent),
                  _buildMetaCard("Exercício", "$_exercicio min", Icons.fitness_center, Colors.greenAccent),
                  _buildMetaCard("Refeições", "$_refeicoes refeições", Icons.restaurant, Colors.orangeAccent),
                  _buildMetaCard("Água", "$_agua ml", Icons.water_drop_outlined, Colors.blueAccent),
                ],
              ),
            ),
    );
  }

  Widget _buildMetaCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
               // Ação visual apenas, já que o usuário deve editar valores, não deletar a meta inteira
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Use o botão Editar para alterar valor para 0.")));
            },
          )
        ],
      ),
    );
  }
}