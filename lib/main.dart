import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const LunaHabitApp());

class LunaHabitApp extends StatelessWidget {
  const LunaHabitApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'LunaHabit',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const HabitHome(),
  );
}

// ─── MODEL ───────────────────────────────────────────────────
class Habit {
  String id, name, emoji;
  Color color;
  int streak;
  List<bool> week; // 7 days
  String frequency;

  Habit({required this.id, required this.name, required this.emoji,
         required this.color, required this.streak,
         required this.week, required this.frequency});
}

// ─── HOME ────────────────────────────────────────────────────
class HabitHome extends StatefulWidget {
  const HabitHome({super.key});
  @override
  State<HabitHome> createState() => _HabitHomeState();
}

class _HabitHomeState extends State<HabitHome> with TickerProviderStateMixin {
  late AnimationController _moonCtrl;

  final List<Habit> _habits = [
    Habit(id:'1', name:'Morning Meditation', emoji:'🧘', color:const Color(0xFF8b5cf6),
          streak:7, week:[true,true,true,false,true,true,false], frequency:'Daily'),
    Habit(id:'2', name:'Read 20 Pages', emoji:'📖', color:const Color(0xFFf59e0b),
          streak:4, week:[true,false,true,true,false,true,true], frequency:'Daily'),
    Habit(id:'3', name:'Drink 8 Glasses', emoji:'💧', color:const Color(0xFF0ea5e9),
          streak:12, week:[true,true,true,true,true,true,false], frequency:'Daily'),
    Habit(id:'4', name:'Exercise 30 min', emoji:'🏃', color:const Color(0xFF10b981),
          streak:3, week:[false,true,true,false,true,false,true], frequency:'Daily'),
    Habit(id:'5', name:'Study Flutter', emoji:'📱', color:const Color(0xFFef4444),
          streak:9, week:[true,true,true,true,true,false,false], frequency:'Weekdays'),
  ];

  int get _totalDone => _habits.where((h) => h.week[6]).length;
  int get _bestStreak => _habits.map((h) => h.streak).reduce(max);

