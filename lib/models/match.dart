import 'team.dart';

class MatchData {
  String id;
  Team teamA;
  Team teamB;
  int scoreA;
  int scoreB;
  String status; // Contoh: 'Segera Mulai', 'Live', 'Selesai'

  MatchData({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.scoreA = 0,
    this.scoreB = 0,
    this.status = 'Segera Mulai',
  });
}