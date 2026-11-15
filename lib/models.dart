import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:homeease/l10n.dart';


/// التاب الحالي في الشريط السفلي (0 الرئيسية، 1 طلباتي، 2 المساعد، 3 منزلي، 4 حسابي)
final ValueNotifier<int> shellTab = ValueNotifier<int>(0);

class ServiceItem {
  final String id, ar, en;
  // final IconData icon;
  final String icon ;
  final bool maintenance;
  const ServiceItem(this.id, this.ar, this.en, this.icon , this.maintenance);
  String get name => tr(ar, en);
}

class EmergencyType {
  final String id, ar, en, serviceId, tipAr, tipEn;
  final IconData icon;
  const EmergencyType(this.id, this.ar, this.en, this.icon, this.serviceId,
      this.tipAr, this.tipEn);
  String get name => tr(ar, en);
  String get tip => tr(tipAr, tipEn);
}

class Technician {
  final String id, nameAr, nameEn, serviceId;
  final double rating, distanceKm;
  final int jobs, years, priceFrom, etaMin;
  final bool available;
  final List<String> tagsAr, tagsEn;
  final Color color;

  const Technician(
    this.id,
    this.nameAr,
    this.nameEn,
    this.serviceId,
    this.rating,
    this.jobs,
    this.years,
    this.priceFrom,
    this.etaMin,
    this.distanceKm,
    this.available,
    this.tagsAr,
    this.tagsEn,
    this.color, {
    this.isReal = false,
  });

  /// true = مختص حقيقي مسجّل في Firestore (مش من القائمة الوهمية)
  final bool isReal;

  /// بيحوّل document من collection `users` لفني يظهر في القائمة
  factory Technician.fromUser(
      String uid, Map<String, dynamic> d, String serviceId) {
    const yearsMap = {'lt1': 1, '1-3': 2, '3-5': 4, '5-10': 7, '10+': 10};
    final email = (d['email'] as String?) ?? '';
    var name = ((d['name'] as String?) ?? '').trim();
    if (name.isEmpty) name = email.contains('@') ? email.split('@').first : 'Provider';
    return Technician(
      uid,
      name,
      name,
      serviceId,
      0,
      0,
      yearsMap[d['experienceYears']] ?? 0,
      0,
      0,
      0,
      true,
      const [],
      const [],
      const Color(0xFFC8643C),
      isReal: true,
    );
  }

  String get name => tr(nameAr, nameEn);
  List<String> get tags => Lang.ar ? tagsAr : tagsEn;
  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    return parts.take(2).map((p) => p[0]).join();
  }
}

enum Urgency { urgent, today, scheduled }

String urgencyLabel(Urgency u) {
  switch (u) {
    case Urgency.urgent:
      return tr('عاجل', 'Urgent');
    case Urgency.today:
      return tr('اليوم', 'Today');
    case Urgency.scheduled:
      return tr('مجدول', 'Scheduled');
  }
}

/// بيانات الطلب قبل اختيار الفنيين
class RequestDraft {
  final String? id;
  final ServiceItem service;
  final String description, location;
  final Urgency urgency;
  final DateTime when;
  final Uint8List? image;
  final bool emergency;

  const RequestDraft({
    this.id,
    required this.service,
    required this.description,
    required this.location,
    required this.urgency,
    required this.when,
    this.image,
    this.emergency = false,
  });
}

class ServiceRequest {
  final String id;
  final RequestDraft draft;
  final List<Technician> technicians;
  final DateTime createdAt;
  final Set<String> accepted = {};

  ServiceRequest({
    required this.id,
    required this.draft,
    required this.technicians,
  }) : createdAt = DateTime.now();
}

/// تخزين الطلبات في الذاكرة (تجريبي) + محاكاة ردّ الفنيين.
class RequestStore {
  static final ValueNotifier<List<ServiceRequest>> requests =
      ValueNotifier<List<ServiceRequest>>([]);
  static int _counter = 2050;

  static String nextId() => 'HE-${++_counter}';

  static void add(ServiceRequest r) {
    requests.value = [r, ...requests.value];
    // محاكاة: أول فنيين يقبلوا الطلب بعد ثواني
    final pool = r.technicians.where((t) => t.available && !t.isReal).toList();
    for (var i = 0; i < pool.length && i < 2; i++) {
      final tech = pool[i];
      Timer(Duration(seconds: 4 + i * 5), () {
        r.accepted.add(tech.id);
        touch();
      });
    }
  }

  static void touch() => requests.value = List.of(requests.value);
}
