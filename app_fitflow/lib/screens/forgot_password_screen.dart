import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPassController = TextEditingController();
  
  final _api = ApiService();
  bool _isLoading = false;
  bool _codigoEnviado = false; // Controla qual etapa da tela mostrar

  // Etapa 1: Pedir Código
  void _solicitarCodigo() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    final erro = await _api.solicitarCodigoSenha(_emailController.text);
    
    setState(() => _isLoading = false);

    if (erro == null) {
      setState(() => _codigoEnviado = true); // Muda a tela
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Código enviado! Verifique o console."), backgroundColor: Colors.green));
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro), backgroundColor: Colors.red));
    }
  }

  // Etapa 2: Trocar Senha
  void _trocarSenha() async {
    if (_codeController.text.isEmpty || _newPassController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final erro = await _api.trocarSenhaComCodigo(
      _emailController.text, 
      _codeController.text, 
      _newPassController.text
    );

    setState(() => _isLoading = false);

    if (erro == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text("Sucesso!"),
            content: const Text("Sua senha foi alterada."),
            actions: [TextButton(onPressed: () {
               Navigator.pop(c); // Fecha Dialog
               Navigator.pop(context); // Fecha Tela e volta pro Login
            }, child: const Text("OK"))],
          ),
        );
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_codigoEnviado ? 'Verifique seu e-mail' : 'Esqueceu a senha?', 
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A1F36))
            ),
            const SizedBox(height: 10),
            Text(_codigoEnviado ? 'Digite o código de 6 dígitos e sua nova senha.' : 'Digite seu e-mail para receber o código.', 
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14)
            ),
            const SizedBox(height: 40),

            // CAMPO EMAIL (Sempre visível, mas desabilitado na etapa 2)
            _buildInput("E-mail", Icons.email, _emailController, false, enabled: !_codigoEnviado),
            
            // CAMPOS DA ETAPA 2 (Só aparecem depois de enviar o código)
            if (_codigoEnviado) ...[
              const SizedBox(height: 16),
              _buildInput("Código (6 dígitos)", Icons.key, _codeController, false),
              const SizedBox(height: 16),
              _buildInput("Nova Senha", Icons.lock, _newPassController, true),
            ],

            const SizedBox(height: 24),

            // BOTÃO MUDAR AÇÃO
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_codigoEnviado ? _trocarSenha : _solicitarCodigo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1F36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_codigoEnviado ? 'ALTERAR SENHA' : 'ENVIAR CÓDIGO', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl, bool isPass, {bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      obscureText: isPass,
      style: GoogleFonts.poppins(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[300],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}