import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';

String get kDefaultAddress =>
    tr('المنزل · 12 شارع 9، المعادي', 'Home · 12 Street 9, Maadi');

const kServices = <ServiceItem>[

  ServiceItem('plumber', 'سبّاك', 'Plumber', "assets/icons/plumber.png", true),
  ServiceItem('electrician', 'كهربائي', 'Electrician', "assets/icons/electrician.png", true),
  ServiceItem('carpenter', 'نجّار', 'Carpenter', "assets/icons/carpenter.png", true),
  ServiceItem('ac', 'فني تكييف', 'AC Technician', "assets/icons/ac-repair.png", true),
  ServiceItem('painter', 'نقّاش', 'Painter', "assets/icons/paint-roller.png", true),

  ServiceItem('cleaning', 'تنظيف المنزل', 'House Cleaning',
      "assets/icons/cleaning.png", false),
  ServiceItem(
      'laundry', 'غسيل', 'Laundry', "assets/icons/laundry.png", false),
  ServiceItem('ironing', 'كي', 'Ironing', "assets/icons/ironing.png", false),
  ServiceItem('cooking', 'طبخ', 'Cooking', "assets/icons/cooking.png", false),
  ServiceItem('babysitting', 'رعاية أطفال', 'Babysitting', "assets/icons/babysitter.png",
      false),
  ServiceItem('petcare', 'رعاية حيوانات', 'Pet Care', "assets/icons/pet-care.png", false),
];

ServiceItem serviceById(String id) =>
    kServices.firstWhere((s) => s.id == id, orElse: () => kServices.first);

const kEmergencyTypes = <EmergencyType>[
  EmergencyType(
    'leak',
    'تسريب مياه شديد',
    'Severe water leak',
    Icons.water_drop_outlined,
    'plumber',
    'أغلق محبس المياه الرئيسي إن كان آمناً. ابتعد قرب المقابس، ولا تلمس مفاتيح الكهرباء في المناطق المبتلة.',
    'Close the main water valve if it is safe. Stay away from sockets and do not touch switches in wet areas.',
  ),
  EmergencyType(
    'electric',
    'عطل كهربائي',
    'Electrical fault',
    Icons.bolt,
    'electrician',
    'أوقف القاطع الرئيسي إن كان الوصول إليه آمناً. لا تلمس الأسلاك المكشوفة أو الأجهزة المبتلة.',
    'Switch off the main breaker if it is safe to reach. Do not touch exposed wires or wet appliances.',
  ),
  EmergencyType(
    'locked',
    'باب مغلق دون مفتاح',
    'Locked out of the door',
    Icons.key_off_outlined,
    'carpenter',
    'ابقَ في مكان آمن ولا تحاول كسر الباب أو الأقفال بنفسك. سيصلك مختص معتمد.',
    'Stay somewhere safe and do not try to force the door or lock yourself. A certified pro will come to you.',
  ),
  EmergencyType(
    'ac',
    'حالة تكييف طارئة',
    'Urgent AC problem',
    Icons.ac_unit,
    'ac',
    'أطفئ الجهاز وافصل الكهرباء عنه. لا تفتح الأجزاء الداخلية، وابتعد عن أي تسريب أو رائحة احتراق.',
    'Turn the unit off and cut its power. Do not open internal parts, and keep away from any leak or burning smell.',
  ),
];

const _blue = Color(0xFF3F6C8A);
const _teal = Color(0xFF2F7F79);
const _plum = Color(0xFF7A4B7A);
const _brown = Color(0xFF8A5A3C);
const _olive = Color(0xFF6B7A3A);
const _rose = Color(0xFFB05468);
const _slate = Color(0xFF4A5A73);


