import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart'; 
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _api = ApiService();
  bool _isLoading = false;

  void _fazerLogin() async {
    setState(() => _isLoading = true);
    
    final erro = await _api.login(_userController.text, _passController.text);

    setState(() => _isLoading = false);

    if (erro == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
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
      backgroundColor: Colors.white, // Fundo branco
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
              Text('FitFlow', 
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1A1F36))
              ),
              const SizedBox(height: 10),
              Text('Bem-vindo de volta', 
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])
              ),
              const SizedBox(height: 40),
              
              // --- CAMPO DE USUÁRIO CORRIGIDO ---
              TextField(
                controller: _userController,
                style: GoogleFonts.poppins(color: Colors.black87), // Força letra escura
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                  filled: true, // Ativa o fundo colorido
                  fillColor: Colors.grey[100], // Cor de fundo cinza claro
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // Sem borda preta dura
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300), // Borda suave
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF238636), width: 2), // Verde ao focar
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // --- CAMPO DE SENHA CORRIGIDO ---
              TextField(
                controller: _passController,
                obscureText: true,
                style: GoogleFonts.poppins(color: Colors.black87), // Força letra escura
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[100],
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
                    borderSide: const BorderSide(color: Color(0xFF238636), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Link Esqueceu a Senha 
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())
                    );
                  },
                  child: Text("Esqueceu a senha?", 
                    style: GoogleFonts.poppins(color: const Color(0xFF238636), fontWeight: FontWeight.w600, fontSize: 14)
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Botão Entrar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1F36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('ENTRAR', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),

              // Link para Cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Não tem uma conta? ", style: GoogleFonts.poppins(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text("Cadastre-se", 
                      style: GoogleFonts.poppins(color: const Color(0xFF238636), fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}