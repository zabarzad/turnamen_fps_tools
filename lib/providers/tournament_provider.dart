import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../services/server_service.dart';

class TournamentProvider with ChangeNotifier {
  List<Team> _teams = [];
  List<Team> get teams => _teams;

  List<MatchData> _matches = [];
  List<MatchData> get matches => _matches;

  void addTeam(Team team) { _teams.add(team); notifyListeners(); }
  void deleteTeam(String id) {
    _teams.removeWhere((t) => t.id == id);
    _matches.removeWhere((m) => m.teamA.id == id || m.teamB.id == id);
    notifyListeners();
  }
  void updateTeamName(String id, String name) {
    final i = _teams.indexWhere((t) => t.id == id);
    if (i != -1) { _teams[i].name = name; notifyListeners(); }
  }
  void updateTeamLogo(String id, String path) {
    final i = _teams.indexWhere((t) => t.id == id);
    if (i != -1) { _teams[i].logoPath = path; notifyListeners(); }
  }

  void createMatch(Team a, Team b) {
    final m = MatchData(id: DateTime.now().toString(), teamA: a, teamB: b);
    _matches.add(m);
    setLiveMatch(m);
    notifyListeners();
  }
  void deleteMatch(String id) { _matches.removeWhere((m) => m.id == id); notifyListeners(); }

  void setLiveMatch(MatchData m) {
    // Memastikan memanggil updateData
    ServerService.updateData(m.teamA.name, m.teamA.logoPath ?? "", m.teamB.name, m.teamB.logoPath ?? "");
    notifyListeners();
  }
}