import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/tax_model.dart';

final taxProvider = StateNotifierProvider<TaxNotifier, TaxState>((ref) {
  return TaxNotifier(ref.read(dioClientProvider).dio);
});

class TaxState {
  final bool isLoading;
  final String? error;
  final List<TaxAnalysisModel> history;
  final List<String> statuses;
  final Map<String, dynamic> ptkpTable;
  final List<dynamic> taxBrackets;

  TaxState({
    this.isLoading = false,
    this.error,
    this.history = const [],
    this.statuses = const [],
    this.ptkpTable = const {},
    this.taxBrackets = const [],
  });

  TaxState copyWith({
    bool? isLoading,
    String? error,
    List<TaxAnalysisModel>? history,
    List<String>? statuses,
    Map<String, dynamic>? ptkpTable,
    List<dynamic>? taxBrackets,
    bool clearError = false,
  }) {
    return TaxState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      history: history ?? this.history,
      statuses: statuses ?? this.statuses,
      ptkpTable: ptkpTable ?? this.ptkpTable,
      taxBrackets: taxBrackets ?? this.taxBrackets,
    );
  }
}

class TaxNotifier extends StateNotifier<TaxState> {
  final Dio _dio;

  TaxNotifier(this._dio) : super(TaxState());

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

  Future<void> fetchTaxData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(ApiConstants.tax);
      
      List<TaxAnalysisModel> historyList = [];
      if (response.data['history'] != null) {
        historyList = (response.data['history'] as List)
            .map((item) => TaxAnalysisModel.fromJson(item))
            .toList();
      }
      
      List<String> statuses = [];
      if (response.data['statuses'] != null) {
        statuses = List<String>.from(response.data['statuses']);
      }

      state = state.copyWith(
        isLoading: false,
        history: historyList,
        statuses: statuses,
        ptkpTable: response.data['ptkpTable'] as Map<String, dynamic>? ?? {},
        taxBrackets: response.data['taxBrackets'] as List<dynamic>? ?? [],
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to fetch tax data'),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> calculateTax(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.post(ApiConstants.taxCalculate, data: data);
      state = state.copyWith(isLoading: false);
      await fetchTaxData();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to calculate tax'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteTaxHistory(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.delete('${ApiConstants.tax}/$id');
      final newHistory = state.history.where((t) => t.id != id).toList();
      state = state.copyWith(isLoading: false, history: newHistory);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to delete tax history'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
