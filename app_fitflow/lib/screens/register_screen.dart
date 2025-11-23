import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfirmController = TextEditingController();
  
  final _api = ApiService();
  bool _isLoading = false;

  void _fazerCadastro() async {
    // Validação básica
    if (_passController.text != _passConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Chama a API
    final erro = await _api.register(
      _userController.text, 
      _emailController.text, 
      _passController.text,
      _passConfirmController.text
    );

    setState(() => _isLoading = false);

    if (erro == null) {
      // Sucesso! Vai direto para a Home logado
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Seta de voltar preta
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 120, 
              ),
              Text('Crie sua conta', 
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A1F36))
              ),
              const SizedBox(height: 8),
              Text('Comece sua jornada saudável hoje', 
                style: GoogleFonts.poppins(color: Colors.grey[600])
              ),
              const SizedBox(height: 30),

              // Inputs com estilo corrigido
              _buildInput("Usuário", Icons.person, _userController, false),
              const SizedBox(height: 16),
              _buildInput("Email", Icons.email, _emailController, false),
              const SizedBox(height: 16),
              _buildInput("Senha", Icons.lock, _passController, true),
              const SizedBox(height: 16),
              _buildInput("Confirmar Senha", Icons.lock_outline, _passConfirmController, true),
              
              const SizedBox(height: 24),

              // Botão Cadastrar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _fazerCadastro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1F36), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('CADASTRAR', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNÇÃO AUXILIAR ATUALIZADA ---
  Widget _buildInput(String label, IconData icon, TextEditingController ctrl, bool isPassword) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      style: GoogleFonts.poppins(color: Colors.black87), // Letra escura
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100], // Fundo cinza claro
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF238636), width: 2), // Verde ao focar
        ),
      ),
    );
  }
}