class PlatformStatsModel {
  final int totalQueriesPosted;
  final int totalQueriesResolved;
  final int totalResponses;

  PlatformStatsModel({
    required this.totalQueriesPosted,
    required this.totalQueriesResolved,
    required this.totalResponses,
  });

  factory PlatformStatsModel.fromMap(Map<String, dynamic> map) {
    return PlatformStatsModel(
      totalQueriesPosted: int.parse(
        (map['totalQueriesPosted'] ?? 0).toString(),
      ),
      totalQueriesResolved: int.parse(
        (map['totalQueriesResolved'] ?? 0).toString(),
      ),
      totalResponses: int.parse((map['totalResponses'] ?? 0).toString()),
    );
  }
}
