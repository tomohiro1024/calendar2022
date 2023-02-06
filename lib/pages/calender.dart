import 'dart:io';

import 'package:calendar202211/model/schedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({Key? key}) : super(key: key);

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  final _formKey = GlobalKey<FormState>();
  DateTime now = DateTime.now();
  DateTime firstDay = DateTime(2023, 1, 1);
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  late DateTime selectedDate;
  List<String> weekName = ['月', '火', '水', '木', '金', '土', '日'];
  List<String> holiday = ['土', '日'];
  TextEditingController titleController = TextEditingController();
  late PageController controller;
  int monthDuration = 0;
  // firstDayから何ヶ月経っているかという状態を管理
  late int initialIndex;

  // オプション
  late List<int> yearOption;
  List<int> monthOption = List.generate(12, (index) => index + 1);
  List<int>? dayOption;
  void buildDayOption(DateTime selectedDate) {
    List<int> _list = [];
    for (int i = 1;
        i <=
            DateTime(selectedDate.year, selectedDate.month + 1, 1)
                .subtract(Duration(days: 1))
                .day;
        i++) {
      _list.add(i);
    }
    dayOption = _list;
  }

  List<int> hourOption = List.generate(24, (index) => index);
  List<int> minuteOption = List.generate(60, (index) => index);

  // ピッカーの開始か終了かの判断
  bool isSettingStartTime = true;

  Map<DateTime, List<Schedule>> scheduleMap = {
    DateTime(2023, 2, 1): [
      Schedule(
        title: 'リリース',
        startAt: DateTime(2023, 2, 1, 1),
        endAt: DateTime(2023, 2, 1, 2),
      ),
    ],
  };

  Map<DateTime, List<Schedule>> holidayMap = {
    DateTime(2023, 1, 1): [
      Schedule(
        title: '元旦',
        startAt: DateTime(2023, 1, 1, 1),
        endAt: DateTime(2023, 1, 1, 2),
      ),
    ],
    DateTime(2023, 1, 9): [
      Schedule(
        title: '成人の日',
        startAt: DateTime(2023, 1, 9, 10),
        endAt: DateTime(2023, 1, 9, 11),
      ),
    ],
    DateTime(2023, 2, 11): [
      Schedule(
        title: '建国記念日',
        startAt: DateTime(2023, 2, 11, 10),
        endAt: DateTime(2023, 2, 11, 11),
      ),
    ],
    DateTime(2023, 2, 23): [
      Schedule(
        title: '天皇誕生日',
        startAt: DateTime(2023, 2, 23, 10),
        endAt: DateTime(2023, 2, 23, 11),
      ),
    ],
    DateTime(2023, 3, 21): [
      Schedule(
        title: '秋分の日',
        startAt: DateTime(2023, 3, 21, 10),
        endAt: DateTime(2023, 3, 21, 11),
      ),
    ],
    DateTime(2023, 4, 29): [
      Schedule(
        title: '昭和の日',
        startAt: DateTime(2023, 4, 29, 10),
        endAt: DateTime(2023, 4, 29, 11),
      ),
    ],
    DateTime(2023, 5, 3): [
      Schedule(
        title: '憲法記念日',
        startAt: DateTime(2023, 5, 3, 10),
        endAt: DateTime(2023, 5, 3, 11),
      ),
    ],
    DateTime(2023, 5, 4): [
      Schedule(
        title: 'みどりの日',
        startAt: DateTime(2023, 5, 4, 10),
        endAt: DateTime(2023, 5, 4, 11),
      ),
    ],
    DateTime(2023, 5, 5): [
      Schedule(
        title: 'こどもの日',
        startAt: DateTime(2023, 5, 5, 10),
        endAt: DateTime(2023, 5, 5, 11),
      ),
    ],
    DateTime(2023, 7, 17): [
      Schedule(
        title: '海の日',
        startAt: DateTime(2023, 7, 17, 10),
        endAt: DateTime(2023, 7, 17, 11),
      ),
    ],
    DateTime(2023, 8, 11): [
      Schedule(
        title: '山の日',
        startAt: DateTime(2023, 8, 11, 10),
        endAt: DateTime(2023, 8, 11, 11),
      ),
    ],
    DateTime(2023, 9, 18): [
      Schedule(
        title: '敬老の日',
        startAt: DateTime(2023, 9, 18, 10),
        endAt: DateTime(2023, 9, 18, 11),
      ),
    ],
    DateTime(2023, 9, 23): [
      Schedule(
        title: '秋分の日',
        startAt: DateTime(2023, 9, 23, 10),
        endAt: DateTime(2023, 9, 23, 11),
      ),
    ],
    DateTime(2023, 10, 9): [
      Schedule(
        title: 'スポーツの日',
        startAt: DateTime(2023, 10, 9, 10),
        endAt: DateTime(2023, 10, 9, 11),
      ),
    ],
    DateTime(2023, 11, 3): [
      Schedule(
        title: '文化の日',
        startAt: DateTime(2023, 11, 3, 10),
        endAt: DateTime(2023, 11, 3, 11),
      ),
    ],
    DateTime(2023, 11, 23): [
      Schedule(
        title: '勤労感謝の日',
        startAt: DateTime(2023, 11, 23, 10),
        endAt: DateTime(2023, 11, 23, 11),
      ),
    ],
  };

  void selectDate(DateTime casheDate) {
    selectedDate = casheDate;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    yearOption = [for (int i = 0; i < 10; i++) now.year + i];
    selectedDate = now;
    initialIndex =
        (now.year - firstDay.year) * 12 + (now.month - firstDay.month);
    controller = PageController(initialPage: initialIndex);
    controller.addListener(() {
      monthDuration = (controller.page! - initialIndex).round();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ドロワーメニュー
      drawer: Drawer(
        backgroundColor: Colors.orangeAccent.shade100,
        child: ListView(
          children: [
            Container(
              child: ListTile(
                title: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset('images/icon.png'),
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      'メニュー',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 7),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.orange),
                  bottom: BorderSide(color: Colors.orange),
                ),
              ),
              child: ListTile(
                title: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        addSchedule();
                      },
                      splashRadius: 15,
                      splashColor: Colors.green,
                      icon: Icon(
                        Icons.add,
                        color: Colors.green,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        'スケジュールの追加',
                        style: TextStyle(fontSize: 20, color: Colors.green),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        addSchedule();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.orange),
                ),
              ),
              child: ListTile(
                title: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(
                                      '確認',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: [
                                          Text(
                                            'Androidは少々お待ちください',
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                          '閉じる',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).popUntil(
                                              (route) => route.isFirst);
                                        },
                                      ),
                                    ],
                                  ));
                        } else {
                          var uri = Uri.parse(
                              'https://apps.apple.com/jp/app/id1668973474');
                          await launchUrl(uri);
                          Navigator.pop(context);
                        }
                      },
                      splashRadius: 15,
                      splashColor: Colors.pinkAccent,
                      icon: Icon(
                        Icons.edit,
                        color: Colors.cyan,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        'レビューする',
                        style: TextStyle(fontSize: 20, color: Colors.cyan),
                      ),
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(
                                      '確認',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: [
                                          Text(
                                            'Androidは少々お待ちください',
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                          '閉じる',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).popUntil(
                                              (route) => route.isFirst);
                                        },
                                      ),
                                    ],
                                  ));
                        } else {
                          var uri = Uri.parse(
                              'https://apps.apple.com/jp/app/id1668973474');
                          await launchUrl(uri);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.orange),
                ),
              ),
              child: ListTile(
                title: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      splashRadius: 15,
                      splashColor: Colors.pinkAccent,
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        '閉じる',
                        style:
                            TextStyle(fontSize: 20, color: Colors.pinkAccent),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: ListTile(
                title: Text(
                  'バージョン: 1.1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: NewGradientAppBar(
        iconTheme: IconThemeData(color: Colors.black),
        gradient: LinearGradient(
          colors: [Colors.orangeAccent, Colors.deepOrange],
        ),
        title: Text(
          DateFormat('yyyy年 M月')
              .format(DateTime(now.year, now.month + monthDuration)),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        // 影をなくす
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 30,
              color: Colors.black.withOpacity(0.9),
              child: Row(
                children: weekName
                    .map((e) => Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            // eに月曜日〜日曜日までの文字列の値が入っている。
                            child: Text(
                              e,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (holiday.any((name) => name == e))
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 3),
            Expanded(child: createCalenderItem()),
          ],
        ),
      ),
      // 画面右下のプラスボタン
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.orangeAccent,
        onPressed: () async {
          addSchedule();
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.deepOrangeAccent],
            ),
          ),
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // エラーダイアログ
  Future<void> errorDialog() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.redAccent.shade200,
              title: Text(
                '警告',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(
                      '終了時刻を確認してください。',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    '閉じる',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  // スケジュール追加のシンプルダイアログ
  Widget buildAppScheduleDialog() {
    return StatefulBuilder(builder: (context, setState) {
      return SimpleDialog(
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: TextFormField(
                        controller: titleController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          hintText: 'タイトルを追加',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '入力してください。';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  // 削除ボタン
                  IconButton(
                    onPressed: () {
                      titleController.clear();
                    },
                    splashRadius: 15,
                    splashColor: Colors.red,
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                  // 追加ボタン
                  IconButton(
                    onPressed: () {
                      final isFormValidate = !_formKey.currentState!.validate();
                      if (isFormValidate) {
                        return;
                      }
                      if (!validationIsOk()) {
                        errorDialog();
                        return;
                      }

                      DateTime checkScheduleTime = DateTime(
                          selectedStartTime!.year,
                          selectedStartTime!.month,
                          selectedStartTime!.day);

                      Schedule newSchedule = Schedule(
                          title: titleController.text,
                          startAt: selectedStartTime!,
                          endAt: selectedEndTime!);

                      // scheduleMapに選択している日付のキーが含まれている場合
                      if (scheduleMap.containsKey(checkScheduleTime)) {
                        scheduleMap[checkScheduleTime]!.add(newSchedule);
                      } else {
                        // キーが存在していない場合、キーに新しいスケジュールの情報を入れる
                        scheduleMap[checkScheduleTime] = [newSchedule];
                      }

                      selectedEndTime = null;

                      Navigator.pop(context, true);

                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(
                                  '追加',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      Text(
                                        'スケジュールを追加しました。',
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      '閉じる',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    },
                                  ),
                                ],
                              ));
                    },
                    splashRadius: 15,
                    splashColor: Colors.green,
                    icon: Icon(
                      Icons.send,
                      color: Colors.green,
                    ),
                  ),
                  //閉じるボタン
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    splashRadius: 15,
                    splashColor: Colors.red,
                    icon: Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // 開始時刻
                GestureDetector(
                  onTap: () async {
                    buildDayOption(selectedDate);
                    isSettingStartTime = true;
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return buildSelectedTimeDialog();
                        });
                    setState(() {});
                  },
                  child: Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '開始',
                          style: TextStyle(color: Colors.pink),
                        ),
                        SizedBox(width: 10),
                        Text(DateFormat('yyyy').format(selectedStartTime!)),
                        SizedBox(width: 5),
                        Text(DateFormat('MM/dd').format(selectedStartTime!)),
                        SizedBox(width: 5),
                        Text(DateFormat('HH:mm').format(selectedStartTime!)),
                      ],
                    ),
                  ),
                ),
                // 終了時刻
                GestureDetector(
                  onTap: () async {
                    buildDayOption(selectedDate);
                    isSettingStartTime = false;
                    selectedEndTime ??= selectedStartTime;
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return buildSelectedTimeDialog();
                        });
                    setState(() {});
                  },
                  child: Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '終了',
                          style: TextStyle(color: Colors.blue),
                        ),
                        SizedBox(width: 10),
                        Text(selectedEndTime == null
                            ? '-----'
                            : DateFormat('yyyy').format(selectedEndTime!)),
                        SizedBox(width: 5),
                        Text(selectedEndTime == null
                            ? '--/--'
                            : DateFormat('MM/dd').format(selectedEndTime!)),
                        SizedBox(width: 5),
                        Text(selectedEndTime == null
                            ? '--:--'
                            : DateFormat('HH:mm').format(selectedEndTime!)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      );
    });
  }

  // スケジュール編集のシンプルダイアログ
  Widget buildEditAppScheduleDialog() {
    return StatefulBuilder(builder: (context, setState) {
      return SimpleDialog(
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: titleController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          hintText: 'タイトルを編集',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '入力してください。';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  // 削除ボタン
                  IconButton(
                    onPressed: () {
                      titleController.clear();
                    },
                    splashRadius: 15,
                    splashColor: Colors.red,
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                  // 追加ボタン
                  IconButton(
                    onPressed: () {
                      final isFormValidate = !_formKey.currentState!.validate();
                      if (isFormValidate) {
                        return;
                      }
                      if (!validationIsOk()) {
                        errorDialog();
                        return;
                      }

                      DateTime checkScheduleTime = DateTime(
                          selectedStartTime!.year,
                          selectedStartTime!.month,
                          selectedStartTime!.day);

                      Schedule newSchedule = Schedule(
                          title: titleController.text,
                          startAt: selectedStartTime!,
                          endAt: selectedEndTime!);

                      // scheduleMapに選択している日付のキーが含まれている場合
                      if (scheduleMap.containsKey(checkScheduleTime)) {
                        scheduleMap[checkScheduleTime]!.add(newSchedule);
                      } else {
                        // キーが存在していない場合、キーに新しいスケジュールの情報を入れる
                        scheduleMap[checkScheduleTime] = [newSchedule];
                      }

                      selectedEndTime = null;

                      Navigator.pop(context, true);

                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(
                                  '編集',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      Text(
                                        'スケジュールを編集しました。',
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      '閉じる',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    },
                                  ),
                                ],
                              ));
                    },
                    splashRadius: 15,
                    splashColor: Colors.green,
                    icon: Icon(
                      Icons.edit,
                      color: Colors.green,
                    ),
                  ),
                  //閉じるボタン
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    splashRadius: 15,
                    splashColor: Colors.red,
                    icon: Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // 開始時刻
                GestureDetector(
                  onTap: () async {
                    buildDayOption(selectedDate);
                    isSettingStartTime = true;
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return buildSelectedTimeDialog();
                        });
                    setState(() {});
                  },
                  child: Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '開始',
                          style: TextStyle(color: Colors.pink),
                        ),
                        SizedBox(width: 10),
                        Text(DateFormat('yyyy').format(selectedStartTime!)),
                        SizedBox(width: 5),
                        Text(DateFormat('MM/dd').format(selectedStartTime!)),
                        SizedBox(width: 5),
                        Text(DateFormat('HH:mm').format(selectedStartTime!)),
                      ],
                    ),
                  ),
                ),
                // 終了時刻
                GestureDetector(
                  onTap: () async {
                    buildDayOption(selectedDate);
                    isSettingStartTime = false;
                    selectedEndTime ??= selectedStartTime;
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return buildSelectedTimeDialog();
                        });
                    setState(() {});
                  },
                  child: Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '終了',
                          style: TextStyle(color: Colors.blue),
                        ),
                        SizedBox(width: 10),
                        Text(selectedEndTime == null
                            ? '-----'
                            : DateFormat('yyyy').format(selectedEndTime!)),
                        SizedBox(width: 5),
                        Text(selectedEndTime == null
                            ? '--/--'
                            : DateFormat('MM/dd').format(selectedEndTime!)),
                        SizedBox(width: 5),
                        Text(selectedEndTime == null
                            ? '--:--'
                            : DateFormat('HH:mm').format(selectedEndTime!)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      );
    });
  }

  // スケジュールを表示するWidget
  Widget buildSelectedTimeDialog() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: StatefulBuilder(builder: (context, setState) {
        return SimpleDialog(
          titlePadding: EdgeInsets.zero,
          title: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '日時を選択',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // 追加ボタン
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    splashRadius: 15,
                    splashColor: Colors.green,
                    icon: Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                  ),
                  // 削除ボタン
                  IconButton(
                    onPressed: () {
                      titleController.clear();
                      Navigator.pop(context);
                    },
                    splashRadius: 15,
                    splashColor: Colors.red,
                    icon: Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Container(
                height: 120,
                width: 350,
                child: Row(
                  children: [
                    // 年ピッカー
                    Expanded(
                      flex: 2,
                      child: CupertinoPicker(
                        selectionOverlay:
                            const CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent),
                        itemExtent: 35,
                        onSelectedItemChanged: (int index) {
                          if (isSettingStartTime) {
                            selectedStartTime = DateTime(
                                yearOption[index],
                                selectedStartTime!.month,
                                selectedStartTime!.day,
                                selectedStartTime!.hour,
                                selectedStartTime!.minute);
                          } else {
                            selectedEndTime = DateTime(
                                yearOption[index],
                                selectedEndTime!.month,
                                selectedEndTime!.day,
                                selectedEndTime!.hour,
                                selectedEndTime!.minute);
                          }
                        },
                        children: yearOption
                            .map(
                              (e) => Container(
                                alignment: Alignment.center,
                                height: 35,
                                child: Text('$e'),
                              ),
                            )
                            .toList(),
                        scrollController: FixedExtentScrollController(
                          initialItem: yearOption.indexOf(isSettingStartTime
                              ? selectedStartTime!.year
                              : selectedEndTime!.year),
                        ),
                      ),
                    ),
                    Text('年'),
                    // 月ピッカー
                    Expanded(
                      child: CupertinoPicker(
                        selectionOverlay:
                            const CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent),
                        itemExtent: 35,
                        onSelectedItemChanged: (int index) {
                          if (isSettingStartTime) {
                            selectedStartTime = DateTime(
                                selectedStartTime!.year,
                                monthOption[index],
                                selectedStartTime!.day,
                                selectedStartTime!.hour,
                                selectedStartTime!.minute);
                            buildDayOption(selectedStartTime!);
                          } else {
                            selectedEndTime = DateTime(
                                selectedEndTime!.year,
                                monthOption[index],
                                selectedEndTime!.day,
                                selectedEndTime!.hour,
                                selectedEndTime!.minute);
                            buildDayOption(selectedEndTime!);
                          }
                          setState(() {});
                        },
                        children: monthOption
                            .map(
                              (e) => Container(
                                alignment: Alignment.center,
                                height: 35,
                                child: Text('$e'),
                              ),
                            )
                            .toList(),
                        scrollController: FixedExtentScrollController(
                          initialItem: monthOption.indexOf(isSettingStartTime
                              ? selectedStartTime!.month
                              : selectedEndTime!.month),
                        ),
                      ),
                    ),
                    Text('月'),
                    // 日ピッカー
                    Expanded(
                      child: CupertinoPicker(
                        selectionOverlay:
                            const CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent),
                        itemExtent: 35,
                        onSelectedItemChanged: (int index) {
                          if (isSettingStartTime) {
                            selectedStartTime = DateTime(
                                selectedStartTime!.year,
                                selectedStartTime!.month,
                                dayOption![index],
                                selectedStartTime!.hour,
                                selectedStartTime!.minute);
                          } else {
                            selectedEndTime = DateTime(
                                selectedEndTime!.year,
                                selectedEndTime!.month,
                                dayOption![index],
                                selectedEndTime!.hour,
                                selectedEndTime!.minute);
                          }
                        },
                        children: dayOption!
                            .map(
                              (e) => Container(
                                alignment: Alignment.center,
                                height: 35,
                                child: Text('$e'),
                              ),
                            )
                            .toList(),
                        scrollController: FixedExtentScrollController(
                          initialItem: dayOption!.indexOf(isSettingStartTime
                              ? selectedStartTime!.day
                              : selectedEndTime!.day),
                        ),
                      ),
                    ),
                    Text('日'),
                    // 時ピッカー
                    Expanded(
                      child: CupertinoPicker(
                        selectionOverlay:
                            const CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent),
                        itemExtent: 35,
                        onSelectedItemChanged: (int index) {
                          if (isSettingStartTime) {
                            selectedStartTime = DateTime(
                                selectedStartTime!.year,
                                selectedStartTime!.month,
                                selectedStartTime!.day,
                                hourOption[index],
                                selectedStartTime!.minute);
                          } else {
                            selectedEndTime = DateTime(
                                selectedEndTime!.year,
                                selectedEndTime!.month,
                                selectedEndTime!.day,
                                hourOption[index],
                                selectedEndTime!.minute);
                          }
                        },
                        children: hourOption
                            .map(
                              (e) => Container(
                                alignment: Alignment.center,
                                height: 35,
                                child: Text('$e'),
                              ),
                            )
                            .toList(),
                        scrollController: FixedExtentScrollController(
                          initialItem: hourOption.indexOf(isSettingStartTime
                              ? selectedStartTime!.hour
                              : selectedEndTime!.hour),
                        ),
                      ),
                    ),
                    Text('時'),
                    // 分ピッカー
                    Expanded(
                      child: CupertinoPicker(
                        selectionOverlay:
                            const CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent),
                        itemExtent: 35,
                        onSelectedItemChanged: (int index) {
                          if (isSettingStartTime) {
                            selectedStartTime = DateTime(
                                selectedStartTime!.year,
                                selectedStartTime!.month,
                                selectedStartTime!.day,
                                selectedStartTime!.hour,
                                minuteOption[index]);
                          } else {
                            selectedEndTime = DateTime(
                                selectedEndTime!.year,
                                selectedEndTime!.month,
                                selectedEndTime!.day,
                                selectedEndTime!.hour,
                                minuteOption[index]);
                          }
                        },
                        children: minuteOption
                            .map(
                              (e) => Container(
                                alignment: Alignment.center,
                                height: 35,
                                child: Text('$e'),
                              ),
                            )
                            .toList(),
                        scrollController: FixedExtentScrollController(
                          initialItem: minuteOption.indexOf(isSettingStartTime
                              ? selectedStartTime!.minute
                              : selectedEndTime!.minute),
                        ),
                      ),
                    ),
                    Text('分'),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  bool validationIsOk() {
    if (selectedEndTime == null) {
      print('終了が入力されていない。');
      return false;
    } else if (selectedStartTime!.isAfter(selectedEndTime!)) {
      print('開始が終了より遅い。');
      return false;
    } else {
      print('正常');
      return true;
    }
  }

  Future<void> editSchedule(
      {required int index, required Schedule selectedSchedule}) async {
    selectedStartTime = selectedSchedule.startAt;
    selectedEndTime = selectedSchedule.endAt;
    titleController.text = selectedSchedule.title;
    final result = await showDialog(
        context: context,
        builder: (context) {
          return buildEditAppScheduleDialog();
        });
    // 元々登録されているデータを削除
    if (result == true) {
      scheduleMap[DateTime(selectedSchedule.startAt.year,
              selectedSchedule.startAt.month, selectedSchedule.startAt.day)]!
          .removeAt(index);
    }
    titleController.clear();

    setState(() {});
  }

  Future<void> deleteSchedule(
      {required int index, required Schedule selectedSchedule}) async {
    scheduleMap[DateTime(selectedSchedule.startAt.year,
            selectedSchedule.startAt.month, selectedSchedule.startAt.day)]!
        .removeAt(index);
    setState(() {});
  }

  Future<void> addSchedule() async {
    selectedStartTime = selectedDate;
    await showDialog(
        context: context,
        builder: (context) {
          return buildAppScheduleDialog();
        });
    titleController.clear();
    setState(() {});
  }

  Widget createCalenderItem() {
    return PageView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          List<Widget> _list = [];
          List<Widget> _listCache = [];

          DateTime date =
              DateTime(now.year, now.month + index - initialIndex, 1);

          int monthLastDay = DateTime(date.year, date.month + 1, 1)
              .subtract(Duration(days: 1))
              .day;

          for (int i = 0; i < monthLastDay; i++) {
            _listCache.add(_CalenderItem(
              day: i + 1,
              now: now,
              casheDate: DateTime(date.year, date.month, i + 1),
              scheduleList: scheduleMap[DateTime(date.year, date.month, i + 1)],
              holidayList: holidayMap[DateTime(date.year, date.month, i + 1)],
              selectedDate: selectedDate,
              selectDate: selectDate,
              editSchedule: editSchedule,
              addSchedule: addSchedule,
              deleteSchedule: deleteSchedule,
            ));
            int repeatNumber = 7 - _listCache.length;
            if (date.add(Duration(days: i)).weekday == 7) {
              if (i < 7) {
                _listCache.insertAll(
                    0,
                    List.generate(
                        repeatNumber,
                        (index) => Expanded(
                                child: Container(
                              color: Colors.orangeAccent.withOpacity(0.2),
                            ))));
              }
              _list.add(Expanded(child: Row(children: _listCache)));
              _listCache = [];
            } else if (i == monthLastDay - 1) {
              _listCache.addAll(List.generate(
                  repeatNumber,
                  (index) => Expanded(
                          child: Container(
                        color: Colors.orangeAccent.withOpacity(0.2),
                      ))));
              _list.add(Expanded(child: Row(children: _listCache)));
            }
          }
          return Column(
            children: _list,
          );
        });
  }
}

