import 'package:flutter/material.dart';

import 'browse/browse_page.dart';
import 'shelf/shelf_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with AutomaticKeepAliveClientMixin {
  late int _currentPageIndex;
  late PageController _pageController;
  late List<NavigationDestination> _destinations;

  @override
  void initState() {
    super.initState();

    _destinations = [
      ShelfPage.destination,
      BrowsePage.destination,
      // ConfigPage.destination,
    ];

    _currentPageIndex = 0;
    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);

            _currentPageIndex = index;
          });
        },
        destinations: _destinations,
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _destinations.length,
        itemBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return const ShelfPage();
            case 1:
              return const BrowsePage();
            // case 2:
            //   return const ConfigPage();
            default:
              throw Exception('Invalid index');
          }
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
