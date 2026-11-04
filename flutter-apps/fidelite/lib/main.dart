// Démo Pluriface — Carte de fidélité pour commerçant.
// Un seul code Flutter pour Android, iPhone et le web.
// Données fictives, tout se passe dans l'appareil (aucun serveur).

import 'package:flutter/material.dart';

void main() => runApp(const FideliteApp());

const kBrand = Color(0xFFD97706); // ambre : à remplacer par la couleur du commerce
const kInk = Color(0xFF0F2A4F);

class FideliteApp extends StatelessWidget {
  const FideliteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carte de fidélité',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kBrand, primary: kBrand),
        scaffoldBackgroundColor: const Color(0xFFFBF8F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: kInk,
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Visit {
  Visit(this.when, this.label);
  final DateTime when;
  final String label;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int goal = 10;
  int stamps = 6;
  int rewards = 0;
  int tab = 0;
  final List<Visit> history = [
    Visit(DateTime.now().subtract(const Duration(days: 1)), 'Passage en boutique'),
    Visit(DateTime.now().subtract(const Duration(days: 3)), 'Passage en boutique'),
    Visit(DateTime.now().subtract(const Duration(days: 6)), 'Passage en boutique'),
    Visit(DateTime.now().subtract(const Duration(days: 9)), 'Passage en boutique'),
    Visit(DateTime.now().subtract(const Duration(days: 13)), 'Passage en boutique'),
    Visit(DateTime.now().subtract(const Duration(days: 15)), 'Passage en boutique'),
  ];

  void addStamp() {
    setState(() {
      stamps++;
      history.insert(0, Visit(DateTime.now(), 'Passage en boutique'));
      if (stamps >= goal) {
        stamps = 0;
        rewards++;
        history.insert(0, Visit(DateTime.now(), 'Récompense débloquée 🎁'));
        WidgetsBinding.instance.addPostFrameCallback((_) => _showReward());
      }
    });
  }

  void _showReward() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bravo ! 🎉'),
        content: const Text(
            'Votre carte est complète : un produit offert au prochain passage. Montrez cet écran en caisse.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Super'),
          ),
        ],
      ),
    );
  }

  String fmt(DateTime d) {
    const days = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
    const months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_cardPage(), _offersPage(), _historyPage()];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: kBrand, borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: const Text('V', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            const Text('Votre commerce', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.card_giftcard_outlined), selectedIcon: Icon(Icons.card_giftcard), label: 'Ma carte'),
          NavigationDestination(icon: Icon(Icons.local_offer_outlined), selectedIcon: Icon(Icons.local_offer), label: 'Offres'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
        ],
      ),
    );
  }

  Widget _cardPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kInk, Color(0xFF163A6B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CARTE DE FIDÉLITÉ', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Nadia B.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: List.generate(goal, (i) {
                  final done = i < stamps;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: done ? kBrand : const Color.fromRGBO(255, 255, 255, 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: done ? kBrand : Colors.white24, width: 2),
                    ),
                    child: Icon(i == goal - 1 ? Icons.card_giftcard : Icons.check, color: done ? Colors.white : Colors.white38, size: 20),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text('$stamps / $goal passages · encore ${goal - stamps} pour un produit offert',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: addStamp,
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Simuler un passage en caisse'),
        ),
        const SizedBox(height: 8),
        const Text('En vrai : le commerçant scanne le QR code du client, le tampon est ajouté automatiquement.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 13)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _kpi('$rewards', 'récompense${rewards > 1 ? 's' : ''} gagnée${rewards > 1 ? 's' : ''}')),
            const SizedBox(width: 10),
            Expanded(child: _kpi('${history.length}', 'passages au total')),
          ],
        ),
      ],
    );
  }

  Widget _kpi(String big, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF3EDE2), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(big, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kInk)),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _offersPage() {
    final offers = [
      ('🥐', 'Viennoiserie offerte', 'Pour tout achat avant 9 h, du lundi au vendredi.'),
      ('🎂', '-10 % sur les gâteaux', 'Sur commande, 48 h à l’avance.'),
      ('🎁', 'Carte complète', 'Un produit offert tous les 10 passages.'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2DCCF))),
        child: ListTile(
          leading: Text(offers[i].$1, style: const TextStyle(fontSize: 28)),
          title: Text(offers[i].$2, style: const TextStyle(fontWeight: FontWeight.w800, color: kInk)),
          subtitle: Text(offers[i].$3),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${offers[i].$2} : montrez cet écran en caisse.'))),
        ),
      ),
    );
  }

  Widget _historyPage() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final v = history[i];
        final reward = v.label.contains('Récompense');
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: reward ? kBrand : const Color(0xFFD8F5F0),
            child: Icon(reward ? Icons.card_giftcard : Icons.storefront, color: reward ? Colors.white : const Color(0xFF0D8A7D)),
          ),
          title: Text(v.label, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(fmt(v.when)),
        );
      },
    );
  }
}