class _CalenderItem extends StatelessWidget {
  final int day;
  final DateTime now;
  final DateTime casheDate;
  final DateTime selectedDate;
  final List<Schedule>? scheduleList;
  final List<Schedule>? holidayList;
  final Function selectDate;
  final Function editSchedule;
  final Function addSchedule;
  final Function deleteSchedule;
  const _CalenderItem(
      {required this.day,
      required this.now,
      required this.casheDate,
      required this.selectedDate,
      this.scheduleList,
      this.holidayList,
      required this.selectDate,
      required this.editSchedule,
      required this.addSchedule,
      required this.deleteSchedule,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = (selectedDate.difference(casheDate).inDays == 0) &&
        (selectedDate.day == casheDate.day);
    // 今日がどうかの判定
    bool isToday =
        (now.difference(casheDate).inDays == 0) && (now.day == casheDate.day);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          selectDate(casheDate);
        },
        onDoubleTap: () {
          addSchedule();
        },
        onLongPress: () {
          addSchedule();
        },
        child: Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            color: isSelected ? Colors.redAccent.withOpacity(0.3) : null,
            border: Border.all(color: Colors.orangeAccent),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isToday ? Colors.orange : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.topCenter,
                  width: 20,
                  height: 20,
                  child: Text(
                    '$day',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // 祝日機能
                holidayList == null
                    ? Container()
                    : Column(
                        children: holidayList!
                            .map(
                              (e) => GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text(
                                              e.title,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: [
                                                  Text(
                                                    'この日は『${e.title}』です。',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                  '閉じる',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .popUntil((route) =>
                                                          route.isFirst);
                                                },
                                              ),
                                            ],
                                          ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.pinkAccent, Colors.red],
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: double.infinity,
                                  height: 20,
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      top: 2, left: 2, right: 2),
                                  child: Text(
                                    e.title,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                scheduleList == null
                    ? Container()
                    : Column(
                        children: scheduleList!
                            .asMap()
                            .entries
                            .map(
                              (e) => GestureDetector(
                                onTap: () {
                                  print('タップ');
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text(e.value.title),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: [
                                                  Text(
                                                      '『${e.value.title}』をどうしますか？')
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  TextButton(
                                                    child: Text(
                                                      '編集',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      editSchedule(
                                                          index: e.key,
                                                          selectedSchedule:
                                                              e.value);
                                                    },
                                                  ),
                                                  // Container(
                                                  //   width: 70,
                                                  //   height: 40,
                                                  //   decoration: BoxDecoration(
                                                  //     borderRadius:
                                                  //         BorderRadius.circular(
                                                  //             10),
                                                  //     gradient: LinearGradient(
                                                  //       colors: [
                                                  //         Colors.greenAccent,
                                                  //         Colors.green
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  //   child: TextButton(
                                                  //     onPressed: () {
                                                  //       Navigator.pop(context);
                                                  //       editSchedule(
                                                  //           index: e.key,
                                                  //           selectedSchedule:
                                                  //               e.value);
                                                  //     },
                                                  //     child: Text(
                                                  //       '編集',
                                                  //       style: TextStyle(
                                                  //           color: Colors.white,
                                                  //           fontSize: 15),
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  TextButton(
                                                    child: Text(
                                                      '削除',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.red),
                                                    ),
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder:
                                                              (context) =>
                                                                  AlertDialog(
                                                                    // backgroundColor: Colors.redAccent.shade200,
                                                                    title: Text(
                                                                      '確認',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    content:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          ListBody(
                                                                        children: [
                                                                          Text(
                                                                            '『${e.value.title}』を本当に削除しますか？',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        child:
                                                                            Text(
                                                                          '削除',
                                                                          style: TextStyle(
                                                                              fontSize: 20,
                                                                              color: Colors.red),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.of(
                                                                              context);
                                                                          deleteSchedule(
                                                                              index: e.key,
                                                                              selectedSchedule: e.value);
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) => AlertDialog(
                                                                                    // backgroundColor: Colors.redAccent.shade200,
                                                                                    title: Text(
                                                                                      '削除',
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                    content: SingleChildScrollView(
                                                                                      child: ListBody(
                                                                                        children: [
                                                                                          Text(
                                                                                            '『${e.value.title}』を削除しました。',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    actions: [
                                                                                      TextButton(
                                                                                        child: Text(
                                                                                          '閉じる',
                                                                                          style: TextStyle(fontSize: 20),
                                                                                        ),
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ));
                                                                        },
                                                                      ),
                                                                      TextButton(
                                                                        child:
                                                                            Text(
                                                                          'キャンセル',
                                                                          style:
                                                                              TextStyle(fontSize: 20),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context).popUntil((route) =>
                                                                              route.isFirst);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ));
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text(
                                                      '閉じる',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ));
                                },
                                onDoubleTap: () {
                                  editSchedule(
                                      index: e.key, selectedSchedule: e.value);
                                },
                                onLongPress: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            // backgroundColor: Colors.redAccent.shade200,
                                            title: Text(
                                              '確認',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: [
                                                  Text(
                                                    '『${e.value.title}』を本当に削除しますか？',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                  '削除',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.red),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  deleteSchedule(
                                                      index: e.key,
                                                      selectedSchedule:
                                                          e.value);
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            // backgroundColor: Colors.redAccent.shade200,
                                                            title: Text(
                                                              '削除',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: ListBody(
                                                                children: [
                                                                  Text(
                                                                    '『${e.value.title}』を削除しました。',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                child: Text(
                                                                  '閉じる',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .popUntil(
                                                                          (route) =>
                                                                              route.isFirst);
                                                                },
                                                              ),
                                                            ],
                                                          ));
                                                },
                                              ),
                                              TextButton(
                                                child: Text(
                                                  'キャンセル',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .popUntil((route) =>
                                                          route.isFirst);
                                                },
                                              ),
                                            ],
                                          ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.greenAccent,
                                        Colors.green
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: double.infinity,
                                  height: 20,
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      top: 2, left: 2, right: 2),
                                  child: Text(
                                    e.value.title,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
