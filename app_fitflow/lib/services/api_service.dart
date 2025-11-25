import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // Para checar se é Web

class ApiService {
  static final String _baseUrl = kIsWeb 
      ? 'http://127.0.0.1:8000/api' 
      : 'https://fitflow-fullstack.onrender.com/api';
  
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  // LOGIN
  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post('https://fitflow-fullstack.onrender.com/api/auth/login/', data: {
        'username': username,
        'password': password,
      });

      // Salva o token
      final token = response.data['key'];
      await _storage.write(key: 'auth_token', value: token);
      return null; // Sucesso
    } on DioException catch (e) {
      if (e.response != null) {
        return 'Erro: ${e.response?.data}';
      }
      return 'Erro de conexão com o Django em $_baseUrl';
    }
  }

  // CADASTRAR USUÁRIO
  Future<String?> register(String username, String email, String password, String passConfirm) async {
    try {
      final response = await _dio.post('https://fitflow-fullstack.onrender.com/api/auth/registration/', data: {
        'username': username,
        'email': email,
        'password1': password,
        'password2': passConfirm, // O Django espera confirmação
      });

      // O Django já retorna o token logo após o cadastro, então já logamos o usuário direto!
      final token = response.data['key'];
      await _storage.write(key: 'auth_token', value: token);
      return null; // Sucesso (null = sem erro)
      
    } on DioException catch (e) {
      if (e.response != null) {
        // Tenta pegar a mensagem de erro específica do Django
        return 'Erro: ${e.response?.data}';
      }
      return 'Erro ao tentar cadastrar.';
    }
  }

  // RECUPERAR SENHA
  Future<String?> solicitarCodigoSenha(String email) async {
    try {
      await _dio.post('https://fitflow-fullstack.onrender.com/api/password/request-code/', data: {'email': email});
      return null; // Sucesso
    } on DioException catch (e) {
      return 'Erro: ${e.response?.data}';
    }
  }

  Future<String?> trocarSenhaComCodigo(String email, String code, String newPassword) async {
    try {
      await _dio.post('https://fitflow-fullstack.onrender.com/api/password/verify-change/', data: {
        'email': email,
        'code': code,
        'new_password': newPassword
      });
      return null; // Sucesso
    } on DioException catch (e) {
      if (e.response != null) {
        // Tenta pegar mensagem de erro do backend
        final data = e.response?.data;
        if (data is Map && data.containsKey('error')) return data['error'];
        return 'Erro: $data';
      }
      return 'Erro de conexão.';
    }
  }

  Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      // Envia o Token no cabeçalho para o Django saber quem é
      final response = await _dio.get('https://fitflow-fullstack.onrender.com/api/dashboard/', 
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return response.data;
    } catch (e) {
      print("Erro ao buscar dashboard: $e");
      return null;
    }
  }

  // REGISTRAR ÁGUA
  Future<bool> registrarAgua(int ml) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      await _dio.post('https://fitflow-fullstack.onrender.com/api/agua/', 
        data: {'quantidade_ml': ml},
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return true; // Deu certo
    } catch (e) {
      print("Erro ao registrar água: $e");
      return false; // Deu erro
    }
  }

  // REGISTRAR EXERCÍCIO
  Future<bool> registrarExercicio(String tipo, int duracao, String intensidade) async {
    return _postData('https://fitflow-fullstack.onrender.com/api/exercicios/', {
      'tipo_atividade': tipo,
      'duracao_minutos': duracao,
      'intensidade': intensidade
    });
  }

  // REGISTRAR SONO
  Future<bool> registrarSono(double horas) async {
    return _postData('https://fitflow-fullstack.onrender.com/api/sono/', {'horas_sono': horas});
  }

  // REGISTRAR REFEIÇÃO
  Future<bool> registrarRefeicao(String tipo, String descricao) async {
    return _postData('https://fitflow-fullstack.onrender.com/api/refeicoes/', {'tipo_refeicao': tipo, 'descricao': descricao});
  }

  // Função auxiliar para evitar repetir código
  Future<bool> _postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      await _dio.post(endpoint, 
        data: data,
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return true;
    } catch (e) {
      print("Erro em $endpoint: $e");
      return false;
    }
  }

  // DADOS DO GRÁFICO (PROGRESSO)
  Future<Map<String, dynamic>?> getProgressData() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get('https://fitflow-fullstack.onrender.com/api/progress/', 
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return response.data;
    } catch (e) {
      print("Erro ao buscar progresso: $e");
      return null;
    }
  }

  // Busca as metas do usuário. Se não existir, retorna null.
  Future<Map<String, dynamic>?> getMetas() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get('https://fitflow-fullstack.onrender.com/api/metas/', 
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      
      // O Django retorna uma lista. Se tiver algo, pegamos o primeiro item.
      if (response.data is List && response.data.isNotEmpty) {
        return response.data[0];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Cria ou Atualiza as metas
  // Se já tiver ID, usa PATCH. Se não, usa POST.
  Future<bool> salvarMetas(int? id, int agua, double sono, int exercicio, int refeicoes) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final dados = {
        'meta_agua_ml': agua,
        'meta_sono_horas': sono,
        'meta_exercicio_min': exercicio,
        'meta_refeicoes_qtd': refeicoes
      };

      if (id != null) {
        // Atualiza existente
        await _dio.patch('https://fitflow-fullstack.onrender.com/api/metas/$id/', data: dados, options: Options(headers: {'Authorization': 'Token $token'}));
      } else {
        // Cria nova
        await _dio.post('https://fitflow-fullstack.onrender.com/api/metas/', data: dados, options: Options(headers: {'Authorization': 'Token $token'}));
      }
      return true;
    } catch (e) {
      print("Erro ao salvar metas: $e");
      return false;
    }
  }

  // --- PERFIL ---

  // Busca os dados do usuário logado (Nome, Email)
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      // Esse endpoint já vem pronto no dj-rest-auth
      final response = await _dio.get('https://fitflow-fullstack.onrender.com/api/auth/user/', 
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return response.data;
    } catch (e) {
      print("Erro ao buscar perfil: $e");
      return null;
    }
  }
  
  // Função de Logout (Limpa o token)
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}