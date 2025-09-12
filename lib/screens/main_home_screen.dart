import 'package:flutter/material.dart';
import 'package:ktnsolutions/screens/cases/cases_screen.dart';
import 'package:ktnsolutions/screens/recognitions/recognitions_screen.dart';
import 'package:ktnsolutions/screens/reports/reports_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const RecognitionsScreen(),
    const CasesScreen(),
    const ReportsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true, // For better bottom navigation bar with edge-to-edge
        body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom > 0
                  ? 0
                  : 16, // Add bottom padding only if there's no system padding
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: 'Recognitions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cases),
                  label: 'Cases',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics),
                  label: 'Reports',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
