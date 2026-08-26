import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/data/repositories.dart';

class Inquiry {
  const Inquiry({
    required this.practice,
    required this.projectType,
    required this.city,
    required this.sector,
    required this.budgetBand,
    required this.name,
    required this.phone,
    required this.email,
    required this.message,
    this.listingId = '',
    this.offer = '',
  });

  final PracticeKind practice;
  final String projectType;
  final String city;
  final String sector;
  final String budgetBand;
  final String name;
  final String phone;
  final String email;
  final String message;
  final String listingId;
  final String offer;
}

class InquiryRepository {
  InquiryRepository({LeadsRepository? leads}) : _leads = leads ?? LeadsRepository();

  final LeadsRepository _leads;
  Inquiry? last;

  Future<void> submit(Inquiry inquiry) async {
    last = inquiry;
    await _leads.submitInquiry(
      name: inquiry.name,
      phone: inquiry.phone,
      email: inquiry.email,
      city: inquiry.city,
      sector: inquiry.sector,
      practice: inquiry.practice.slug,
      projectType: inquiry.projectType,
      budgetBand: inquiry.budgetBand,
      message: inquiry.message,
      listingId: inquiry.listingId,
      offer: inquiry.offer,
    );
  }
}
