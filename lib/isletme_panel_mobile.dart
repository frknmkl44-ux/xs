import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';
import 'services/auth_service.dart';

class IsletmePaneliMobile extends StatefulWidget {
  const IsletmePaneliMobile({Key? key}) : super(key: key);

  @override
  State<IsletmePaneliMobile> createState() => _IsletmePaneliMobileState();
}

class _IsletmePaneliMobileState extends State<IsletmePaneliMobile>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final List<String> _mahalleler = const [
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

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'bekleniyor':
        return Colors.grey;
      case 'onaylandı':
        return Colors.orange[700]!;
      case 'dağıtımda':
        return Colors.blue[700]!;
      case 'teslim_edildi':
        return Colors.green[700]!;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
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

  IconData _getStatusIcon(String status) {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'İşletme Paneli',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().signOut();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            tooltip: 'Çıkış Yap',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.add_location_alt), text: 'Kurye Çağır'),
            Tab(icon: Icon(Icons.list_alt), text: 'Siparişler'),
            Tab(icon: Icon(Icons.assessment), text: 'Raporlar'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[900]!, Colors.blue[700]!, Colors.blue[500]!],
          ),
        ),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildKuryeCagirTab(),
              _buildSiparislerTab(),
              _buildRaporlarTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKuryeCagirTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Aktif kurye sayısı kartı
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getOnlineCouriers(),
            builder: (context, snapshot) {
              final onlineCount = snapshot.data?.docs.length ?? 0;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktif Kurye Sayısı',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$onlineCount',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
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
        const SizedBox(height: 16),
        Text(
          'Mahalle seçin ve kurye çağırın',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _mahalleler.map((m) => _buildMahalleChip(m)).toList(),
        ),
      ],
    );
  }

  Widget _buildMahalleChip(String mahalle) {
    return ActionChip(
      backgroundColor: Colors.white,
      elevation: 2,
      avatar: Icon(Icons.location_on, color: Colors.blue[700], size: 18),
      label: Text(
        mahalle,
        style: GoogleFonts.poppins(
          color: Colors.grey[800],
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      onPressed: () async {
        if (_currentUser == null) return;
        await _firestoreService.createOrder(_currentUser.uid, mahalle);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '$mahalle için kurye çağrıldı',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSiparislerTab() {
    if (_currentUser == null) {
      return Center(
        child: Text(
          'Lütfen giriş yapın.',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getBusinessOrders(_currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, color: Colors.white54, size: 64),
                const SizedBox(height: 12),
                Text(
                  'Henüz sipariş yok',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        final List<QueryDocumentSnapshot> orders = snapshot.data!.docs.toList();
        orders.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp?;
          final bTime = bData['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final data = orders[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'bekleniyor';
            final courierInfo = data['courierInfo'] as Map<String, dynamic>?;
            final neighborhood = data['neighborhood'] ?? 'Bilinmeyen';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              neighborhood,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getStatusText(status),
                              style: GoogleFonts.poppins(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (courierInfo != null && status != 'bekleniyor') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kurye Bilgileri',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Ad Soyad: ${courierInfo['fullName'] ?? 'Bilinmiyor'}',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Plaka: ${courierInfo['plateNumber'] ?? 'Bilinmiyor'}',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Telefon: ${courierInfo['phone'] ?? 'Bilinmiyor'}',
                            style: GoogleFonts.poppins(fontSize: 12),
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
    );
  }

  Widget _buildRaporlarTab() {
    if (_currentUser == null) {
      return Center(
        child: Text(
          'Lütfen giriş yapın.',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _firestoreService.getBusinessStats(_currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'Rapor verisi bulunamadı',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          );
        }

        final stats = snapshot.data!;
        final totalPackages = stats['totalPackages'] ?? 0;
        final courierPackages =
            (stats['courierPackages'] ?? <String, int>{}) as Map<String, int>;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toplam Bıraktığınız Paket',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalPackages',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
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
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            if (courierPackages.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Center(
                  child: Text(
                    'Henüz kurye verisi yok',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ),
              )
            else
              ...courierPackages.entries.map((entry) {
                final courierId = entry.key;
                final packageCount = entry.value;
                return FutureBuilder<String>(
                  future: _firestoreService.getUserFullName(courierId),
                  builder: (context, nameSnap) {
                    final name = nameSnap.data ?? 'Yükleniyor...';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Paket Sayısı: $packageCount',
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
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
              }).toList(),
          ],
        );
      },
    );
  }
}
