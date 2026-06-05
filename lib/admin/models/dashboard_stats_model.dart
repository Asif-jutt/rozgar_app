class DashboardStatsModel {
  final int totalUsers;
  final int totalJobs;
  final int totalApplications;
  final int pendingJobs;
  final int bannedUsers;
  final int reportsCount;
  final List<int> weeklySignups;
  final List<int> weeklyApplications;

  const DashboardStatsModel({
    this.totalUsers = 0,
    this.totalJobs = 0,
    this.totalApplications = 0,
    this.pendingJobs = 0,
    this.bannedUsers = 0,
    this.reportsCount = 0,
    this.weeklySignups = const [0, 0, 0, 0, 0, 0, 0],
    this.weeklyApplications = const [0, 0, 0, 0, 0, 0, 0],
  });

  factory DashboardStatsModel.empty() => const DashboardStatsModel();

  factory DashboardStatsModel.fromMap(Map<String, dynamic> d) {
    return DashboardStatsModel(
      totalUsers: d['totalUsers'] as int? ?? 0,
      totalJobs: d['totalJobs'] as int? ?? 0,
      totalApplications: d['totalApplications'] as int? ?? 0,
      pendingJobs: d['pendingJobs'] as int? ?? 0,
      bannedUsers: d['bannedUsers'] as int? ?? 0,
      reportsCount: d['reportsCount'] as int? ?? 0,
      weeklySignups: List<int>.from(d['weeklySignups'] ?? List.filled(7, 0)),
      weeklyApplications:
          List<int>.from(d['weeklyApplications'] ?? List.filled(7, 0)),
    );
  }
}
