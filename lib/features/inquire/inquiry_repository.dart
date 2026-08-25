import 'package:biconcept_in/content/services.dart';

class Inquiry {
  const Inquiry({
    required this.practice,
    required this.projectType,
    required this.city,
    required this.budgetBand,
    required this.name,
    required this.phone,
    required this.message,
  });

  final PracticeKind practice;
  final String projectType;
  final String city;
  final String budgetBand;
  final String name;
  final String phone;
  final String message;
}

class InquiryRepository {
  Inquiry? last;

  Future<void> submit(Inquiry inquiry) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    last = inquiry;
  }
}
