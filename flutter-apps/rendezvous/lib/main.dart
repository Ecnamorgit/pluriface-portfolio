// Démo Pluriface — Prise de rendez-vous pour un salon, un cabinet, un artisan.
// Un seul code Flutter pour Android, iPhone et le web.
// Créneaux fictifs : en production, l'agenda est synchronisé avec le professionnel.

import 'package:flutter/material.dart';

void main() => runApp(const RendezVousApp());

const kInk = Color(0xFF0F2A4F);
const kBrand = Color(0xFF7C3AED); // violet : à remplacer par la couleur du professionnel

class Service {
  const Service(this.name, this.minutes, this.price, this.icon);
  final String name;
  final int minutes;
  final int price;
  final IconData icon;
}

const services = [
  Service('Coupe', 30, 25, Icons.content_cut),
  Service('Coupe + brushing', 45, 38, Icons.air),
  Service('Coloration', 90, 65, Icons.palette_outlined),
  Service('Soin du cuir chevelu', 30, 30, Icons.spa_outlined),
];

class RendezVousApp extends StatelessWidget {
  const RendezVousApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prise de rendez-vous',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kBrand, primary: kBrand),
        scaffoldBackgroundColor: const Color(0xFFFBF8F2),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, foregroundColor: kInk, elevation: 0),
      ),
      home: const BookingFlow(),
    );
  }
}

class BookingFlow extends StatefulWidget {
  const BookingFlow({super.key});

  @override
  State<BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends State<BookingFlow> {
  int step = 0; // 0 service, 1 date+heure, 2 confirmation
  Service? service;
  int dayIndex = 0;
  String? slot;
  final List<String> booked = [];

  List<DateTime> get days => List.generate(7, (i) => DateTime.now().add(Duration(days: i + 1)));

  static const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const monthNames = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];

  List<String> slotsFor(DateTime d) {
    if (d.weekday == DateTime.sunday) return [];
    final all = ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30'];
    // Quelques créneaux déjà pris, de façon déterministe selon le jour.
    return all.where((s) => (s.hashCode + d.day) % 4 != 0).toList();
  }

  String longDate(DateTime d) => '${dayNames[d.weekday - 1]} ${d.day} ${monthNames[d.month - 1]}';

  void confirm() {
    setState(() {
      booked.add('${service!.name} · ${longDate(days[dayIndex])} à $slot');
      step = 2;
    });
  }

  void reset() => setState(() {
        step = 0;
        service = null;
        dayIndex = 0;
        slot = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: step > 0 && step < 2 ? IconButton(onPressed: () => setState(() => step--), icon: const Icon(Icons.arrow_back)) : null,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: kBrand, borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: const Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            const Text('Salon Démo', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(value: (step + 1) / 3, backgroundColor: const Color(0xFFE9E3D6), minHeight: 4),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (step) {
            0 => _servicesStep(),
            1 => _dateStep(),
            _ => _doneStep(),
          },
        ),
      ),
    );
  }

  Widget _title(String t, String sub) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ],
        ),
      );

  Widget _servicesStep() {
    return ListView(
      key: const ValueKey(0),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('Quelle prestation ?', 'Étape 1 sur 3'),
        for (final s in services)
          Card(
            elevation: 0,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2DCCF))),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFFEDE4FF), child: Icon(s.icon, color: kBrand)),
              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800, color: kInk)),
              subtitle: Text('${s.minutes} min'),
              trailing: Text('${s.price} €', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kInk)),
              onTap: () => setState(() {
                service = s;
                slot = null;
                step = 1;
              }),
            ),
          ),
        if (booked.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text('Mes rendez-vous', style: TextStyle(fontWeight: FontWeight.w800, color: kInk)),
          ),
          for (final b in booked)
            ListTile(leading: const Icon(Icons.event_available, color: kBrand), title: Text(b, style: const TextStyle(fontSize: 14))),
        ],
      ],
    );
  }

  Widget _dateStep() {
    final d = days[dayIndex];
    final slots = slotsFor(d);
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title('Quand ?', 'Étape 2 sur 3 · ${service!.name}, ${service!.minutes} min'),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final day = days[i];
              final on = i == dayIndex;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() {
                  dayIndex = i;
                  slot = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  decoration: BoxDecoration(
                    color: on ? kBrand : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: on ? kBrand : const Color(0xFFE2DCCF)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dayNames[day.weekday - 1], style: TextStyle(fontSize: 12, color: on ? Colors.white70 : Colors.black54)),
                      Text('${day.day}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: on ? Colors.white : kInk)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: slots.isEmpty
              ? const Center(child: Text('Fermé ce jour-là.', style: TextStyle(color: Colors.black54)))
              : GridView.count(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    for (final s in slots)
                      OutlinedButton(
                        onPressed: () => setState(() => slot = s),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: slot == s ? kBrand : Colors.white,
                          foregroundColor: slot == s ? Colors.white : kInk,
                          side: BorderSide(color: slot == s ? kBrand : const Color(0xFFE2DCCF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        child: Text(s),
                      ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: slot == null ? null : confirm,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            child: Text(slot == null ? 'Choisissez un créneau' : 'Confirmer ${longDate(d)} à $slot'),
          ),
        ),
      ],
    );
  }

  Widget _doneStep() {
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF14B3A3), size: 72),
          const SizedBox(height: 16),
          const Text('Rendez-vous confirmé', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
          const SizedBox(height: 8),
          Text('${service!.name} · ${longDate(days[dayIndex])} à $slot',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Un SMS de rappel est envoyé la veille. Vous pouvez annuler jusqu’à 24 h avant.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 28),
          FilledButton(onPressed: reset, child: const Text('Prendre un autre rendez-vous')),
        ],
      ),
    );
  }
}
