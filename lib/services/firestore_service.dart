import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(Map<String, dynamic> userData, String userId) async {
    await _db.collection('users').doc(userId).set(userData);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) async {
    return await _db.collection('users').doc(userId).get();
  }

  // Kullanıcı adı ve soyadını al
  Future<String> getUserFullName(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Kurye için adSoyad alanını kullan
        if (userData['rol'] == 'kurye' || userData['userType'] == 'courier') {
          return userData['adSoyad'] ?? 'Bilinmeyen Kurye';
        }

        // İşletme için yetkiliAdSoyad alanını kullan
        if (userData['rol'] == 'isletme' ||
            userData['userType'] == 'business') {
          return userData['yetkiliAdSoyad'] ?? 'Bilinmeyen Yetkili';
        }

        // Fallback - firstName lastName varsa kullan
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          return '$firstName $lastName'.trim();
        }

        // Son çare - adSoyad alanını kullan
        return userData['adSoyad'] ??
            userData['yetkiliAdSoyad'] ??
            'Bilinmeyen Kullanıcı';
      }
      return 'Bilinmeyen Kullanıcı';
    } catch (e) {
      return 'Bilinmeyen Kullanıcı';
    }
  }

  // İşletme adını al
  Future<String> getBusinessName(String businessId) async {
    try {
      final userDoc = await _db.collection('users').doc(businessId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // İşletme adını farklı alanlardan çekmeyi dene
        return userData['isletmeAdi'] ??
            userData['businessName'] ??
            userData['yetkiliAdSoyad'] ??
            userData['firstName'] ??
            'Bilinmeyen İşletme';
      }
      return 'Bilinmeyen İşletme';
    } catch (e) {
      return 'Bilinmeyen İşletme';
    }
  }

  // Tüm kullanıcı bilgilerini al
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create a new order
  Future<void> createOrder(String businessId, String neighborhood) async {
    await _db.collection('orders').add({
      'businessId': businessId,
      'neighborhood': neighborhood,
      'status': 'bekleniyor', // bekleniyor, onaylandı, dağıtımda, teslim_edildi
      'createdAt': FieldValue.serverTimestamp(),
      'courierId': null,
      'courierInfo': null, // kurye bilgileri
      'packageCount': 1, // varsayılan paket sayısı
    });
  }

  // Get all orders for a specific business
  Stream<QuerySnapshot> getBusinessOrders(String businessId) {
    return _db
        .collection('orders')
        .where('businessId', isEqualTo: businessId)
        .snapshots();
  }

  // Get orders for a specific business and neighborhood
  Stream<QuerySnapshot> getBusinessOrdersByNeighborhood(
    String businessId,
    String neighborhood,
  ) {
    return _db
        .collection('orders')
        .where('businessId', isEqualTo: businessId)
        .where('neighborhood', isEqualTo: neighborhood)
        .snapshots();
  }

  // Get completed orders for a business
  Stream<QuerySnapshot> getCompletedOrders(String businessId) {
    return _db
        .collection('orders')
        .where('businessId', isEqualTo: businessId)
        .where('status', isEqualTo: 'teslim_edildi')
        .snapshots();
  }

  // Get all available orders for couriers
  Stream<QuerySnapshot> getAvailableOrders() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'bekleniyor')
        .snapshots();
  }

  // Get orders for a specific courier
  Stream<QuerySnapshot> getCourierOrders(String courierId) {
    return _db
        .collection('orders')
        .where('courierId', isEqualTo: courierId)
        .snapshots();
  }

  // Get courier's completed orders for reporting
  Stream<QuerySnapshot> getCourierCompletedOrders(String courierId) {
    return _db
        .collection('orders')
        .where('courierId', isEqualTo: courierId)
        .where('status', isEqualTo: 'teslim_edildi')
        .snapshots();
  }

  // Get online couriers count
  Stream<QuerySnapshot> getOnlineCouriers() {
    return _db
        .collection('users')
        .where('userType', isEqualTo: 'courier')
        .where('isOnline', isEqualTo: true)
        .snapshots();
  }

  // Kurye durumunu güncelle (giriş/çıkış)
  Future<void> updateCourierOnlineStatus(
    String courierId,
    bool isOnline,
  ) async {
    await _db.collection('users').doc(courierId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Accept an order (kurye siparişi onaylar)
  Future<void> acceptOrder(
    String orderId,
    String courierId,
    Map<String, dynamic> courierInfo,
  ) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'onaylandı',
      'courierId': courierId,
      'courierInfo': courierInfo,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  // Kurye siparişi aldı (dağıtıma başladı)
  Future<void> startDelivery(String orderId) async {
    await _db.collection('orders').doc(orderId).update({'status': 'dağıtımda'});
  }

  // Complete an order
  Future<void> completeOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'teslim_edildi',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update courier online status
  Future<void> updateCourierStatus(String courierId, bool isOnline) async {
    await _db.collection('users').doc(courierId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Get courier statistics
  Future<Map<String, dynamic>> getCourierStats(String courierId) async {
    final completedOrders =
        await _db
            .collection('orders')
            .where('courierId', isEqualTo: courierId)
            .where('status', isEqualTo: 'teslim_edildi')
            .get();

    int totalPackages = 0;
    Map<String, int> businessPackages = {};

    for (var doc in completedOrders.docs) {
      final data = doc.data();
      final packageCount = (data['packageCount'] ?? 1) as int;
      final businessId = data['businessId'];

      totalPackages += packageCount;
      businessPackages[businessId] =
          (businessPackages[businessId] ?? 0) + packageCount;
    }

    return {
      'totalPackages': totalPackages,
      'businessPackages': businessPackages,
      'totalOrders': completedOrders.docs.length,
    };
  }

  // Get business statistics
  Future<Map<String, dynamic>> getBusinessStats(String businessId) async {
    final completedOrders =
        await _db
            .collection('orders')
            .where('businessId', isEqualTo: businessId)
            .where('status', isEqualTo: 'teslim_edildi')
            .get();

    int totalPackages = 0;
    Map<String, int> courierPackages = {};

    for (var doc in completedOrders.docs) {
      final data = doc.data();
      final packageCount = (data['packageCount'] ?? 1) as int;
      final courierId = data['courierId'];

      totalPackages += packageCount;
      if (courierId != null) {
        courierPackages[courierId] =
            (courierPackages[courierId] ?? 0) + packageCount;
      }
    }

    return {
      'totalPackages': totalPackages,
      'courierPackages': courierPackages,
      'totalOrders': completedOrders.docs.length,
    };
  }
}
