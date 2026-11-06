import 'package:flutter/material.dart';

const Color featureNavy = Color(0xFF172B4D);
const Color featureBlue = Color(0xFF3268B2);
const Color featureBackground = Color(0xFFF4F6FA);
const Color featureText = Color(0xFF26354D);
const Color featureMuted = Color(0xFF778397);
const Color featureBorder = Color(0xFFE7ECF3);

class FeatureScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String roleName;

  const FeatureScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.roleName,
  });

  @override
  State<FeatureScreen> createState() => _FeatureScreenState();
}

class _FeatureScreenState extends State<FeatureScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _journalController = TextEditingController();

  String _selectedDay = 'Senin';
  String _selectedPermission = 'Sakit';
  String _selectedClass = 'XI RPL 1';
  String _selectedSubject = 'Pemrograman Web';

  bool _submitted = false;

  final List<String> _days = const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
  ];

  final List<Map<String, String>> _scheduleData = const [
    {
      'day': 'Senin',
      'time': '07.00 - 08.30',
      'subject': 'Pemrograman Web',
      'class': 'XI RPL 1',
      'teacher': 'Bapak/Ibu Guru',
    },
    {
      'day': 'Senin',
      'time': '08.30 - 10.00',
      'subject': 'Basis Data',
      'class': 'XI RPL 1',
      'teacher': 'Bapak/Ibu Guru',
    },
    {
      'day': 'Selasa',
      'time': '07.00 - 08.30',
      'subject': 'Pemrograman Berorientasi Objek',
      'class': 'XI RPL 1',
      'teacher': 'Bapak/Ibu Guru',
    },
    {
      'day': 'Rabu',
      'time': '09.00 - 10.30',
      'subject': 'Desain Antarmuka',
      'class': 'XI RPL 1',
      'teacher': 'Bapak/Ibu Guru',
    },
    {
      'day': 'Kamis',
      'time': '07.00 - 08.30',
      'subject': 'Basis Data',
      'class': 'XI RPL 1',
      'teacher': 'Bapak/Ibu Guru',
    },
    {
      'day': 'Jumat',
      'time': '07.00 - 08.00',
      'subject': 'Projek RPL',
      'class': 'XI RPL 1',
      'teacher': 'Bapak/Ibu Guru',
    },
  ];

  final List<Map<String, String>> _attendanceData = const [
    {
      'date': '02 November 2026',
      'day': 'Senin',
      'status': 'Hadir',
    },
    {
      'date': '30 Oktober 2026',
      'day': 'Jumat',
      'status': 'Hadir',
    },
    {
      'date': '29 Oktober 2026',
      'day': 'Kamis',
      'status': 'Izin',
    },
    {
      'date': '28 Oktober 2026',
      'day': 'Rabu',
      'status': 'Hadir',
    },
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: featureBackground,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: featureNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: featureNavy,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    final title = widget.title.toLowerCase();

    if (title.contains('jadwal')) {
      return _buildSchedulePage();
    }

    if (title.contains('pengajuan izin') ||
        title == 'perizinan' ||
        title.contains('izin untuk anak')) {
      return _buildPermissionForm();
    }

    if (title.contains('jurnal')) {
      return _buildJournalForm();
    }

    if (title.contains('presensi') ||
        title.contains('kehadiran')) {
      return _buildAttendancePage();
    }

    if (title.contains('pemantauan siswa') ||
        title.contains('data perizinan') ||
        title.contains('data izin siswa') ||
        title.contains('presensi guru')) {
      return _buildMonitoringPage();
    }

    if (title.contains('data siswa') ||
        title.contains('data guru') ||
        title.contains('data kelas') ||
        title.contains('laporan')) {
      return _buildSchoolDataPage();
    }

    if (title.contains('informasi kelas')) {
      return _buildClassInformationPage();
    }

    return _buildGeneralPage();
  }

  Widget _buildSchedulePage() {
    final filteredSchedules = _scheduleData
        .where((item) => item['day'] == _selectedDay)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildIntroCard(
          icon: Icons.calendar_month_outlined,
          title: widget.title,
          description: widget.subtitle,
        ),
        const SizedBox(height: 22),
        _sectionTitle('Pilih Hari'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: _cardDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDay,
              isExpanded: true,
              items: _days.map((day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDay = value;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Jadwal $_selectedDay'),
        const SizedBox(height: 12),
        if (filteredSchedules.isEmpty)
          _buildEmptyState(
            icon: Icons.event_busy_outlined,
            title: 'Tidak ada jadwal',
            description:
                'Belum ada contoh jadwal untuk hari $_selectedDay.',
          )
        else
          ...filteredSchedules.map(
            (item) => _buildScheduleCard(item),
          ),
        const SizedBox(height: 18),
        _buildDemoNotice(),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 88,
            decoration: BoxDecoration(
              color: featureBlue,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['time']!,
                  style: const TextStyle(
                    color: featureBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['subject']!,
                  style: const TextStyle(
                    color: featureNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Kelas: ${item['class']}',
                  style: const TextStyle(
                    color: featureMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pengajar: ${item['teacher']}',
                  style: const TextStyle(
                    color: featureMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendancePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildIntroCard(
          icon: Icons.fact_check_outlined,
          title: widget.title,
          description: widget.subtitle,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildSmallStat(
                'Hadir',
                '3',
                const Color(0xFF259B83),
                Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallStat(
                'Izin',
                '1',
                const Color(0xFFE39A36),
                Icons.event_note_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 23),
        _sectionTitle('Riwayat Kehadiran'),
        const SizedBox(height: 12),
        ..._attendanceData.map((item) {
          final status = item['status']!;
          final statusColor = status == 'Hadir'
              ? const Color(0xFF259B83)
              : status == 'Izin'
                  ? const Color(0xFFE39A36)
                  : const Color(0xFFC94C55);

          return Container(
            margin: const EdgeInsets.only(bottom: 11),
            padding: const EdgeInsets.all(15),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    status == 'Hadir'
                        ? Icons.check_circle_outline
                        : Icons.event_note_outlined,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['date']!,
                        style: const TextStyle(
                          color: featureText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['day']!,
                        style: const TextStyle(
                          color: featureMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(status, statusColor),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        _buildDemoNotice(),
      ],
    );
  }

  Widget _buildPermissionForm() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildIntroCard(
          icon: Icons.note_add_outlined,
          title: 'Pengajuan Perizinan',
          description:
              'Isi alasan izin atau sakit. Pengajuan ini masih berupa '
              'simulasi dan belum dikirim ke sekolah.',
        ),
        const SizedBox(height: 22),
        if (_submitted) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6EF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFC6E8D5),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF237A53),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Simulasi pengajuan berhasil. Data belum tersimpan '
                    'ke database Laravel.',
                    style: TextStyle(
                      color: Color(0xFF237A53),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Jenis Perizinan'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: _cardDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPermission,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Sakit',
                        child: Text('Sakit'),
                      ),
                      DropdownMenuItem(
                        value: 'Izin',
                        child: Text('Izin'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPermission = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _fieldLabel('Tanggal Pengajuan'),
              const SizedBox(height: 8),
              _readOnlyField(
                '${DateTime.now().day} '
                '${_monthName(DateTime.now().month)} '
                '${DateTime.now().year}',
                Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 18),
              _fieldLabel('Alasan'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: _inputDecoration(
                  hint: 'Jelaskan alasan izin atau sakit...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan wajib diisi.';
                  }
                  if (value.trim().length < 5) {
                    return 'Alasan minimal 5 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _fieldLabel('Bukti Pendukung'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: featureBorder,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 30,
                      color: featureBlue,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Unggah foto atau dokumen pendukung',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: featureText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Unggah file akan diaktifkan pada tahap berikutnya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: featureMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _submitPermission,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Kirim Pengajuan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: featureNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDemoNotice(),
            ],
          ),
        ),
      ],
    );
  }

  void _submitPermission() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitted = true;
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Simulasi pengajuan selesai. Data belum dikirim ke server.',
        ),
      ),
    );
  }

  Widget _buildJournalForm() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildIntroCard(
          icon: Icons.menu_book_outlined,
          title: 'Jurnal Mengajar',
          description:
              'Catat kegiatan pembelajaran. Formulir ini belum '
              'menyimpan data ke backend.',
        ),
        const SizedBox(height: 22),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Kelas'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedClass,
                items: const [
                  'XI RPL 1',
                  'XI RPL 2',
                  'X RPL 1',
                  'XII RPL 1',
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedClass = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 18),
              _fieldLabel('Mata Pelajaran'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedSubject,
                items: const [
                  'Pemrograman Web',
                  'Basis Data',
                  'Pemrograman Berorientasi Objek',
                  'Projek RPL',
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 18),
              _fieldLabel('Tanggal Mengajar'),
              const SizedBox(height: 8),
              _readOnlyField(
                '${DateTime.now().day} '
                '${_monthName(DateTime.now().month)} '
                '${DateTime.now().year}',
                Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 18),
              _fieldLabel('Kegiatan Pembelajaran'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _journalController,
                maxLines: 5,
                decoration: _inputDecoration(
                  hint: 'Tuliskan materi dan kegiatan pembelajaran...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kegiatan pembelajaran wajib diisi.';
                  }
                  if (value.trim().length < 5) {
                    return 'Isi minimal 5 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _fieldLabel('Dokumentasi Foto'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: featureBorder),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: featureBlue,
                      size: 30,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tambah foto kegiatan mengajar',
                      style: TextStyle(
                        color: featureText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Fitur kamera dan unggah foto akan dihubungkan nanti.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: featureMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _submitJournal,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan Jurnal'),
                  style: FilledButton.styleFrom(
                    backgroundColor: featureNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDemoNotice(),
            ],
          ),
        ),
      ],
    );
  }

  void _submitJournal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Jurnal siap disimpan'),
          content: Text(
            'Kelas: $_selectedClass\n'
            'Mata pelajaran: $_selectedSubject\n\n'
            'Ini masih simulasi. Jurnal belum dikirim ke Laravel.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonitoringPage() {
    final title = widget.title.toLowerCase();

    final List<Map<String, String>> items;

    if (title.contains('izin')) {
      items = const [
        {
          'title': 'Pengajuan izin siswa',
          'subtitle': 'Menunggu pemeriksaan',
          'status': 'Menunggu',
        },
        {
          'title': 'Pengajuan sakit siswa',
          'subtitle': 'Bukti pendukung perlu diperiksa',
          'status': 'Menunggu',
        },
      ];
    } else if (title.contains('guru')) {
      items = const [
        {
          'title': 'Pemrograman Web',
          'subtitle': 'XI RPL 1',
          'status': 'Contoh',
        },
        {
          'title': 'Basis Data',
          'subtitle': 'XI RPL 2',
          'status': 'Contoh',
        },
      ];
    } else {
      items = const [
        {
          'title': 'Siswa dengan ketidakhadiran',
          'subtitle': 'Perlu ditinjau lebih lanjut',
          'status': 'Perhatian',
        },
        {
          'title': 'Pemantauan kelas',
          'subtitle': 'Ringkasan kehadiran siswa',
          'status': 'Contoh',
        },
      ];
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildIntroCard(
          icon: Icons.analytics_outlined,
          title: widget.title,
          description: widget.subtitle,
        ),
        const SizedBox(height: 22),
        _sectionTitle('Ringkasan Pemantauan'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallStat(
                'Perlu ditinjau',
                '2',
                const Color(0xFFE39A36),
                Icons.pending_actions_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallStat(
                'Data contoh',
                '2',
                featureBlue,
                Icons.list_alt_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _sectionTitle('Daftar Pemantauan'),
        const SizedBox(height: 12),
        ...items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  color: featureBlue,
                  size: 27,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          color: featureText,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['subtitle']!,
                        style: const TextStyle(
                          color: featureMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: _statusBadge(
                    item['status']!,
                    const Color(0xFFE39A36),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        _buildDemoNotice(),
      ],
    );
  }

  Widget _buildSchoolDataPage() {
    final title = widget.title.toLowerCase();

    late final List<Map<String, String>> items;

    if (title.contains('guru')) {
      items = const [
        {
          'name': 'Guru Contoh 1',
          'detail': 'Mata pelajaran: Pemrograman Web',
          'code': 'GURU-001',
        },
        {
          'name': 'Guru Contoh 2',
          'detail': 'Mata pelajaran: Basis Data',
          'code': 'GURU-002',
        },
      ];
    } else if (title.contains('kelas')) {
      items = const [
        {
          'name': 'X RPL 1',
          'detail': 'Tingkat X',
          'code': 'KELAS-001',
        },
        {
          'name': 'XI RPL 1',
          'detail': 'Tingkat XI',
          'code': 'KELAS-002',
        },
        {
          'name': 'XII RPL 1',
          'detail': 'Tingkat XII',
          'code': 'KELAS-003',
        },
      ];
    } else if (title.contains('laporan')) {
      items = const [
        {
          'name': 'Laporan Presensi',
          'detail': 'Ringkasan kehadiran siswa',
          'code': 'LAP-001',
        },
        {
          'name': 'Laporan Jurnal',
          'detail': 'Ringkasan jurnal mengajar',
          'code': 'LAP-002',
        },
        {
          'name': 'Laporan Perizinan',
          'detail': 'Ringkasan pengajuan izin',
          'code': 'LAP-003',
        },
      ];
    } else {
      items = const [
        {
          'name': 'Siswa Contoh 1',
          'detail': 'Kelas XI RPL 1',
          'code': 'SISWA-001',
        },
        {
          'name': 'Siswa Contoh 2',
          'detail': 'Kelas XI RPL 1',
          'code': 'SISWA-002',
        },
        {
          'name': 'Siswa Contoh 3',
          'detail': 'Kelas XI RPL 2',
          'code': 'SISWA-003',
        },
      ];
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildIntroCard(
          icon: title.contains('laporan')
              ? Icons.bar_chart_outlined
              : Icons.storage_outlined,
          title: widget.title,
          description: widget.subtitle,
        ),
        const SizedBox(height: 22),
        if (!title.contains('laporan'))
          TextField(
            decoration: _inputDecoration(
              hint: 'Cari ${widget.title.toLowerCase()}...',
              prefixIcon: Icons.search,
            ),
            onChanged: (value) {
              // Pencarian data backend akan dibuat saat API terhubung.
            },
          ),
        const SizedBox(height: 20),
        _sectionTitle('Daftar ${widget.title}'),
        const SizedBox(height: 12),
        ...items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0FA),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    title.contains('guru')
                        ? Icons.school_outlined
                        : title.contains('kelas')
                            ? Icons.meeting_room_outlined
                            : title.contains('laporan')
                                ? Icons.description_outlined
                                : Icons.person_outline,
                    color: featureNavy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name']!,
                        style: const TextStyle(
                          color: featureText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['detail']!,
                        style: const TextStyle(
                          color: featureMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['code']!,
                        style: const TextStyle(
                          color: featureBlue,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: featureMuted,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        _buildDemoNotice(),
      ],
    );
  }

  Widget _buildClassInformationPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildIntroCard(
          icon: Icons.meeting_room_outlined,
          title: 'Informasi Kelas',
          description: widget.subtitle,
        ),
        const SizedBox(height: 22),
        _sectionTitle('Informasi Umum'),
        const SizedBox(height: 12),
        _informationRow('Nama Kelas', 'XI RPL 1'),
        _informationRow('Tingkat', 'XI'),
        _informationRow('Jurusan', 'Rekayasa Perangkat Lunak'),
        _informationRow('Wali Kelas', 'Belum tersedia'),
        const SizedBox(height: 22),
        _sectionTitle('Informasi Tambahan'),
        const SizedBox(height: 12),
        _buildEmptyState(
          icon: Icons.info_outline,
          title: 'Belum ada pengumuman',
          description:
              'Informasi kelas akan ditampilkan setelah data '
              'terhubung ke backend Laravel.',
        ),
        const SizedBox(height: 16),
        _buildDemoNotice(),
      ],
    );
  }

  Widget _buildGeneralPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildIntroCard(
          icon: Icons.dashboard_outlined,
          title: widget.title,
          description: widget.subtitle,
        ),
        const SizedBox(height: 20),
        _buildEmptyState(
          icon: Icons.hourglass_empty_outlined,
          title: 'Halaman siap dikembangkan',
          description:
              'Tampilan khusus untuk fitur ini akan disesuaikan '
              'dengan kebutuhan akun ${widget.roleName}.',
        ),
        const SizedBox(height: 16),
        _buildDemoNotice(),
      ],
    );
  }

  Widget _buildIntroCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: featureNavy,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFD6DFED),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              color: featureNavy,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: featureMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, size: 36, color: featureMuted),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: featureNavy,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: featureMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FA),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: featureNavy,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mode pratinjau: informasi yang ditampilkan masih '
              'berupa data contoh, belum berasal dari database.',
              style: TextStyle(
                color: featureNavy,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: featureNavy,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: featureText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _readOnlyField(String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: featureMuted, size: 20),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: featureText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _cardDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _informationRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: featureMuted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: featureText,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: featureMuted,
        fontSize: 12,
      ),
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: featureBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: featureBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: featureBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: featureBorder),
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
