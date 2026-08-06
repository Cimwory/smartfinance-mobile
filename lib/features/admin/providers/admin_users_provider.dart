import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/user_model.dart';
import '../data/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AdminRepository(dioClient);
});

final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return AdminUsersNotifier(repository);
});

class AdminUsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final AdminRepository _repository;

  AdminUsersNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _repository.getUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateRole(int id, String role) async {
    try {
      final updatedUser = await _repository.updateRole(id, role);
      
      // Update state locally
      if (state is AsyncData) {
        final currentUsers = state.value!;
        final updatedUsers = currentUsers.map((user) {
          return user.id == id ? updatedUser : user;
        }).toList();
        state = AsyncValue.data(updatedUsers);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleStatus(int id) async {
    try {
      final updatedUser = await _repository.toggleStatus(id);
      
      // Update state locally
      if (state is AsyncData) {
        final currentUsers = state.value!;
        final updatedUsers = currentUsers.map((user) {
          return user.id == id ? updatedUser : user;
        }).toList();
        state = AsyncValue.data(updatedUsers);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _repository.deleteUser(id);
      
      // Update state locally
      if (state is AsyncData) {
        final currentUsers = state.value!;
        final updatedUsers = currentUsers.where((user) => user.id != id).toList();
        state = AsyncValue.data(updatedUsers);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
