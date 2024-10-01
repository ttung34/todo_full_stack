import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/todo_models.dart';

class TodoRouter {
  // ignore: unused_field
  final _todos = <TodoModels>[];

  // Taọ và trả về mộtt router cho  các hoạt động

  Router get router {
    final router = Router();

    router.get('/todos', _getTodosHandler);

    //enpoint thêm công việc

    router.post('/todos', _addTodosHandler);

    //endpoint xoá 1 công việc
    router.delete('/todos/<id>', _deleteTodoHandler);

    // endpoint cập nhật 1 công việc
    router.put('/todos/<id>', _updateTodoHandler);

    return router;
  }

  //header mặc định cho dữ liệu trả về dưới dạng json

  static final _headers = {'Content-Type': 'application/json'};

  Future<Response> _getTodosHandler(Request req) async {
    try {
      final body = json.encode(_todos.map((todo) => todo.toMap()).toList());
      return Response.ok(
        body,
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  // xử lý yêu cầu thêm công việc vào danh sách
  Future<Response> _addTodosHandler(Request req) async {
    try {
      final payload = await req.readAsString();
      final data = json.decode(payload);
      final todo = TodoModels.fromMap(data);
      _todos.add(todo);
      return Response.ok(
        todo.toJson(),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  // xử lý yêu cầu xoá 1 công việc
  Future<Response> _deleteTodoHandler(Request req, String id) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == int.parse(id));
      if (index == -1) {
        return Response.notFound("Không tìm thấy todo có id = $id");
      }

      final removedTodo = _todos.removeAt(index);
      return Response.ok(
        removedTodo.toJson(),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers,
      );
    }
  }

  Future<Response> _updateTodoHandler(Request req, String id) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == int.parse(id));
      if (index == -1) {
        return Response.notFound("Không tìm thấy todo có id = $id");
      }

      final payload = await req.readAsString();
      final map = json.decode(payload);
      final updatedTodo = TodoModels.fromMap(map);

      _todos[index] = updatedTodo;
      return Response.ok(
        updatedTodo.toJson(),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers,
      );
    }
  }
}
