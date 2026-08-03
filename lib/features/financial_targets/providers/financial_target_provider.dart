import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/financial_target_model.dart';

final financialTargetProvider = StateNotifierProvider<FinancialTargetNotifier, FinancialTargetState>((ref) {
  return FinancialTargetNotifier(ref.read(dioClientProvider).dio);
});

class FinancialTargetState {
  final bool isLoading;
  final String? error;
  final List<FinancialTargetModel> targets;
  final Map<String, dynamic>? stats;
  final FinancialTargetModel? currentTarget;
  final List<FinancialTargetDepositModel> deposits;
  final Map<String, dynamic>? monthlyBreakdown;

  FinancialTargetState({
    this.isLoading = false,
    this.error,
    this.targets = const [],
    this.stats,
    this.currentTarget,
    this.deposits = const [],
    this.monthlyBreakdown,
  });

  FinancialTargetState copyWith({
    bool? isLoading,
    String? error,
    List<FinancialTargetModel>? targets,
    Map<String, dynamic>? stats,
    FinancialTargetModel? currentTarget,
    List<FinancialTargetDepositModel>? deposits,
    Map<String, dynamic>? monthlyBreakdown,
    bool clearError = false,
    bool clearCurrentTarget = false,
  }) {
    return FinancialTargetState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      targets: targets ?? this.targets,
      stats: stats ?? this.stats,
      currentTarget: clearCurrentTarget ? null : (currentTarget ?? this.currentTarget),
      deposits: deposits ?? this.deposits,
      monthlyBreakdown: monthlyBreakdown ?? this.monthlyBreakdown,
    );
  }
}

class FinancialTargetNotifier extends StateNotifier<FinancialTargetState> {
  final Dio _dio;

  FinancialTargetNotifier(this._dio) : super(FinancialTargetState());

  String _getErrorMessage(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      return 'Connection refused. Check server or internet.';
    }
    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          return errors.values.first[0].toString();
        }
      } else if (data['message'] != null) {
        return data['message'].toString();
      }
    }
    return defaultMessage;
  }

  Future<void> fetchTargets() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(ApiConstants.targets);
      
      List<FinancialTargetModel> targetsList = [];
      if (response.data['targets'] != null) {
        targetsList = (response.data['targets'] as List)
            .map((item) => FinancialTargetModel.fromJson(item))
            .toList();
      }
      
      state = state.copyWith(
        isLoading: false,
        targets: targetsList,
        stats: response.data['stats'] as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to fetch targets'),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchTargetDetails(int id) async {
    state = state.copyWith(isLoading: true, clearError: true, clearCurrentTarget: true);
    try {
      final response = await _dio.get('${ApiConstants.targets}/$id');
      
      FinancialTargetModel? target;
      if (response.data['target'] != null) {
        target = FinancialTargetModel.fromJson(response.data['target']);
      }

      List<FinancialTargetDepositModel> depositList = [];
      if (response.data['deposits'] != null) {
        depositList = (response.data['deposits'] as List)
            .map((item) => FinancialTargetDepositModel.fromJson(item))
            .toList();
      }
      
      state = state.copyWith(
        isLoading: false,
        currentTarget: target,
        deposits: depositList,
        monthlyBreakdown: response.data['monthlyBreakdown'] as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to fetch target details'),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createTarget(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.post(ApiConstants.targets, data: data);
      state = state.copyWith(isLoading: false);
      await fetchTargets();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to create target'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateTarget(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.put('${ApiConstants.targets}/$id', data: data);
      state = state.copyWith(isLoading: false);
      await fetchTargets();
      if (state.currentTarget?.id == id) {
        await fetchTargetDetails(id);
      }
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to update target'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteTarget(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.delete('${ApiConstants.targets}/$id');
      final newTargets = state.targets.where((t) => t.id != id).toList();
      state = state.copyWith(isLoading: false, targets: newTargets);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to delete target'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> addDeposit(int targetId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.post('${ApiConstants.targets}/$targetId/deposit', data: data);
      state = state.copyWith(isLoading: false);
      await fetchTargets();
      await fetchTargetDetails(targetId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to add deposit'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> removeDeposit(int depositId, int targetId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.delete('${ApiConstants.targets}/deposit/$depositId');
      state = state.copyWith(isLoading: false);
      await fetchTargets();
      await fetchTargetDetails(targetId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to remove deposit'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
