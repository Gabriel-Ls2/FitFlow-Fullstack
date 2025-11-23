import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  
  String _username = "Carregando...";
  String _email = "Carregando...";
  bool _notificacoesAtivas = true; // Simulação de estado local

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  void _carregarPerfil() async {
    final dados = await _api.getUserData();
    if (mounted && dados != null) {
      setState(() {
        _username = dados['username'] ?? "Usuário";
        _email = dados['email'].toString().isNotEmpty ? dados['email'] : "Sem email cadastrado";
      });
    }
  }

  void _fazerLogout() async {
    await _api.logout();
    if (mounted) {
      // Remove todas as telas e volta pro Login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text("Perfil", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gerencie suas informações", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),

            // --- BLOCO 1: INFORMAÇÕES PESSOAIS ---
            Text("Informações Pessoais", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabelValue("Nome", _username),
                  const Divider(color: Colors.white10, height: 30),
                  _buildLabelValue("Email", _email),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- BLOCO 2: PREFERÊNCIAS ---
            Text("Preferências", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Permitir Notificações", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      Text("Receber lembretes e notificações", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Switch(
                    value: _notificacoesAtivas,
                    activeColor: const Color(0xFF238636),
                    onChanged: (val) {
                      setState(() => _notificacoesAtivas = val);
                    },
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- BOTÃO SAIR ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _fazerLogout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: Text("Sair", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}