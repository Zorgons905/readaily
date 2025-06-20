import 'package:flutter/material.dart';
import '../pages/create_class_page.dart';
import '../pages/create_quiz_page.dart';
import '../pages/join_class_page.dart';
import '../pages/library_page.dart';
import '../pages/profile_page.dart';
import '../pages/leaderboard_page.dart';
import '../pages/upload_page.dart';
import '../pages/home_page.dart';
import '../services/auth_service.dart';

class Navbar extends StatefulWidget {
  final String role;
  const Navbar({super.key, required this.role});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final userID = AuthService().getCurrentUserID();
  late final List<Widget> _tabs;
  OverlayEntry? _overlayEntry;
  late AnimationController _fabAnimationController;
  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomePage(key: _homeKey, id: userID, role: widget.role),
      LibraryPage(id: userID, role: widget.role),
      LeaderboardPage(),
      ProfilePage(id: userID, role: widget.role),
    ];

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleOverlayMenu() {
    if (_overlayEntry == null) {
      _fabAnimationController.forward();
      _overlayEntry = _buildOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _fabAnimationController.reverse();
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _fabAnimationController.reverse();
            _removeOverlay();
          },
          child: Stack(
            children: [
              Positioned(
                bottom: 100,
                width: screenWidth,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildMenuItems(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems() {
    final List<Widget> items = [];

    void addItem(String label, IconData icon, VoidCallback onTap) {
      items.add(
        GestureDetector(
          onTap: () {
            _removeOverlay();
            _fabAnimationController.reverse();
            onTap();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }

    if (widget.role == 'lecturer') {
      addItem('Upload Modul', Icons.upload_file, _navigateToUploadModule);
      addItem('Buat Kelas', Icons.class_, _navigateToCreateClass);
      addItem('Buat Quiz', Icons.quiz, _navigateToCreateQuiz);
    } else if (widget.role == 'student') {
      addItem('Gabung Kelas', Icons.group_add, _navigateToJoinClass);
    }

    return items;
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (_, child) {
        return Transform.rotate(
          angle: _fabAnimationController.value * 3.14 * 1.5,
          child: child,
        );
      },
      child: FloatingActionButton(
        onPressed: _toggleOverlayMenu,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const CircleBorder(), // lingkaran
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // NAVIGATION
  void _navigateToCreateQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuizPage(lecturerId: userID),
      ),
    );
  }

  void _navigateToCreateClass() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateClassPage(lecturerId: userID)),
    );
  }

  void _navigateToUploadModule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadPage(lecturerId: userID)),
    );
  }

  void _navigateToJoinClass() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JoinClassPage(studentId: userID)),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(child: _buildNavItem(0, Icons.home, 'Home')),
          Expanded(child: _buildNavItem(1, Icons.folder, 'Library')),
          const Expanded(child: SizedBox()), // spacer for FAB
          Expanded(child: _buildNavItem(2, Icons.emoji_events, 'Leaderboard')),
          Expanded(child: _buildNavItem(3, Icons.person, 'Profile')),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _tabs[_currentIndex],
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:
          (widget.role == 'lecturer' || widget.role == 'student')
              ? _buildBottomNav()
              : BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.folder),
                    label: 'Library',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_events),
                    label: 'Leaderboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
    );
  }
}
