import 'package:dio/dio.dart';

class ApiService {
  // Chrome web -> Django on same machine
  static const String baseUrl = "http://127.0.0.1:8000/api";

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {"Content-Type": "application/json"},
    ),
  );

  String? accessToken;
  String? refreshToken;

  // ================= AUTH =================
  Future<bool> login(String username, String password) async {
    try {
      final res = await _dio.post(
        "/token/",
        data: {"username": username, "password": password},
      );

      accessToken = res.data["access"];
      refreshToken = res.data["refresh"];
      return true;
    } catch (e) {
      // ignore: avoid_print
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  // ================= PROFILE =================
  Future<Map<String, dynamic>?> me() async {
    if (accessToken == null) return null;

    final res = await _dio.get(
      "/me/",
      options: Options(
        headers: {"Authorization": "Bearer $accessToken"},
      ),
    );

    return Map<String, dynamic>.from(res.data);
  }

  // ================= BATCHES =================
  Future<List<Map<String, dynamic>>> getBatches() async {
    if (accessToken == null) return [];

    final res = await _dio.get(
      "/batches/",
      options: Options(
        headers: {"Authorization": "Bearer $accessToken"},
      ),
    );

    final list = res.data as List;
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ================= STUDENTS =================
    Future<List<Map<String, dynamic>>> getStudents(int batchId) async {
  if (accessToken == null) return [];

  final res = await _dio.get(
    "/students/",
    queryParameters: {"batch_id": batchId},
    options: Options(headers: {"Authorization": "Bearer $accessToken"}),
  );

  final list = res.data as List;
  return list.map((e) => Map<String, dynamic>.from(e)).toList();
}

  // ================= ATTENDANCE =================
  Future<Map<String, dynamic>> getAttendance(int batchId, String dateStr) async {
    if (accessToken == null) throw Exception("Not logged in");

    final res = await _dio.get(
      "/attendance/batch/$batchId/date/$dateStr/",
      options: Options(
        headers: {"Authorization": "Bearer $accessToken"},
      ),
    );

    return Map<String, dynamic>.from(res.data);
  }

  Future<int> submitAttendance(
    int batchId,
    String dateStr,
    List<Map<String, dynamic>> records,
  ) async {
    if (accessToken == null) throw Exception("Not logged in");

    final res = await _dio.post(
      "/attendance/batch/$batchId/date/$dateStr/submit/",
      data: {"records": records},
      options: Options(
        headers: {"Authorization": "Bearer $accessToken"},
      ),
    );

    return (res.data["saved"] as int?) ?? 0;
  }

  // ================= EXAMS =================
  Future<List<Map<String, dynamic>>> getExams(int batchId) async {
    if (accessToken == null) return [];

    final res = await _dio.get(
      "/exams/batch/$batchId/",
      options: Options(
        headers: {"Authorization": "Bearer $accessToken"},
      ),
    );

    final list = res.data as List;
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> getExamResults(int examId) async {
    if (accessToken == null) throw Exception("Not logged in");

    final res = await _dio.get(
      "/exams/$examId/results/",
      options: Options(
        headers: {"Authorization": "Bearer $accessToken"},
      ),
    );

    return Map<String, dynamic>.from(res.data);
  }

  Future<int> submitExamResults(
    int examId,
    List<Map<String, dynamic>> results,
  ) async {
    if (accessToken == null) throw Exception("Not logged in");

    final res = await _dio.post(
      "/exams/$examId/results/submit/",
      data: {"results": results},
      options: Options(
        headers: {"Authorization": "Bearer $accessToken"},
      ),
    );

    return (res.data["saved"] as int?) ?? 0;
  }
}
