// Démo Pluriface — Information voyageurs pour un réseau de bus.
// Un seul code Flutter pour Android, iPhone et le web.
// Horaires simulés : en production, les données viennent d'un flux GTFS / temps réel.

import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const VoyageursApp());

const kInk = Color(0xFF0F2A4F);
const kTeal = Color(0xFF14B3A3);
const kCoral = Color(0xFFFF5A3C);

class Line {
  const Line(this.code, this.name, this.color, this.freqMin);
  final String code;
  final String name;
  final Color color;
  final int freqMin;
}

const lines = [
  Line('1', 'Gare ↔ Centre commercial', Color(0xFFE11D48), 12),
  Line('2', 'Hôpital ↔ Quartier des Bruyères', Color(0xFF2563EB), 15),
  Line('3', 'Lycée ↔ Zone d’activités', Color(0xFF16A34A), 20),
  Line('N', 'Navette centre-ville', Color(0xFF7C3AED), 8),
];

class Stop {
  const Stop(this.name, this.lineCodes, this.offsetMin);
  final String name;
  final List<String> lineCodes;
  final int offsetMin;
}

const stops = [
  Stop('Gare SNCF', ['1', '2', 'N'], 0),
  Stop('Place de la Mairie', ['1', '3', 'N'], 3),
  Stop('Hôpital', ['2'], 5),
  Stop('Lycée Jean-Moulin', ['3'], 7),
];

class VoyageursApp extends StatelessWidget {
  const VoyageursApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Info voyageurs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kTeal, primary: kTeal),
        scaffoldBackgroundColor: const Color(0xFFF3F6F9),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  Timer? timer;
  DateTime now = DateTime.now();
  final Set<String> favorites = {'Gare SNCF', 'Place de la Mairie'};
  bool alertOpen = true;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 20), (_) => setState(() => now = DateTime.now()));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// Prochains passages simulés : à partir de la fréquence de la ligne et d'un décalage par arrêt.
  List<int> nextDepartures(Line line, Stop stop) {
    final minuteOfDay = now.hour * 60 + now.minute;
    final phase = (minuteOfDay - stop.offsetMin) % line.freqMin;
    final first = (line.freqMin - phase) % line.freqMin;
    return [first, first + line.freqMin, first + 2 * line.freqMin];
  }

  Line lineOf(String code) => lines.firstWhere((l) => l.code == code);

  @override
  Widget build(BuildContext context) {
    final pages = [_nextPage(), _linesPage(), _alertsPage()];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kInk,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: kTeal, borderRadius: BorderRadius.circular(8)),
              child: const Text('BUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
            const SizedBox(width: 10),
            const Text('Votre réseau', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Prochains'),
          NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route), label: 'Lignes'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alertes'),
        ],
      ),
    );
  }

  Widget _alertBanner() {
    if (!alertOpen) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFE3DC), borderRadius: BorderRadius.circular(14), border: Border.all(color: kCoral)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: kCoral),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Ligne 2 : arrêt Hôpital non desservi jusqu’à 17 h (travaux). Report à l’arrêt Clinique.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kInk)),
          ),
          IconButton(onPressed: () => setState(() => alertOpen = false), icon: const Icon(Icons.close, size: 18)),
        ],
      ),
    );
  }

  Widget _nextPage() {
    final favStops = stops.where((s) => favorites.contains(s.name)).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _alertBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              const Text('Mes arrêts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => now = DateTime.now()),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Actualiser'),
              ),
            ],
          ),
        ),
        if (favStops.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Ajoutez des arrêts en favoris depuis l’onglet Lignes.', style: TextStyle(color: Colors.black54)),
          ),
        for (final s in favStops) _stopCard(s),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text('Horaires simulés pour la démonstration. En production : horaires théoriques (GTFS) et temps réel.',
              style: TextStyle(fontSize: 12, color: Colors.black45)),
        ),
      ],
    );
  }

  Widget _stopCard(Stop s) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place, color: kTeal, size: 20),
              const SizedBox(width: 6),
              Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kInk))),
              IconButton(
                onPressed: () => setState(() => favorites.remove(s.name)),
                icon: const Icon(Icons.star, color: Color(0xFFFFB300)),
                tooltip: 'Retirer des favoris',
              ),
            ],
          ),
          for (final code in s.lineCodes) _departureRow(lineOf(code), s),
        ],
      ),
    );
  }

  Widget _departureRow(Line l, Stop s) {
    final d = nextDepartures(l, s);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _badge(l),
          const SizedBox(width: 10),
          Expanded(child: Text(l.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
          for (var i = 0; i < d.length; i++)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: i == 0 ? kTeal : const Color(0xFFEFF3F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                d[i] == 0 ? 'à quai' : '${d[i]} min',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: i == 0 ? Colors.white : kInk),
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(Line l) {
    return Container(
      width: 32,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: l.color, borderRadius: BorderRadius.circular(8)),
      child: Text(l.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
    );
  }

  Widget _linesPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Lignes et arrêts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
        const SizedBox(height: 8),
        for (final l in lines)
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: ExpansionTile(
              leading: _badge(l),
              title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              subtitle: Text('Toutes les ${l.freqMin} min'),
              shape: const Border(),
              children: [
                for (final s in stops.where((s) => s.lineCodes.contains(l.code)))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined, size: 18),
                    title: Text(s.name),
                    trailing: IconButton(
                      icon: Icon(favorites.contains(s.name) ? Icons.star : Icons.star_border,
                          color: favorites.contains(s.name) ? const Color(0xFFFFB300) : null),
                      onPressed: () => setState(() {
                        if (!favorites.remove(s.name)) favorites.add(s.name);
                      }),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _alertsPage() {
    final items = [
      (Icons.construction, kCoral, 'Travaux · ligne 2', 'Arrêt Hôpital non desservi jusqu’à 17 h. Report à l’arrêt Clinique.'),
      (Icons.event, kTeal, 'Marché de Noël', 'Samedi : la navette N circule toutes les 5 min de 10 h à 20 h.'),
      (Icons.info_outline, kInk, 'Nouveaux horaires', 'Les horaires d’hiver s’appliquent à partir du 1er décembre.'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: items[i].$2, child: Icon(items[i].$1, color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(items[i].$3, style: const TextStyle(fontWeight: FontWeight.w800, color: kInk)),
                  const SizedBox(height: 4),
                  Text(items[i].$4, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
