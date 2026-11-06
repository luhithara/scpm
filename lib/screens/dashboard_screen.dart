import 'package:flutter/material.dart';
import 'feature_screen.dart';

const Color scpNavy = Color(0xFF172B4D);
const Color scpBlue = Color(0xFF3268B2);
const Color scpBackground = Color(0xFFF4F6FA);
const Color scpText = Color(0xFF26354D);
const Color scpMuted = Color(0xFF778397);
const Color scpBorder = Color(0xFFE7ECF3);

class DashboardScreen extends StatefulWidget {
  final String initialRole;

  const DashboardScreen({
    super.key,
    this.initialRole = 'waka',
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _selectedRole;
  int _selectedTab = 0;

  final List<Map<String, String>> _roles = [
    {'id': 'siswa', 'label': 'Siswa'},
    {'id': 'orangtua', 'label': 'Orang Tua'},
    {'id': 'guru', 'label': 'Guru'},
    {'id': 'bk', 'label': 'BK'},
    {'id': 'waka', 'label': 'Waka'},
    {'id': 'kelas', 'label': 'Akun Kelas'},
  ];

  @override
  void initState() {
    super.initState();

    final roleExists = _roles.any(
      (role) => role['id'] == widget.initialRole,
    );

    _selectedRole = roleExists ? widget.initialRole : 'waka';
  }

  String get _roleName {
    return _roles.firstWhere(
      (role) => role['id'] == _selectedRole,
      orElse: () => {'id': 'waka', 'label': 'Waka'},
    )['label']!;
  }

  String get _greeting {
    switch (_selectedRole) {
      case 'siswa':
        return 'Halo, Siswa!';
      case 'orangtua':
        return 'Selamat Datang!';
      case 'guru':
        return 'Halo, Bapak/Ibu Guru!';
      case 'bk':
        return 'Dashboard BK';
      case 'waka':
        return 'Dashboard Waka';
      case 'kelas':
        return 'Dashboard Kelas';
      default:
        return 'Selamat Datang!';
    }
  }

  String get _description {
    switch (_selectedRole) {
      case 'siswa':
        return 'Pantau jadwal dan kehadiranmu hari ini.';
      case 'orangtua':
        return 'Pantau kegiatan dan kehadiran anak.';
      case 'guru':
        return 'Kelola jadwal dan jurnal mengajar.';
      case 'bk':
        return 'Pantau kehadiran dan tindak lanjut siswa.';
      case 'waka':
        return 'Pantau aktivitas akademik sekolah.';
      case 'kelas':
        return 'Lihat informasi dan kegiatan kelas.';
      default:
        return 'Kelola informasi sekolah dengan mudah.';
    }
  }

  List<_DashboardStat> get _stats {
    switch (_selectedRole) {
      case 'siswa':
        return [
          _DashboardStat(
            'Jadwal Hari Ini',
            '4',
            Icons.calendar_month_outlined,
            scpBlue,
          ),
          _DashboardStat(
            'Kehadiran',
            '96%',
            Icons.fact_check_outlined,
            const Color(0xFF259B83),
          ),
        ];

      case 'orangtua':
        return [
          _DashboardStat(
            'Jadwal Anak',
            '4',
            Icons.calendar_month_outlined,
            scpBlue,
          ),
          _DashboardStat(
            'Kehadiran Anak',
            '96%',
            Icons.family_restroom_outlined,
            const Color(0xFF259B83),
          ),
        ];

      case 'guru':
        return [
          _DashboardStat(
            'Jadwal Mengajar',
            '4',
            Icons.calendar_month_outlined,
            scpBlue,
          ),
          _DashboardStat(
            'Jurnal Hari Ini',
            '3/4',
            Icons.menu_book_outlined,
            const Color(0xFF259B83),
          ),
        ];

      case 'bk':
        return [
          _DashboardStat(
            'Perlu Ditangani',
            '8',
            Icons.assignment_late_outlined,
            const Color(0xFFE39A36),
          ),
          _DashboardStat(
            'Pengajuan Izin',
            '5',
            Icons.fact_check_outlined,
            scpBlue,
          ),
        ];

      case 'waka':
        return [
          _DashboardStat(
            'Total Siswa',
            '320',
            Icons.people_alt_outlined,
            scpBlue,
          ),
          _DashboardStat(
            'Total Guru',
            '25',
            Icons.school_outlined,
            const Color(0xFF259B83),
          ),
          _DashboardStat(
            'Total Kelas',
            '12',
            Icons.meeting_room_outlined,
            const Color(0xFFE39A36),
          ),
          _DashboardStat(
            'Kehadiran',
            '95%',
            Icons.fact_check_outlined,
            const Color(0xFF8063B7),
          ),
        ];

      case 'kelas':
        return [
          _DashboardStat(
            'Jadwal Hari Ini',
            '5',
            Icons.calendar_month_outlined,
            scpBlue,
          ),
          _DashboardStat(
            'Informasi Kelas',
            '3',
            Icons.info_outline,
            const Color(0xFF259B83),
          ),
        ];

      default:
        return [];
    }
  }

  List<_DashboardMenu> get _menus {
    switch (_selectedRole) {
      case 'siswa':
        return [
          _DashboardMenu(
            'Jadwal Pelajaran',
            'Lihat jadwal dan jam pelajaran',
            Icons.calendar_month_outlined,
          ),
          _DashboardMenu(
            'Presensi Saya',
            'Lihat catatan kehadiran',
            Icons.fact_check_outlined,
          ),
          _DashboardMenu(
            'Pengajuan Izin',
            'Ajukan izin atau sakit',
            Icons.note_add_outlined,
          ),
          _DashboardMenu(
            'Riwayat Kehadiran',
            'Lihat riwayat presensi',
            Icons.history,
          ),
        ];

      case 'orangtua':
        return [
          _DashboardMenu(
            'Jadwal Anak',
            'Lihat jadwal pelajaran anak',
            Icons.calendar_month_outlined,
          ),
          _DashboardMenu(
            'Presensi Anak',
            'Pantau catatan kehadiran anak',
            Icons.fact_check_outlined,
          ),
          _DashboardMenu(
            'Perizinan',
            'Ajukan izin untuk anak',
            Icons.note_add_outlined,
          ),
        ];

      case 'guru':
        return [
          _DashboardMenu(
            'Jadwal Mengajar',
            'Lihat jadwal kelas dan mata pelajaran',
            Icons.calendar_month_outlined,
          ),
          _DashboardMenu(
            'Jurnal Mengajar',
            'Isi jurnal dan dokumentasi mengajar',
            Icons.menu_book_outlined,
          ),
          _DashboardMenu(
            'Data Izin Siswa',
            'Lihat data izin siswa',
            Icons.fact_check_outlined,
          ),
        ];

      case 'bk':
        return [
          _DashboardMenu(
            'Pemantauan Siswa',
            'Pantau ketidakhadiran siswa',
            Icons.people_outline,
          ),
          _DashboardMenu(
            'Data Perizinan',
            'Periksa pengajuan dan bukti izin',
            Icons.fact_check_outlined,
          ),
          _DashboardMenu(
            'Presensi Guru',
            'Lihat kehadiran per mata pelajaran',
            Icons.school_outlined,
          ),
        ];

      case 'waka':
        return [
          _DashboardMenu(
            'Data Siswa',
            'Kelola data siswa dan kelas',
            Icons.people_outline,
          ),
          _DashboardMenu(
            'Data Guru',
            'Kelola data guru',
            Icons.school_outlined,
          ),
          _DashboardMenu(
            'Data Kelas',
            'Pantau data kelas dan rombel',
            Icons.meeting_room_outlined,
          ),
          _DashboardMenu(
            'Jadwal Pelajaran',
            'Pantau jadwal sekolah',
            Icons.calendar_month_outlined,
          ),
          _DashboardMenu(
            'Presensi Siswa',
            'Pantau rekap kehadiran',
            Icons.fact_check_outlined,
          ),
          _DashboardMenu(
            'Jurnal Mengajar',
            'Pantau jurnal dan pengisian guru',
            Icons.menu_book_outlined,
          ),
          _DashboardMenu(
            'Laporan',
            'Lihat ringkasan aktivitas sekolah',
            Icons.bar_chart_outlined,
          ),
        ];

      case 'kelas':
        return [
          _DashboardMenu(
            'Jadwal Kelas',
            'Lihat jadwal pelajaran',
            Icons.calendar_month_outlined,
          ),
          _DashboardMenu(
            'Informasi Kelas',
            'Lihat informasi kelas',
            Icons.info_outline,
          ),
        ];

      default:
        return [];
    }
  }

  void _openMenu(_DashboardMenu menu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeatureScreen(
          title: menu.title,
          subtitle: menu.subtitle,
          roleName: _roleName,
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(22, 8, 22, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: scpNavy,
                  ),
                ),
                SizedBox(height: 18),
                _NotificationItem(
                  icon: Icons.notifications_none,
                  title: 'Selamat datang di SCP',
                  subtitle: 'Aplikasi SCP Mobile sedang dikembangkan.',
                ),
                SizedBox(height: 18),
                _NotificationItem(
                  icon: Icons.info_outline,
                  title: 'Informasi',
                  subtitle:
                      'Notifikasi asli tersedia setelah API terhubung.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari aplikasi?'),
          content: const Text(
            'Apakah kamu ingin kembali ke halaman sebelumnya?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: scpNavy,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      _buildMenuPage(),
      _buildActivityPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: scpBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scpNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scpNavy,
                    fontSize: 19,
                  ),
                ),
                Text(
                  'School Class Progress',
                  style: TextStyle(
                    color: scpMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: _showNotifications,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: scpNavy,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: scpBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _selectedTab,
            onDestinationSelected: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFE8EEF7),
            height: 68,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Menu',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history_rounded),
                label: 'Aktivitas',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text(
          _greeting,
          style: const TextStyle(
            color: scpNavy,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _description,
          style: const TextStyle(
            color: scpMuted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        _buildDateCard(),
        const SizedBox(height: 23),
        const _SectionHeading(
          title: 'Ringkasan',
          subtitle: 'Informasi singkat akun kamu',
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 130,
          ),
          itemBuilder: (context, index) {
            return _StatCard(stat: _stats[index]);
          },
        ),
        const SizedBox(height: 27),
        _SectionHeading(
          title: 'Menu Utama',
          subtitle: 'Akses fitur akun $_roleName',
          trailing: TextButton(
            onPressed: () {
              setState(() {
                _selectedTab = 1;
              });
            },
            child: const Text(
              'Lihat semua',
              style: TextStyle(
                color: scpBlue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._menus.take(4).map(
          (menu) => _MenuTile(
            menu: menu,
            onTap: () => _openMenu(menu),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FA),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: scpNavy, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi aplikasi',
                      style: TextStyle(
                        color: scpNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Data dashboard masih berupa contoh dan belum '
                      'terhubung ke database.',
                      style: TextStyle(
                        color: scpMuted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard() {
    final now = DateTime.now();
    final date = '${now.day} ${_monthName(now.month)} ${now.year}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scpNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scpNavy.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tetap semangat menjalani aktivitas!',
                  style: TextStyle(
                    color: Color(0xFFD6DFED),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Semua Menu',
          style: TextStyle(
            color: scpNavy,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Fitur yang tersedia untuk akun $_roleName.',
          style: const TextStyle(color: scpMuted, fontSize: 13),
        ),
        const SizedBox(height: 22),
        ..._menus.map(
          (menu) => _MenuTile(
            menu: menu,
            onTap: () => _openMenu(menu),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'Aktivitas',
          style: TextStyle(
            color: scpNavy,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Ringkasan aktivitas terbaru.',
          style: TextStyle(color: scpMuted, fontSize: 13),
        ),
        SizedBox(height: 24),
        _ActivityItem(
          icon: Icons.login_rounded,
          title: 'Aplikasi dibuka',
          description: 'Kamu sedang melihat pratinjau SCP Mobile.',
          time: 'Baru saja',
        ),
        _ActivityItem(
          icon: Icons.dashboard_outlined,
          title: 'Dashboard ditampilkan',
          description: 'Data yang terlihat masih berupa data contoh.',
          time: 'Baru saja',
        ),
        SizedBox(height: 18),
        _EmptyInfo(
          icon: Icons.history_rounded,
          title: 'Riwayat aktivitas belum tersedia',
          description: 'Riwayat asli akan tersedia setelah backend '
              'terintegrasi.',
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Profil',
          style: TextStyle(
            color: scpNavy,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scpBorder),
          ),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: scpNavy,
                  size: 42,
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'Pengguna SCP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scpNavy,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _roleName,
                style: const TextStyle(fontSize: 13, color: scpMuted),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6EF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Mode pratinjau',
                  style: TextStyle(
                    color: Color(0xFF237A53),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _ProfileOption(
          icon: Icons.person_outline,
          title: 'Informasi Profil',
          subtitle: 'Data pengguna',
          onTap: () => _showProfileInfo('Informasi Profil'),
        ),
        _ProfileOption(
          icon: Icons.lock_outline,
          title: 'Ubah Password',
          subtitle: 'Pengaturan keamanan akun',
          onTap: () => _showProfileInfo('Ubah Password'),
        ),
        _ProfileOption(
          icon: Icons.info_outline,
          title: 'Tentang SCP',
          subtitle: 'School Class Progress',
          onTap: () => _showProfileInfo('Tentang SCP'),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 51,
          child: OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Keluar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC33D46),
              side: const BorderSide(color: Color(0xFFF0D6D8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileInfo(String title) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: const Text(
            'Fitur ini memerlukan integrasi dengan backend Laravel.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return months[month - 1];
  }
}

class _DashboardStat {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardStat(
    this.title,
    this.value,
    this.icon,
    this.color,
  );
}

class _DashboardMenu {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DashboardMenu(
    this.title,
    this.subtitle,
    this.icon,
  );
}

class _StatCard extends StatelessWidget {
  final _DashboardStat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scpBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: stat.color, size: 21),
          ),
          Text(
            stat.value,
            style: const TextStyle(
              color: scpNavy,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            stat.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: scpMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: scpNavy,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: scpMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _DashboardMenu menu;
  final VoidCallback onTap;

  const _MenuTile({
    required this.menu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scpBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(menu.icon, color: scpNavy, size: 23),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.title,
                        style: const TextStyle(
                          color: scpText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        menu.subtitle,
                        style: const TextStyle(
                          color: scpMuted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: scpMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scpBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FA),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: scpNavy),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: scpNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: scpMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  time,
                  style: const TextStyle(
                    color: scpBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: scpBorder),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        leading: Icon(icon, color: scpNavy, size: 23),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: scpText,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: scpMuted),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: scpMuted,
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: scpNavy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: scpNavy,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: scpMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyInfo({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scpBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 35, color: scpMuted),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: scpNavy,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: scpMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}