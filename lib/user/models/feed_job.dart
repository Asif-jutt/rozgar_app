import 'package:rozgar/core/app_images.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/models/remote_job.dart';

enum JobFeedSource { local, api }

/// Unified job item for displaying Firestore and REST API jobs with the same UI.
class FeedJob {
  final JobFeedSource source;
  final JobModel? localJob;
  final RemoteJob? remoteJob;

  const FeedJob._({
    required this.source,
    this.localJob,
    this.remoteJob,
  });

  factory FeedJob.local(JobModel job) =>
      FeedJob._(source: JobFeedSource.local, localJob: job);

  factory FeedJob.api(RemoteJob job) =>
      FeedJob._(source: JobFeedSource.api, remoteJob: job);

  String get id => source == JobFeedSource.local
      ? localJob!.jobId
      : 'api_${remoteJob!.id}';

  String get title => source == JobFeedSource.local
      ? localJob!.title
      : remoteJob!.title;

  String get companyName => source == JobFeedSource.local
      ? (localJob!.companyName ?? 'Company')
      : remoteJob!.company;

  String get location => source == JobFeedSource.local
      ? localJob!.location
      : remoteJob!.location;

  String get salary => source == JobFeedSource.local
      ? localJob!.salary
      : remoteJob!.salary;

  String get category => source == JobFeedSource.local
      ? localJob!.category
      : remoteJob!.category;

  String? get imageUrl => source == JobFeedSource.local
      ? localJob!.imageUrl
      : remoteJob!.imageUrl;

  String get description => source == JobFeedSource.local
      ? localJob!.description
      : remoteJob!.description;

  List<String> get requirementList => source == JobFeedSource.local
      ? localJob!.requirementList
      : remoteJob!.tags;

  String? get companyId =>
      source == JobFeedSource.local ? localJob!.companyId : null;

  String? get externalUrl =>
      source == JobFeedSource.api ? remoteJob!.url : null;

  bool get isLocal => source == JobFeedSource.local;
  bool get isApi => source == JobFeedSource.api;

  String get sourceLabel => isLocal ? 'Rozgar' : 'API';

  JobModel toJobModel() {
    if (localJob != null) return localJob!;
    final r = remoteJob!;
    return JobModel(
      jobId: id,
      companyId: '',
      title: r.title,
      description: r.description,
      salary: r.salary,
      location: r.location,
      requirements: r.tags.join(', '),
      category: r.category,
      companyName: r.company,
      imageUrl: r.imageUrl ?? AppImages.jobImageForCategory(r.category),
      postedAt: DateTime.now(),
    );
  }
}
