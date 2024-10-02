import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:http/http.dart' as http;

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

class UpdateTodo extends StatefulWidget {
  const UpdateTodo({required this.todo, super.key});

  final TodoModels todo;

  @override
  State<UpdateTodo> createState() => _UpdateTodoState();
}

class _UpdateTodoState extends State<UpdateTodo> {
  late TextEditingController _controller;

  final apiUrl = '${getBackendUrl()}/api/v1/todos';
  final _headers = {'Content-Type': 'application/json'};

  Future<void> _updateTodo() async {
    final updatedTodo = TodoModels(
      id: widget.todo.id,
      title: _controller.text,
      completed: widget.todo.completed,
    );

    try {
      final res = await http.put(
        Uri.parse('$apiUrl/${updatedTodo.id}'),
        headers: _headers,
        body: json.encode(updatedTodo.toMap()),
      );
      if (res.statusCode == 200) {
        Navigator.pop(context, updatedTodo);
      } else {
        debugPrint(res.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Todo",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              maxLines: null,
              controller: _controller,
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _updateTodo();
              });
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: const Size(100, 50),
            ),
          ),
        ],
      ),
    );
  }
}
