import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';

void main() {
  runApp(const MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B&G Kurye',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[900],
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      home: const IsletmePaneli(),
    );
  }
}

class IsletmePaneli extends StatefulWidget {
  const IsletmePaneli({Key? key}) : super(key: key);

  @override
  State<IsletmePaneli> createState() => _IsletmePaneliState();
}

class _IsletmePaneliState extends State<IsletmePaneli> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<String> mahalleler = [
    'Gülümbe',
    'Üniversite',
    'Pelitözü',
    'Bahçelievler',
    'Hürriyet',
    'Cumhuriyet',
    'İstiklal',
    'Gazi Paşa',
    'Ertuğrul gazi',
    'İstasyon',
    'Toki',
  ];

  String? selectedMahalle;
  bool showReports = false;

  // Durum renklerini belirle
  Color getStatusColor(String status) {
    switch (status) {
      case 'bekleniyor':
        return Colors.grey;
      case 'onaylandı':
        return Colors.yellow[700]!;
      case 'dağıtımda':
        return Colors.blue;
      case 'teslim_edildi':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Durum metnini Türkçe yap
  String getStatusText(String status) {
    switch (status) {
      case 'bekleniyor':
        return 'Bekleniyor';
      case 'onaylandı':
        return 'Onaylandı';
      case 'dağıtımda':
        return 'Dağıtımda';
      case 'teslim_edildi':
        return 'Teslim Edildi';
      default:
        return status;
    }
  }

  // Durum ikonunu belirle
  IconData getStatusIcon(String status) {
    switch (status) {
      case 'bekleniyor':
        return Icons.hourglass_top;
      case 'onaylandı':
        return Icons.check_circle;
      case 'dağıtımda':
        return Icons.local_shipping;
      case 'teslim_edildi':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'İşletme Paneli',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          leading: const SizedBox.shrink(),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                onPressed: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.refresh, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'Veriler yenilendi',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.blue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                tooltip: 'Yenile',
              ),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFE0F2FE)],
            ),
          ),
          child: Column(
            children: [
              // Üst Bilgi Şeridi - Gerçek Kurye Sayısı
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E3A8A),
                      const Color(0xFF3B82F6),
                      const Color(0xFF60A5FA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getOnlineCouriers(),
                  builder: (context, snapshot) {
                    int onlineKuryeSayisi = 0;
                    if (snapshot.hasData) {
                      onlineKuryeSayisi = snapshot.data!.docs.length;
                    }

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delivery_dining,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aktif Kurye Sayısı',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$onlineKuryeSayisi',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'B&G go\'da aktif kurye var',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Ana İçerik
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mahalleler Listesi - Modern Sidebar
                    Container(
                      width: 280,
                      margin: const EdgeInsets.only(left: 20, bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Mahalleler',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    showReports
                                        ? const Color(0xFFE0F2FE)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    showReports
                                        ? Border.all(
                                          color: const Color(0xFF1E3A8A),
                                          width: 2,
                                        )
                                        : null,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    showReports = true;
                                    selectedMahalle = null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.assessment,
                                        color:
                                            showReports
                                                ? const Color(0xFF1E3A8A)
                                                : Colors.grey[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Raporlar',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight:
                                                showReports
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                            color:
                                                showReports
                                                    ? const Color(0xFF1E3A8A)
                                                    : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color:
                                            showReports
                                                ? const Color(0xFF1E3A8A)
                                                : Colors.grey[400],
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: mahalleler.length,
                              itemBuilder: (context, index) {
                                final mahalle = mahalleler[index];
                                final isSelected = selectedMahalle == mahalle;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? const Color(0xFFE0F2FE)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        isSelected
                                            ? Border.all(
                                              color: const Color(0xFF1E3A8A),
                                              width: 2,
                                            )
                                            : null,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedMahalle = mahalle;
                                        showReports = false;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              mahalle,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w500,
                                                color:
                                                    isSelected
                                                        ? const Color(
                                                          0xFF1E3A8A,
                                                        )
                                                        : Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E3A8A),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  if (currentUser != null &&
                                                      selectedMahalle != null) {
                                                    await _firestoreService
                                                        .createOrder(
                                                          currentUser!.uid,
                                                          selectedMahalle!,
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Text(
                                                              '$selectedMahalle için kurye çağrıldı',
                                                              style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  minimumSize: const Size(
                                                    80,
                                                    32,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Kurye Çağır',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            )
                                          else
                                            Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey[400],
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sağ Taraf İçerik - Modern Kart Tasarımı
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 20, bottom: 20),
                        child: Column(
                          children: [
                            // Üst Kısım - Seçime göre içerik başlığı
                            if (showReports)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1E3A8A,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.assessment,
                                        color: const Color(0xFF1E3A8A),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Raporlar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (selectedMahalle != null)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1E3A8A,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.location_city,
                                        color: const Color(0xFF1E3A8A),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '$selectedMahalle Mahallesi Siparişleri',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20),
                            // İçerik: showReports ise rapor listesi, değilse mahalle akışı
                            Expanded(
                              child:
                                  showReports
                                      ? FutureBuilder<Map<String, dynamic>>(
                                        future: _firestoreService
                                            .getBusinessStats(
                                              currentUser?.uid ?? '',
                                            ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          const Color(
                                                            0xFF1E3A8A,
                                                          ),
                                                        ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Rapor hazırlanıyor...',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.bar_chart_outlined,
                                                    size: 60,
                                                    color: Colors.grey[400],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Rapor verisi bulunamadı',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.grey[600],
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          final stats = snapshot.data!;
                                          final totalPackages =
                                              stats['totalPackages'] ?? 0;
                                          final courierPackages =
                                              stats['courierPackages'] ??
                                              <String, int>{};
                                          return ListView(
                                            padding: const EdgeInsets.all(16),
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.blue
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.local_shipping,
                                                        color: Colors.blue[700],
                                                        size: 24,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Toplam Paket',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '$totalPackages',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors
                                                                      .blue[700],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Kurye Bazlı Paket Sayıları',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF1E3A8A,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              if (courierPackages.isNotEmpty)
                                                ...courierPackages.entries.map((
                                                  entry,
                                                ) {
                                                  final courierId = entry.key;
                                                  final packageCount =
                                                      entry.value;
                                                  return FutureBuilder<String>(
                                                    future: _firestoreService
                                                        .getUserFullName(
                                                          courierId,
                                                        ),
                                                    builder: (
                                                      context,
                                                      nameSnapshot,
                                                    ) {
                                                      final courierName =
                                                          nameSnapshot.data ??
                                                          'Yükleniyor...';
                                                      return Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 8,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green
                                                              .withOpacity(
                                                                0.05,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors.green
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    8,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .green
                                                                    .withOpacity(
                                                                      0.2,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              child: Icon(
                                                                Icons.person,
                                                                color:
                                                                    Colors
                                                                        .green[700],
                                                                size: 16,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    courierName,
                                                                    style: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          13,
                                                                      color:
                                                                          Colors
                                                                              .grey[800],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    '$packageCount paket',
                                                                    style: GoogleFonts.poppins(
                                                                      color:
                                                                          Colors
                                                                              .green[700],
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          11,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }).toList()
                                              else
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Henüz kurye verisi yok',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                            fontSize: 14,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      )
                                      : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          if (selectedMahalle != null)
                                            SizedBox(
                                              height: 200,
                                              child: StreamBuilder<
                                                QuerySnapshot
                                              >(
                                                stream: _firestoreService
                                                    .getBusinessOrdersByNeighborhood(
                                                      currentUser?.uid ?? '',
                                                      selectedMahalle!,
                                                    ),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(
                                                                  const Color(
                                                                    0xFF1E3A8A,
                                                                  ),
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          Text(
                                                            'Siparişler yükleniyor...',
                                                            style: GoogleFonts.poppins(
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  if (!snapshot.hasData ||
                                                      snapshot
                                                          .data!
                                                          .docs
                                                          .isEmpty) {
                                                    return Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .inbox_outlined,
                                                            size: 60,
                                                            color:
                                                                Colors
                                                                    .grey[400],
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          Text(
                                                            'Bu mahallede henüz sipariş bulunmuyor',
                                                            style: GoogleFonts.poppins(
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            'Kurye çağırdığınızda burada görünecek',
                                                            style: GoogleFonts.poppins(
                                                              color:
                                                                  Colors
                                                                      .grey[500],
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  final orders =
                                                      snapshot.data!.docs;
                                                  return ListView.builder(
                                                    itemCount: orders.length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      final order =
                                                          orders[index];
                                                      final data =
                                                          order.data()
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >;
                                                      final status =
                                                          data['status'] ??
                                                          'bekleniyor';
                                                      final courierInfo =
                                                          data['courierInfo']
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >?;
                                                      return Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 12,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              16,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: getStatusColor(
                                                            status,
                                                          ).withOpacity(0.05),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                getStatusColor(
                                                                  status,
                                                                ).withOpacity(
                                                                  0.3,
                                                                ),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        10,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: getStatusColor(
                                                                      status,
                                                                    ).withOpacity(
                                                                      0.1,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                  child: Icon(
                                                                    getStatusIcon(
                                                                      status,
                                                                    ),
                                                                    color:
                                                                        getStatusColor(
                                                                          status,
                                                                        ),
                                                                    size: 20,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 16,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Mahalle: ${data['neighborhood']}',
                                                                        style: GoogleFonts.poppins(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey[800],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            4,
                                                                      ),
                                                                      Text(
                                                                        'Durum: ${getStatusText(status)}',
                                                                        style: GoogleFonts.poppins(
                                                                          color: getStatusColor(
                                                                            status,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            if (courierInfo !=
                                                                    null &&
                                                                status !=
                                                                    'bekleniyor') ...[
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      12,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .blue
                                                                      .withOpacity(
                                                                        0.05,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  border: Border.all(
                                                                    color: Colors
                                                                        .blue
                                                                        .withOpacity(
                                                                          0.2,
                                                                        ),
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Kurye Bilgileri:',
                                                                      style: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            Colors.blue[700],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: Text(
                                                                            'Ad Soyad: ${courierInfo['fullName'] ?? 'Bilinmiyor'}',
                                                                            style: GoogleFonts.poppins(
                                                                              fontSize:
                                                                                  12,
                                                                              color:
                                                                                  Colors.grey[700],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child: Text(
                                                                            'Plaka: ${courierInfo['plateNumber'] ?? 'Bilinmiyor'}',
                                                                            style: GoogleFonts.poppins(
                                                                              fontSize:
                                                                                  12,
                                                                              color:
                                                                                  Colors.grey[700],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      'Telefon: ${courierInfo['phone'] ?? 'Bilinmiyor'}',
                                                                      style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            12,
                                                                        color:
                                                                            Colors.grey[700],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          const SizedBox(height: 20),
                                          // Alt tarafta tamamlanan siparişler
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue
                                                        .withOpacity(0.1),
                                                    spreadRadius: 1,
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFF1E3A8A,
                                                          ).withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.analytics,
                                                          color: const Color(
                                                            0xFF1E3A8A,
                                                          ),
                                                          size: 24,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Text(
                                                        'Tamamlanan Siparişler',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  const Color(
                                                                    0xFF1E3A8A,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Expanded(
                                                    child: StreamBuilder<
                                                      QuerySnapshot
                                                    >(
                                                      stream: _firestoreService
                                                          .getCompletedOrders(
                                                            currentUser?.uid ??
                                                                '',
                                                          ),
                                                      builder: (
                                                        context,
                                                        snapshot,
                                                      ) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                CircularProgressIndicator(
                                                                  valueColor: AlwaysStoppedAnimation<
                                                                    Color
                                                                  >(
                                                                    const Color(
                                                                      0xFF1E3A8A,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 16,
                                                                ),
                                                                Text(
                                                                  'Siparişler yükleniyor...',
                                                                  style: GoogleFonts.poppins(
                                                                    color:
                                                                        Colors
                                                                            .grey[600],
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                        if (!snapshot.hasData ||
                                                            snapshot
                                                                .data!
                                                                .docs
                                                                .isEmpty) {
                                                          return Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .check_circle_outline,
                                                                  size: 60,
                                                                  color:
                                                                      Colors
                                                                          .grey[400],
                                                                ),
                                                                const SizedBox(
                                                                  height: 16,
                                                                ),
                                                                Text(
                                                                  'Henüz tamamlanan sipariş bulunmuyor',
                                                                  style: GoogleFonts.poppins(
                                                                    color:
                                                                        Colors
                                                                            .grey[600],
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Kurye siparişi teslim ettiğinde burada görünecek',
                                                                  style: GoogleFonts.poppins(
                                                                    color:
                                                                        Colors
                                                                            .grey[500],
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                        final orders =
                                                            snapshot.data!.docs;
                                                        return ListView.builder(
                                                          itemCount:
                                                              orders.length,
                                                          itemBuilder: (
                                                            context,
                                                            index,
                                                          ) {
                                                            final order =
                                                                orders[index];
                                                            final data =
                                                                order.data()
                                                                    as Map<
                                                                      String,
                                                                      dynamic
                                                                    >;
                                                            final courierInfo =
                                                                data['courierInfo']
                                                                    as Map<
                                                                      String,
                                                                      dynamic
                                                                    >?;
                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets.only(
                                                                    bottom: 12,
                                                                  ),
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    16,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .green
                                                                    .withOpacity(
                                                                      0.05,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      16,
                                                                    ),
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .green
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              10,
                                                                            ),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.green.withOpacity(
                                                                            0.1,
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                        ),
                                                                        child: const Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          color:
                                                                              Colors.green,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            16,
                                                                      ),
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Mahalle: ${data['neighborhood']}',
                                                                              style: GoogleFonts.poppins(
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                                fontSize:
                                                                                    14,
                                                                                color:
                                                                                    Colors.grey[800],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height:
                                                                                  4,
                                                                            ),
                                                                            Text(
                                                                              'Durum: Teslim Edildi',
                                                                              style: GoogleFonts.poppins(
                                                                                color:
                                                                                    Colors.green,
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                                fontSize:
                                                                                    12,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  if (courierInfo !=
                                                                      null) ...[
                                                                    const SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                            12,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .green
                                                                            .withOpacity(
                                                                              0.05,
                                                                            ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: Colors.green.withOpacity(
                                                                            0.2,
                                                                          ),
                                                                          width:
                                                                              1,
                                                                        ),
                                                                      ),
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'Teslim Eden Kurye:',
                                                                            style: GoogleFonts.poppins(
                                                                              fontWeight:
                                                                                  FontWeight.w600,
                                                                              fontSize:
                                                                                  12,
                                                                              color:
                                                                                  Colors.green[700],
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Ad Soyad: ${courierInfo['fullName'] ?? 'Bilinmiyor'}',
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize:
                                                                                        12,
                                                                                    color:
                                                                                        Colors.grey[700],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'Plaka: ${courierInfo['plateNumber'] ?? 'Bilinmiyor'}',
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize:
                                                                                        12,
                                                                                    color:
                                                                                        Colors.grey[700],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            'Telefon: ${courierInfo['phone'] ?? 'Bilinmiyor'}',
                                                                            style: GoogleFonts.poppins(
                                                                              fontSize:
                                                                                  12,
                                                                              color:
                                                                                  Colors.grey[700],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rapor Bölümü - Sağ Taraf
                    if (MediaQuery.of(context).size.width >= 1000)
                      Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 20, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.assessment,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Raporlar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: FutureBuilder<Map<String, dynamic>>(
                                future: _firestoreService.getBusinessStats(
                                  currentUser?.uid ?? '',
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  const Color(0xFF1E3A8A),
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Rapor hazırlanıyor...',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.bar_chart_outlined,
                                            size: 60,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Rapor verisi bulunamadı',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final stats = snapshot.data!;
                                  final totalPackages =
                                      stats['totalPackages'] ?? 0;
                                  final courierPackages =
                                      stats['courierPackages'] ??
                                      <String, int>{};

                                  return ListView(
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      // Toplam İstatistik
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.local_shipping,
                                                color: Colors.blue[700],
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Toplam Paket',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '$totalPackages',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Kurye Bazlı Rapor
                                      Text(
                                        'Kurye Bazlı Paket Sayıları',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      if (courierPackages.isNotEmpty)
                                        ...courierPackages.entries.map((entry) {
                                          final courierId = entry.key;
                                          final packageCount = entry.value;

                                          return FutureBuilder<String>(
                                            future: _firestoreService
                                                .getUserFullName(courierId),
                                            builder: (context, nameSnapshot) {
                                              final courierName =
                                                  nameSnapshot.data ??
                                                  'Yükleniyor...';

                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.green
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.person,
                                                        color:
                                                            Colors.green[700],
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            courierName,
                                                            style: GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 13,
                                                              color:
                                                                  Colors
                                                                      .grey[800],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            '$packageCount paket',
                                                            style: GoogleFonts.poppins(
                                                              color:
                                                                  Colors
                                                                      .green[700],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        }).toList()
                                      else
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Henüz kurye verisi yok',
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
