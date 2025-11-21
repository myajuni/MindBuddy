// lib/screens/notification_setting_screen.dart 파일

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool enabled = true;
  TimeOfDay time = const TimeOfDay(hour: 20, minute: 0);
  final List<bool> weekdaySelected = List<bool>.filled(7, false); // 1=월 ~ 7=일
  DateTime? oneTimeDate;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final sp = await SharedPreferences.getInstance();

    enabled = sp.getBool('notif_enabled') ?? true;

    final h = sp.getInt('notif_hour');
    final m = sp.getInt('notif_min');
    if (h != null && m != null) {
      time = TimeOfDay(hour: h, minute: m);
    }

    final wd =
        sp.getStringList('notif_weekdays')?.map(int.parse).toList() ?? <int>[];
    for (int i = 0; i < 7; i++) {
      weekdaySelected[i] = wd.contains(i + 1);
    }

    final od = sp.getString('notif_one_date');
    if (od != null) oneTimeDate = DateTime.tryParse(od);

    if (mounted) setState(() => _loading = false);
  }

  List<int> _selectedWeekdays() {
    final result = <int>[];
    for (int i = 0; i < 7; i++) {
      if (weekdaySelected[i])
        result.add(i + 1); // DateTime.monday = 1 ~ sunday = 7
    }
    return result;
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: time);
    if (t != null) setState(() => time = t);
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: oneTimeDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
      helpText: '1회 알림 날짜 선택',
    );
    if (d != null) setState(() => oneTimeDate = d);
  }

  Future<void> _saveAndSchedule() async {
    if (!mounted) return;

    final selectedWeekdays = _selectedWeekdays();
    if (enabled && selectedWeekdays.isEmpty && oneTimeDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('반복 요일을 하나 이상 선택하거나 1회 날짜를 지정해주세요.'),
        ),
      );
      return;
    }

    // 저장
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('notif_enabled', enabled);
    await sp.setInt('notif_hour', time.hour);
    await sp.setInt('notif_min', time.minute);
    await sp.setStringList(
      'notif_weekdays',
      selectedWeekdays.map((e) => '$e').toList(),
    );
    if (oneTimeDate != null) {
      await sp.setString('notif_one_date', oneTimeDate!.toIso8601String());
    } else {
      await sp.remove('notif_one_date');
    }

    // 스케줄링
    final ns = NotificationService(); // factory 싱글톤
    await ns.init();
    await ns.cancelAll();

    if (enabled) {
      if (selectedWeekdays.isNotEmpty) {
        await ns.scheduleWeekly(
          idBase: 1000,
          time: time,
          weekdays: selectedWeekdays,
        );
      }
      if (oneTimeDate != null) {
        final when = DateTime(
          oneTimeDate!.year,
          oneTimeDate!.month,
          oneTimeDate!.day,
          time.hour,
          time.minute,
        );
        if (when.isAfter(DateTime.now())) {
          await ns.scheduleOneTime(id: 2000, when: when);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('지정한 1회 알림 시간이 이미 지났어요. 날짜/시간을 다시 선택해주세요.'),
            ),
          );
        }
      }

      // 저장 확인 + 빠른 동작 확인용 테스트 알림(5초 뒤)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 설정이 저장되었습니다. (5초 뒤 테스트 알림)')),
      );
      await ns.showInSeconds(5, body: '테스트 알림이 보이면 설정 완료!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림이 비활성화되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = const ['월', '화', '수', '목', '금', '토', '일'];

    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 알림 on/off
                SwitchListTile(
                  title: const Text('알림 사용'),
                  value: enabled,
                  onChanged: (v) => setState(() => enabled = v),
                ),
                const SizedBox(height: 12),

                // 시간 선택
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('시간'),
                  subtitle: Text(time.format(context)),
                  onTap: _pickTime,
                ),
                const Divider(height: 24),

                // 요일(반복)
                Row(
                  children: [
                    const Text(
                      '요일(반복)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: '선택한 요일에 매주 같은 시간으로 알림이 울립니다.',
                      child: const Icon(Icons.info_outline, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ✅ 자연 크기 + 가로 스크롤 가능한 요일 칩
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(labels.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(labels[i]),
                          selected: weekdaySelected[i],
                          onSelected: (v) =>
                              setState(() => weekdaySelected[i] = v),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 16),

                // 1회 알림 날짜
                ListTile(
                  leading: const Icon(Icons.event_available_rounded),
                  title: const Text('1회 알림 날짜 (선택사항)'),
                  subtitle: Text(
                    oneTimeDate == null
                        ? '미선택'
                        : '${oneTimeDate!.year}.${oneTimeDate!.month}.${oneTimeDate!.day}',
                  ),
                  onTap: _pickDate,
                  onLongPress: () => setState(() => oneTimeDate = null),
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveAndSchedule,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('저장하기'),
                ),
                const SizedBox(height: 8),
                Text(
                  '설명\n'
                  '• 선택한 요일에는 매주 같은 시간에 알림이 옵니다.\n'
                  '• 날짜를 지정하면 그 날짜에 1회 알림도 함께 예약돼요.\n'
                  '• 날짜 타일을 길게 누르면 1회 알림이 제거됩니다.\n'
                  '• 알림이 오지 않으면 배터리 최적화를 해제해 보세요(기기별 상이).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}
