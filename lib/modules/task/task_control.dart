import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

import 'package:videoflow/models/db/video_task.dart';
import 'package:videoflow/models/db/account.dart';
import 'package:videoflow/entity/common.dart';
import 'package:videoflow/services/task_servcie.dart';
import 'package:videoflow/services/account_service.dart';
import 'package:videoflow/services/url_parse/url_parse_service.dart';
import 'package:videoflow/services/download_service.dart';
import 'package:videoflow/services/cover_style_service.dart';
import 'package:videoflow/models/db/cover_style.dart';

class TaskControl extends GetxController {
  // Form controllers
  final TextEditingController shareLinkController = TextEditingController();
  final TextEditingController videoTitleController = TextEditingController();
  final TextEditingController subTitleController = TextEditingController();

  final RxString _coverPath = RxString('');
  String get coverPath => _coverPath.value;

  // Accounts and selected account id
  final RxList<Account> accounts = <Account>[].obs;
  final RxString? selectedAccountId = RxString('');

  // Task list
  final RxList<VideoTask> tasks = <VideoTask>[].obs;
  final RxList<CoverStyle> coverStyles = <CoverStyle>[].obs;
  final RxString selectedCoverStyleId = ''.obs;

  TaskService get _taskService => TaskService.instance;
  AccountService get _accountService => AccountService.instance;
  UrlParseService get _urlParseService => UrlParseService.instance;
  DownloadManagerService get _downloadService =>
      DownloadManagerService.instance;

  @override
  void onInit() {
    super.onInit();
    _refreshAccounts();
    _refreshTasks();
    _refreshCoverStyles();
    // listen changes from task service (put/update/delete called within app)
    _taskService.changed.listen((_) => _refreshTasks());
  }

  @override
  void onClose() {
    shareLinkController.dispose();
    videoTitleController.dispose();
    subTitleController.dispose();
    super.onClose();
  }

  Future<void> pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _coverPath.value = result.files.single.path!;
    }
  }

  Future<void> addTask() async {
    final String shareLink = shareLinkController.text.trim();
    final String title = videoTitleController.text.trim();
    final String subtitle = subTitleController.text.trim();
    final String? userId = selectedAccountId?.value.isNotEmpty == true
        ? selectedAccountId!.value
        : null;

    if (shareLink.isEmpty || userId == null || coverPath.isEmpty) {
      Get.snackbar('提示', '请填写分享链接、选择账号并选择封面');
      return;
    }

    final task = VideoTask(
      id: const Uuid().v4(),
      shareLink: shareLink,
      userId: userId,
      coverPath: coverPath,
      videoTitle: title,
      subTitle: subtitle,
      name: title.isNotEmpty ? title : '任务',
    )..status = TaskStatus.init;
    task.coverStyleId = selectedCoverStyleId.value.isNotEmpty
        ? selectedCoverStyleId.value
        : null;

    await _taskService.put(task);
    _clearForm();
  }

  Future<void> startTask(VideoTask task) async {
    // 若可下载则直接进入下载队列，否则进入解析
    if (task.canDownload()) {
      task.status = TaskStatus.waitForDownload;
      await _taskService.update(task);
      _downloadService.addDownloadTask(task);
    } else {
      task.status = TaskStatus.waitForParse;
      await _taskService.update(task);
      _urlParseService.addParseTask(task);
    }
  }

  Future<void> pauseTask(VideoTask task) async {
    _urlParseService.stopParse(task.id);
    _downloadService.stopDownload(task.id);
    task.pause();
    await _taskService.update(task);
  }

  Future<void> deleteTask(VideoTask task) async {
    // ensure stop
    await pauseTask(task);
    await _taskService.delete(task.id);
  }

  void _refreshAccounts() {
    accounts.assignAll(_accountService.getAll());
    if (accounts.isNotEmpty && (selectedAccountId?.value.isEmpty ?? true)) {
      selectedAccountId?.value = accounts.first.id ?? '';
    }
  }

  void _refreshTasks() {
    tasks.assignAll(_taskService.getAll());
  }

  void _refreshCoverStyles() {
    coverStyles.assignAll(CoverStyleService.instance.getAll());
    if (coverStyles.isNotEmpty && selectedCoverStyleId.value.isEmpty) {
      selectedCoverStyleId.value = coverStyles.first.id;
    }
  }

  void _clearForm() {
    shareLinkController.clear();
    videoTitleController.clear();
    subTitleController.clear();
    _coverPath.value = '';
  }
}
