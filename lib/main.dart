import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'providers/tournament_provider.dart';
import 'models/team.dart';
import 'services/server_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServerService.startServer();
  runApp(
    ChangeNotifierProvider(
      create: (c) => TournamentProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF330000),
        fontFamily: 'TacticoFont', // Harus sama dengan family di pubspec
      ),
      home: const ControlPanelScreen(),
    );
  }
}

class ControlPanelScreen extends StatelessWidget {
  const ControlPanelScreen({super.key});

  // Fungsi Box Link Abu-abu untuk di-copy
  Widget _buildLinkBox(BuildContext context, String label, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label : $url",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.black, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Link Tersalin!")));
            },
          ),
        ],
      ),
    );
  }

  // Dialog Pilih Tim Manual
  void _showMatchDialog(BuildContext context, TournamentProvider p) {
    Team? t1, t2;
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text("Pilih Tim Tanding"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<Team>(
                value: t1,
                hint: const Text("Pilih Tim 1"),
                isExpanded: true,
                items: p.teams
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setState(() => t1 = v),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "VS",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButton<Team>(
                value: t2,
                hint: const Text("Pilih Tim 2"),
                isExpanded: true,
                items: p.teams
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setState(() => t2 = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: (t1 != null && t2 != null && t1 != t2)
                  ? () {
                      p.createMatch(t1!, t2!);
                      Navigator.pop(c);
                    }
                  : null,
              child: const Text("Buat"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<TournamentProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("TOOLS TURNAMEN FPS"),
        backgroundColor: Colors.black,
      ),
      body: Row(
        children: [
          // KIRI: DAFTAR TIM
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => p.addTeam(
                      Team(id: DateTime.now().toString(), name: "Nama Tim"),
                    ),
                    child: const Text("Tambah Tim"),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: p.teams.length,
                      itemBuilder: (c, i) => Card(
                        child: ListTile(
                          leading: InkWell(
                            onTap: () async {
                              var res = await FilePicker.platform.pickFiles(
                                type: FileType.image,
                              );
                              if (res != null)
                                p.updateTeamLogo(
                                  p.teams[i].id,
                                  res.files.single.path!,
                                );
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              backgroundImage: p.teams[i].logoPath != null
                                  ? FileImage(File(p.teams[i].logoPath!))
                                  : null,
                              child: p.teams[i].logoPath == null
                                  ? const Icon(Icons.add_a_photo, size: 20)
                                  : null,
                            ),
                          ),
                          title: TextField(
                            onChanged: (v) =>
                                p.updateTeamName(p.teams[i].id, v),
                            decoration: InputDecoration(
                              hintText: p.teams[i].name,
                              border: InputBorder.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => p.deleteTeam(p.teams[i].id),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // KANAN: MATCH & LINK OBS
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: p.teams.length >= 2
                        ? () => _showMatchDialog(context, p)
                        : null,
                    child: const Text("Buat Jadwal Manual"),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: p.matches.length,
                      itemBuilder: (c, i) => Card(
                        child: ListTile(
                          onTap: () => p.setLiveMatch(p.matches[i]),
                          title: Text(
                            "${p.matches[i].teamA.name} VS ${p.matches[i].teamB.name}",
                          ),
                          subtitle: const Text(
                            "Klik untuk aktifkan link OBS",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => p.deleteMatch(p.matches[i].id),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 30),
                  const Text(
                    "SALIN LINK UNTUK OBS",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLinkBox(
                    context,
                    "Url Team 1",
                    "http://localhost:8080/logo1",
                  ),
                  _buildLinkBox(
                    context,
                    "Url Nama 1",
                    "http://localhost:8080/name1.html",
                  ),
                  _buildLinkBox(
                    context,
                    "Url Team 2",
                    "http://localhost:8080/logo2",
                  ),
                  _buildLinkBox(
                    context,
                    "Url Nama 2",
                    "http://localhost:8080/name2.html",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