  @override
  void initState() {
    super.initState();
    _moonCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() { _moonCtrl.dispose(); super.dispose(); }

  void _toggleToday(String id) {
    setState(() {
      final h = _habits.firstWhere((h) => h.id == id);
      h.week[6] = !h.week[6];
      if (h.week[6]) h.streak++; else if (h.streak > 0) h.streak--;
    });
  }

  void _addHabit() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddHabitSheet(onAdd: (h) {
        setState(() => _habits.add(h));
      }),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF060b14),
    body: Stack(children: [
      // Animated moon bg
      AnimatedBuilder(
        animation: _moonCtrl,
        builder: (_, __) => Positioned(
          top: -80 + sin(_moonCtrl.value * 2 * pi) * 15,
          right: -60,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF8b5cf6).withOpacity(0.15),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ),
      SafeArea(child: Column(children: [
        _buildHeader(),
        _buildSummaryRow(),
        _buildDayLabels(),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            ..._habits.map((h) => _buildHabitCard(h)),
          ],
        )),
      ])),
    ]),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addHabit,
      backgroundColor: const Color(0xFF8b5cf6),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text('Add Habit', style: TextStyle(
        color: Colors.white, fontWeight: FontWeight.w700)),
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('Luna', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w900,
            color: Color(0xFF8b5cf6), letterSpacing: -1,
          )),
          Text('Habit', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w900,
            color: Colors.white, letterSpacing: -1,
          )),
          SizedBox(width: 6),
          Text('🌙', style: TextStyle(fontSize: 20)),
        ]),
        Text(_getGreeting(), style: const TextStyle(
          fontSize: 12, color: Color(0xFF6b7280))),
      ]),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF8b5cf6).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8b5cf6).withOpacity(0.3)),
        ),
        child: Text('🔥 $_bestStreak day streak',
          style: const TextStyle(fontSize: 12, color: Color(0xFF8b5cf6),
              fontWeight: FontWeight.w700)),
      ),
    ]),
  );

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning! Rise and shine ☀️';
    if (h < 17) return 'Good afternoon! Keep going 💪';
    return 'Good evening! Wind down gently 🌙';
  }

  Widget _buildSummaryRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: [
      Expanded(child: _summaryCard('Today', '$_totalDone/${_habits.length}',
        'completed', const Color(0xFF8b5cf6))),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Best Streak', '$_bestStreak',
        'days in a row', const Color(0xFFf59e0b))),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Total', '${_habits.length}',
        'habits tracked', const Color(0xFF10b981))),
    ]),
  );

  Widget _summaryCard(String title, String value, String sub, Color color) =>
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF6b7280))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF6b7280))),
      ]),
    );

  Widget _buildDayLabels() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
    child: Row(children: [
      const Expanded(child: SizedBox()),
      ...['M','T','W','T','F','S','S'].map((d) => SizedBox(
        width: 32,
        child: Center(child: Text(d, style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4b5563)))),
      )),
    ]),
  );

  Widget _buildHabitCard(Habit h) => GestureDetector(
    onTap: () => _toggleToday(h.id),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: h.week[6] ? h.color.withOpacity(0.4) : Colors.white.withOpacity(0.06),
        ),
        boxShadow: h.week[6] ? [BoxShadow(
          color: h.color.withOpacity(0.15), blurRadius: 16)] : [],
      ),
      child: Row(children: [
        // Emoji + Name
        Text(h.emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h.name, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          Row(children: [
            Icon(Icons.local_fire_department_rounded, size: 12, color: h.color),
            const SizedBox(width: 3),
            Text('${h.streak} day streak', style: TextStyle(
              fontSize: 11, color: h.color, fontWeight: FontWeight.w600)),
          ]),
        ])),
        // Week dots
        ...h.week.asMap().entries.map((e) => _dot(e.value, h.color, e.key == 6)),
      ]),
    ),
  );

  Widget _dot(bool done, Color color, bool isToday) => Container(
    width: 28, height: 28,
    margin: const EdgeInsets.only(left: 4),
    decoration: BoxDecoration(
      color: done ? color : Colors.white.withOpacity(0.06),
      shape: BoxShape.circle,
      border: isToday ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)
                      : null,
      boxShadow: done ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)] : null,
    ),
    child: done ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
  );
}

// ─── ADD HABIT SHEET ─────────────────────────────────────────
class _AddHabitSheet extends StatefulWidget {
  final Function(Habit) onAdd;
  const _AddHabitSheet({required this.onAdd});
  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _ctrl = TextEditingController();
  String _emoji = '⭐';
  Color _color = const Color(0xFF8b5cf6);
  final emojis = ['⭐','🎯','💪','📚','🧘','💧','🏃','🎵','🌱','✍️'];
  final colors = [Color(0xFF8b5cf6),Color(0xFF0ea5e9),Color(0xFF10b981),
                  Color(0xFFf59e0b),Color(0xFFef4444),Color(0xFFec4899)];

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left:20, right:20, top:20,
      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
    ),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('New Habit 🌙', style: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 20),
      TextField(
        controller: _ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Habit name...',
          hintStyle: const TextStyle(color: Color(0xFF4b5563)),
          filled: true, fillColor: Colors.white.withOpacity(0.07),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 16),
      Wrap(spacing:10, children: emojis.map((e) => GestureDetector(
        onTap: () => setState(() => _emoji = e),
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _emoji == e ? const Color(0xFF8b5cf6).withOpacity(0.3)
                               : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: _emoji == e ? Border.all(color: const Color(0xFF8b5cf6)) : null,
          ),
          child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
        ),
      )).toList()),
      const SizedBox(height: 16),
      Wrap(spacing:10, children: colors.map((c) => GestureDetector(
        onTap: () => setState(() => _color = c),
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: c, shape: BoxShape.circle,
            border: _color == c ? Border.all(color: Colors.white, width: 2) : null,
          ),
        ),
      )).toList()),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: () {
          if (_ctrl.text.trim().isEmpty) return;
          widget.onAdd(Habit(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _ctrl.text.trim(), emoji: _emoji, color: _color,
            streak: 0, week: List.filled(7, false), frequency: 'Daily',
          ));
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF8b5cf6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text('Add Habit', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
        ),
      ),
    ]),
  );
}