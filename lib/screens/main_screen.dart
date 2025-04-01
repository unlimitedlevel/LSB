import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'report_form_screen.dart'; // Atau FormOCRScreen jika itu entry point utama
import 'form_ocr_screen.dart'; // Import FormOCRScreen
import '../services/auth_service.dart'; // Import AuthService

class MainScreen extends StatefulWidget {
  final AuthService authService; // Tambahkan parameter authService

  const MainScreen({super.key, required this.authService}); // Update constructor

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar layar yang akan ditampilkan di body
  // Kita perlu membuatnya non-static agar bisa mengakses widget.authService
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Inisialisasi _widgetOptions di initState untuk akses ke widget.authService
    _widgetOptions = <Widget>[
      // Teruskan authService ke HomeScreen
      HomeScreen(authService: widget.authService), // Uncomment dan teruskan authService
      const FormOCRScreen(), // FormOCRScreen mungkin tidak perlu authService?
      // Tambahkan layar lain di sini jika perlu (misal: Pengaturan dengan tombol logout)
      // ProfileScreen(authService: widget.authService),
    ];
  }


  void _onItemTapped(int index) {
    // Hindari navigasi ke halaman form jika sudah di halaman form
    // atau jika kita ingin menggunakan FAB khusus
    if (index == 1) {
      // Langsung navigasi ke FormOCRScreen sebagai modal atau push
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FormOCRScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        // Gunakan _widgetOptions yang sudah diinisialisasi
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo_outlined),
            activeIcon: Icon(Icons.add_a_photo),
            label: 'Scan LSB',
          ),
          // Contoh item untuk Logout (bisa diletakkan di AppBar atau halaman profil)
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person_outline),
          //   activeIcon: Icon(Icons.person),
          //   label: 'Profil', // Atau Pengaturan
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Agar label selalu terlihat
        backgroundColor: theme.colorScheme.surface,
        elevation: 8.0,
      ),
      // Contoh AppBar dengan tombol Logout
      // appBar: AppBar(
      //   title: const Text('LSB App'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: () async {
      //         await widget.authService.signOut();
      //         // StreamBuilder di main.dart akan otomatis handle navigasi ke LoginScreen
      //       },
      //     )
      //   ],
      // ),
    );
  }
}
