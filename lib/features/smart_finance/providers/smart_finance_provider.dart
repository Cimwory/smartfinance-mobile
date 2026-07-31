import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/smart_finance_model.dart';

final smartFinanceProvider = StateNotifierProvider<SmartFinanceNotifier, SmartFinanceState>((ref) {
  return SmartFinanceNotifier(ref.read(dioClientProvider).dio);
});

class SmartFinanceState {
  final bool isLoading;
  final String? error;
  final List<SmartFinanceHistory> history;
  final SmartFinanceResult? lastResult;

  SmartFinanceState({
    this.isLoading = false,
    this.error,
    this.history = const [],
    this.lastResult,
  });

  SmartFinanceState copyWith({
    bool? isLoading,
    String? error,
    List<SmartFinanceHistory>? history,
    SmartFinanceResult? lastResult,
    bool clearError = false,
    bool clearLastResult = false,
  }) {
    return SmartFinanceState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      history: history ?? this.history,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
    );
  }
}

class SmartFinanceNotifier extends StateNotifier<SmartFinanceState> {
  final Dio _dio;

  SmartFinanceNotifier(this._dio) : super(SmartFinanceState());

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

  Future<void> fetchHistory() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(ApiConstants.smartFinance);
      
      List<SmartFinanceHistory> historyList = [];
      if (response.data['history'] != null) {
        historyList = (response.data['history'] as List)
            .map((item) => SmartFinanceHistory.fromJson(item))
            .toList();
      }
      
      SmartFinanceResult? result;
      if (response.data['result'] != null) {
        result = SmartFinanceResult.fromJson(response.data['result']);
      }
      
      state = state.copyWith(
        isLoading: false,
        history: historyList,
        lastResult: result,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to fetch history'),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> analyze(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.post(ApiConstants.smartFinanceAnalyze, data: data);
      
      List<SmartFinanceHistory> historyList = [];
      if (response.data['history'] != null) {
        historyList = (response.data['history'] as List)
            .map((item) => SmartFinanceHistory.fromJson(item))
            .toList();
      }
      
      SmartFinanceResult? result;
      if (response.data['result'] != null) {
        result = SmartFinanceResult.fromJson(response.data['result']);
      }

      state = state.copyWith(
        isLoading: false,
        history: historyList,
        lastResult: result,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to analyze data'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteHistory(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.delete('${ApiConstants.smartFinance}/$id');
      // Remove from local state
      final newHistory = state.history.where((h) => h.id != id).toList();
      state = state.copyWith(isLoading: false, history: newHistory);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to delete history'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
