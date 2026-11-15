import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models.dart';

Future<String> createRequestInFirestore(RequestDraft d,
    {String? code, List<String> invitedProviders = const []}) async {
  
  final user = FirebaseAuth.instance.currentUser!;
  final ref = await FirebaseFirestore.instance.collection('requests').add({
    'code': code,                        // مثلاً HE-2051 لربطه بشاشة التأكيد
    'serviceId': d.service.id,           // plumber ... نفس id اللي المختص اختاره
    'description': d.description,
    'city': d.location,
    'address': d.location,
    'urgency': d.urgency.name,
    'emergency': d.emergency,
    'scheduledAt': Timestamp.fromDate(d.when),
    'status': 'open',                    // لازم 'open' عشان تظهر للمختصين
    'invitedProviders': invitedProviders, // المختصين الحقيقيين اللي العميل اختارهم
    'customerId': user.uid,              // القواعد بتشترط إنه يساوي uid العميل
    'createdAt': FieldValue.serverTimestamp(),
  });
  return ref.id;
  
}
