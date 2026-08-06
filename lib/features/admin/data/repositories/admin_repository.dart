import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AdminRepository {
  final DioClient _dioClient;

  AdminRepository(this._dioClient);

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dioClient.dio.get('/admin/users');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil data user');
    }
  }

  Future<UserModel> getUserDetails(int id) async {
    try {
      final response = await _dioClient.dio.get('/admin/users/$id');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil detail user');
    }
  }

  Future<UserModel> updateRole(int id, String role) async {
    try {
      final response = await _dioClient.dio.put(
        '/admin/users/$id/role',
        data: {'role': role},
      );
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengubah role user');
    }
  }

  Future<UserModel> toggleStatus(int id) async {
    try {
      final response = await _dioClient.dio.put('/admin/users/$id/status');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengubah status user');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dioClient.dio.delete('/admin/users/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus user');
    }
  }
}
