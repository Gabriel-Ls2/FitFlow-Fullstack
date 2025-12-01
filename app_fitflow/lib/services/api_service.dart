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
      final response = await _dio.post('/auth/login/', data: {
        'username': username,
        'password': password,
      });

      final token = response.data['key'];
      await _storage.write(key: 'auth_token', value: token);
      return null; 
    } on DioException catch (e) {
      if (e.response != null) return 'Erro: ${e.response?.data}';
      return 'Erro de conexão com $_baseUrl';
    }
  }

  // CADASTRAR USUÁRIO
  Future<String?> register(String username, String email, String password, String passConfirm) async {
    try {
      final response = await _dio.post('/auth/registration/', data: {
        'username': username,
        'email': email,
        'password1': password,
        'password2': passConfirm,
      });

      final token = response.data['key'];
      await _storage.write(key: 'auth_token', value: token);
      return null;
      
    } on DioException catch (e) {
      if (e.response != null) return 'Erro: ${e.response?.data}';
      return 'Erro ao tentar cadastrar.';
    }
  }

  // RECUPERAR SENHA
  Future<String?> solicitarCodigoSenha(String email) async {
    try {
      await _dio.post('/password/request-code/', data: {'email': email});
      return null;
    } on DioException catch (e) {
      return 'Erro: ${e.response?.data}';
    }
  }

  Future<String?> trocarSenhaComCodigo(String email, String code, String newPassword) async {
    try {
      await _dio.post('/password/verify-change/', data: {
        'email': email,
        'code': code,
        'new_password': newPassword
      });
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
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
      final response = await _dio.get('/dashboard/', 
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  // REGISTRAR ÁGUA
  Future<bool> registrarAgua(int ml) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      await _dio.post('/agua/', 
        data: {'quantidade_ml': ml},
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // REGISTRAR EXERCÍCIO
  Future<bool> registrarExercicio(String tipo, int duracao, String intensidade) async {
    return _postData('/exercicios/', {
      'tipo_atividade': tipo,
      'duracao_minutos': duracao,
      'intensidade': intensidade
    });
  }

  // REGISTRAR SONO
  Future<bool> registrarSono(double horas) async {
    return _postData('/sono/', {'horas_sono': horas});
  }

  // REGISTRAR REFEIÇÃO
  Future<bool> registrarRefeicao(String tipo, String descricao) async {
    return _postData('/refeicoes/', {'tipo_refeicao': tipo, 'descricao': descricao});
  }

  // Função auxiliar genérica
  Future<bool> _postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      await _dio.post(endpoint, 
        data: data,
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // DADOS DO GRÁFICO (PROGRESSO)
  Future<Map<String, dynamic>?> getProgressData() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get('/progress/', 
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  // METAS
  Future<Map<String, dynamic>?> getMetas() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get('/metas/', 
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      
      if (response.data is List && response.data.isNotEmpty) {
        return response.data[0];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
        await _dio.patch('/metas/$id/', data: dados, options: Options(headers: {'Authorization': 'Token $token'}));
      } else {
        await _dio.post('/metas/', data: dados, options: Options(headers: {'Authorization': 'Token $token'}));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // PERFIL
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get('/auth/user/', 
        options: Options(headers: {'Authorization': 'Token $token'})
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}