const kTechnicians = <Technician>[
  // سباكين
  Technician('p1', 'أحمد المصري', 'Ahmed El-Masry', 'plumber', 4.9, 312, 9, 150, 20, 1.8, true, ['تسريب مياه', 'خلاطات'], ['Leaks', 'Mixers'], _blue),
  Technician('p2', 'محمود سعيد', 'Mahmoud Saeed', 'plumber', 4.8, 241, 7, 120, 25, 2.6, true, ['صرف وسدّات', 'سخانات'], ['Drains', 'Heaters'], _teal),
  Technician('p3', 'كريم عادل', 'Karim Adel', 'plumber', 4.6, 128, 4, 100, 40, 4.2, true, ['تمديدات', 'حمامات'], ['Piping', 'Bathrooms'], _plum),
  Technician('p4', 'سيد عبد الرحمن', 'Sayed Abdelrahman', 'plumber', 4.7, 190, 12, 180, 55, 6.0, false, ['طوارئ 24 ساعة'], ['24h emergency'], _brown),
  // كهربائيين
  Technician('e1', 'ياسر فتحي', 'Yasser Fathy', 'electrician', 4.9, 405, 11, 150, 25, 2.0, true, ['أعطال كهرباء', 'قواطع'], ['Faults', 'Breakers'], _slate),
  Technician('e2', 'هاني رمزي', 'Hany Ramzy', 'electrician', 4.7, 220, 8, 130, 30, 3.1, true, ['إنارة', 'فيشات'], ['Lighting', 'Sockets'], _olive),
  Technician('e3', 'سامح نبيل', 'Sameh Nabil', 'electrician', 4.5, 97, 3, 100, 45, 5.2, true, ['تمديدات', 'لوحات'], ['Wiring', 'Panels'], _rose),
  // نجارين
  Technician('c1', 'عمرو حسن', 'Amr Hassan', 'carpenter', 4.8, 260, 10, 200, 35, 3.0, true, ['أبواب وأقفال', 'دواليب'], ['Doors & locks', 'Wardrobes'], _brown),
  Technician('c2', 'طارق علي', 'Tarek Ali', 'carpenter', 4.6, 150, 6, 160, 30, 2.4, true, ['تفصيل وتركيب', 'إصلاح أثاث'], ['Custom builds', 'Furniture repair'], _blue),
  Technician('c3', 'رضا منصور', 'Reda Mansour', 'carpenter', 4.4, 80, 3, 140, 50, 6.5, false, ['مطابخ', 'أبواب'], ['Kitchens', 'Doors'], _teal),
  // تكييف
  Technician('a1', 'مصطفى جمال', 'Mostafa Gamal', 'ac', 4.9, 530, 10, 200, 25, 2.2, true, ['صيانة وتنظيف', 'شحن فريون'], ['Service & cleaning', 'Gas refill'], _teal),
  Technician('a2', 'إسلام خالد', 'Islam Khaled', 'ac', 4.7, 310, 6, 170, 30, 3.4, true, ['تركيب', 'أعطال'], ['Installation', 'Repairs'], _slate),
  Technician('a3', 'وليد شريف', 'Walid Sherif', 'ac', 4.5, 140, 4, 150, 45, 5.0, true, ['سبليت', 'مركزي'], ['Split units', 'Central'], _plum),
  // نقاشين
  Technician('d1', 'إبراهيم رشدي', 'Ibrahim Roshdy', 'painter', 4.8, 175, 13, 300, 60, 3.7, true, ['دهانات داخلية', 'ورق حائط'], ['Interior paint', 'Wallpaper'], _olive),
  Technician('d2', 'ماجد عبد الله', 'Maged Abdullah', 'painter', 4.6, 96, 7, 250, 70, 5.8, true, ['ترميم جدران', 'ديكورات'], ['Wall repair', 'Decor'], _rose),
  // تنظيف
  Technician('l1', 'منى السيد', 'Mona El-Sayed', 'cleaning', 4.9, 380, 5, 250, 90, 3.3, true, ['تنظيف شامل', 'بعد التشطيب'], ['Deep cleaning', 'Post-renovation'], _rose),
  Technician('l2', 'هالة فؤاد', 'Hala Fouad', 'cleaning', 4.7, 210, 4, 200, 120, 4.4, true, ['تنظيف دوري', 'مطابخ'], ['Regular cleaning', 'Kitchens'], _teal),
  // غسيل
  Technician('w1', 'نادر صلاح', 'Nader Salah', 'laundry', 4.6, 150, 5, 80, 60, 2.8, true, ['غسيل وكي', 'استلام وتسليم'], ['Wash & iron', 'Pickup & delivery'], _blue),
  Technician('w2', 'فاطمة جلال', 'Fatma Galal', 'laundry', 4.5, 90, 3, 70, 90, 4.0, true, ['غسيل بالوزن', 'بطاطين'], ['Wash by weight', 'Blankets'], _plum),
  // كي
  Technician('i1', 'سعاد محمد', 'Soad Mohamed', 'ironing', 4.7, 200, 8, 60, 60, 2.0, true, ['كي ملابس', 'ستائر'], ['Ironing', 'Curtains'], _brown),
  Technician('i2', 'رشا ممدوح', 'Rasha Mamdouh', 'ironing', 4.5, 70, 2, 50, 75, 3.5, true, ['كي سريع'], ['Express ironing'], _olive),
  // طبخ
  Technician('k1', 'ليلى حسين', 'Layla Hussein', 'cooking', 4.9, 160, 9, 300, 120, 3.9, true, ['مأكولات مصرية', 'وجبات أسبوعية'], ['Egyptian cuisine', 'Weekly meals'], _rose),
  Technician('k2', 'عادل زكي', 'Adel Zaki', 'cooking', 4.6, 85, 6, 350, 150, 5.1, true, ['مشويات', 'حفلات صغيرة'], ['Grills', 'Small parties'], _slate),
  // رعاية أطفال
  Technician('b1', 'ندى أشرف', 'Nada Ashraf', 'babysitting', 4.9, 140, 5, 120, 90, 2.9, true, ['رعاية أطفال', 'مساعدة في المذاكرة'], ['Childcare', 'Homework help'], _teal),
  Technician('b2', 'دينا سمير', 'Dina Samir', 'babysitting', 4.6, 70, 3, 100, 120, 4.6, true, ['رعاية رضّع', 'أنشطة'], ['Infant care', 'Activities'], _plum),
  // رعاية حيوانات
  Technician('pc1', 'يوسف طارق', 'Youssef Tarek', 'petcare', 4.8, 120, 4, 100, 60, 3.2, true, ['تمشية وتغذية', 'استحمام'], ['Walking & feeding', 'Grooming'], _olive),
  Technician('pc2', 'مريم وائل', 'Mariam Wael', 'petcare', 4.7, 95, 3, 90, 80, 4.1, true, ['رعاية منزلية', 'قطط'], ['Home care', 'Cats'], _blue),
];

List<Technician> techniciansFor(String serviceId) =>
    kTechnicians.where((t) => t.serviceId == serviceId).toList();
