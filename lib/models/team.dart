class Team {
  String id;
  String name;
  String? logoPath;

  Team({
    required this.id,
    required this.name,
    this.logoPath,
  });
}