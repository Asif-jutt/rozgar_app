class AppImages {
  static const defaultAvatar =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop';
  static const defaultCompany =
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=200&h=200&fit=crop';
  static const defaultJob =
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=300&fit=crop';
  static const emptyJobs =
      'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400&h=300&fit=crop';

  static String jobImageForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'tech':
      case 'technology':
        return 'https://images.unsplash.com/photo-1517694712202-14dd9538a880?w=600&h=300&fit=crop';
      case 'design':
        return 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=600&h=300&fit=crop';
      case 'marketing':
        return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600&h=300&fit=crop';
      case 'remote':
        return 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=600&h=300&fit=crop';
      default:
        return defaultJob;
    }
  }
}
