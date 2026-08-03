import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as fp;
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/stata_model.dart';

final stataProvider = StateNotifierProvider<StataNotifier, StataState>((ref) {
  return StataNotifier(ref.read(dioClientProvider).dio);
});

class StataState {
  final bool isLoading;
  final String? error;
  final StataDatasetModel? dataset;
  final StataOutputModel? output;

  StataState({
    this.isLoading = false,
    this.error,
    this.dataset,
    this.output,
  });

  StataState copyWith({
    bool? isLoading,
    String? error,
    StataDatasetModel? dataset,
    StataOutputModel? output,
    bool clearError = false,
    bool clearDataset = false,
    bool clearOutput = false,
  }) {
    return StataState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      dataset: clearDataset ? null : (dataset ?? this.dataset),
      output: clearOutput ? null : (output ?? this.output),
    );
  }
}

class StataNotifier extends StateNotifier<StataState> {
  final Dio _dio;

  StataNotifier(this._dio) : super(StataState());

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

  Future<void> fetchState() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(ApiConstants.stata);
      
      StataDatasetModel? dataset;
      if (response.data['dataset'] != null) {
        dataset = StataDatasetModel.fromJson(response.data['dataset']);
      }

      StataOutputModel? output;
      if (response.data['output'] != null) {
        output = StataOutputModel.fromJson(response.data['output']);
      }

      state = state.copyWith(
        isLoading: false,
        dataset: dataset,
        output: output,
        clearDataset: dataset == null,
        clearOutput: output == null,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to fetch Stata data'),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> importDataset() async {
    try {
      fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['dta'],
      );

      if (result != null && result.files.single.path != null) {
        state = state.copyWith(isLoading: true, clearError: true);
        
        final file = result.files.single;
        final formData = FormData.fromMap({
          'stata_file': await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          ),
        });

        final response = await _dio.post(ApiConstants.stataImport, data: formData);
        
        if (response.data['dataset'] != null) {
          state = state.copyWith(
            isLoading: false,
            dataset: StataDatasetModel.fromJson(response.data['dataset']),
            clearOutput: true, // clear previous output
          );
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to upload Stata file'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> runCommand(String prompt) async {
    if (prompt.trim().isEmpty) return false;
    
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.post(
        ApiConstants.stataCommand,
        data: {'stata_prompt': prompt},
      );
      
      if (response.data['output'] != null) {
        state = state.copyWith(
          isLoading: false,
          output: StataOutputModel.fromJson(response.data['output']),
        );
        return true;
      }
      
      state = state.copyWith(isLoading: false);
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to run command'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> clearDataset() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dio.delete(ApiConstants.stataDataset);
      state = state.copyWith(
        isLoading: false,
        clearDataset: true,
        clearOutput: true,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, 'Failed to clear dataset'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
