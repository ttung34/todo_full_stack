import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/todo_model.dart';

String getBackendUrl() {
  if (kIsWeb) {
    return 'http://localhost:8080'; // hoặc sử dụng IP LAN nếu cần
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080'; // cho emulator
    // return 'http://192.168.1.x:8080'; // cho thiết bị thật khi truy cập qua LAN
  } else {
    return 'http://localhost:8080';
  }
}

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final _todos = <TodoModels>[];
  final _controller = TextEditingController();
  final apiUrl = '${getBackendUrl()}/api/v1/todos';
  final _headers = {'Content-Type': 'application/json'};

  Future<void> _fetchTodos() async {
    final res = await http.get(Uri.parse(apiUrl));

    if (res.statusCode == 200) {
      final List<dynamic> todoList = json.decode(res.body);

      setState(() {
        _todos.clear();
        _todos.addAll(todoList.map((e) => TodoModels.fromMap(e)).toList());
      });
    }
  }

  // Thêm một todo mới sử dụng phương thức post
  Future<void> _addTodo() async {
    if (_controller.text.isEmpty) return;

    final newItem = TodoModels(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _controller.text,
        completed: false);

    final res = await http.post(
      Uri.parse(apiUrl),
      headers: _headers,
      body: json.encode(newItem.toMap()),
    );

    if (res.statusCode == 200) {
      _controller.clear();
      _fetchTodos();
    }
  }

  // lamf mowis danh sách bằng cách lấy danh sách todo mới
  // Cập nhập trạng thái completed của todo sử dụng phương thức Put
  Future<void> _updateTodo(TodoModels item) async {
    item.completed = !item.completed;

    try {
      final res = await http.put(
        Uri.parse('$apiUrl/${item.id}'),
        headers: _headers,
        body: json.encode(item.toMap()),
      );
      if (res.statusCode == 200) {
        _fetchTodos();
      } else {
        debugPrint(res.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _deleteTodo(int id) async {
    final res = await http.delete(
      Uri.parse('$apiUrl/$id'),
    );
    if (res.statusCode == 200) {
      _fetchTodos();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchTodos();
    // Khi khởi tạo widget lần đầu thì lấy danh sách todo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Todo App"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLines: null,
                      controller: _controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Tiêu đề công việc không được để trống";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          color: Color(0xFF262626)),
                      decoration: InputDecoration(
                          hintText: "Công việc ",
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.2),
                          ),
                          fillColor: const Color(0xFFFAFAFA),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: const Color(0xFF000000).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: const Color(0xFF000000).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: const Color(0xFF000000).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Color(0xFF3797EF),
                                width: 1,
                              ))),
                    ),
                  ),
                  IconButton(
                    onPressed: _addTodo,
                    icon: const Icon(Icons.add),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    final item = _todos.elementAt(index);
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.blue,
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        child: ListTile(
                          title: Text(item.title),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: item.completed,
                                onChanged: (value) {
                                  _updateTodo(item);
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  _deleteTodo(item.id);
                                },
                                icon: const Icon(Icons.delete),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
