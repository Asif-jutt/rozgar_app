class Applicant {
  String name;
  String role;
  String experience;

  Applicant({
    required this.name,
    required this.role,
    required this.experience,
  });
}

class Job {
  String title;
  String company;
  String type;

  Job({
    required this.title,
    required this.company,
    required this.type,
  });
}

final List<Applicant> applicants = [
  Applicant(name: "Ali Khan", role: "Flutter Developer", experience: "2 Years"),
  Applicant(name: "Sara Ahmed", role: "UI/UX Designer", experience: "3 Years"),
  Applicant(name: "Usman Tariq", role: "Backend Developer", experience: "4 Years"),
  Applicant(name: "Ayesha Malik", role: "React Developer", experience: "1.5 Years"),
];

final List<Job> jobs = [
  Job(title: "Flutter Developer", company: "Tech Solutions", type: "Full Time"),
  Job(title: "Backend Engineer", company: "Cloud Soft", type: "Remote"),
];