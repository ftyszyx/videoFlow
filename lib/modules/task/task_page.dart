import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:videoflow/modules/task/task_control.dart';

class TaskPage extends GetView<TaskControl>{
  const TaskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Task')));
  }
}
