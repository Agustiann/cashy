import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:cashy/features/auth/presentation/screens/profile_page.dart';
import 'package:cashy/features/category/presentation/screens/category_page.dart';
import 'package:cashy/features/home/presentation/bloc/home_bloc.dart';
import 'package:cashy/features/home/presentation/screens/home_page.dart';
import 'package:cashy/features/pos/presentation/screens/pos_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  DateTime selectedDate = DateTime.now();

  void _onDateChanged(DateTime date) {
    setState(() => selectedDate = date);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context
          .read<HomeBloc>()
          .add(LoadHomeData(userId: userId, selectedDate: selectedDate));
    }
  }

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context
          .read<HomeBloc>()
          .add(LoadHomeData(userId: userId, selectedDate: selectedDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User belum login")),
      );
    }

    final List<Widget> _children = [
      const HomePage(),
      const PosPage(),
      CategoryPage(userId: user.id, type: 'expense'),
      ProfilePage(),
    ];

    String _getAppBarTitle(int index) {
      switch (index) {
        case 1:
          return 'Pos Keuangan';
        case 2:
          return 'Kategori';
        case 3:
          return 'Profil Anda';
        default:
          return '';
      }
    }

    return Scaffold(
      appBar: (currentIndex == 0)
          ? CalendarAppBar(
              accent: Colors.blue,
              backButton: false,
              locale: 'id',
              onDateChanged: _onDateChanged,
              firstDate: DateTime(2024, 1, 1),
              lastDate: DateTime.now(),
              selectedDate: selectedDate,
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(40.0),
              child: AppBar(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.blue,
                title: Text(
                  _getAppBarTitle(currentIndex),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
      body: _children[currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => setState(() => currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey[600],
              selectedLabelStyle:
                  GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.montserrat(),
              backgroundColor: Colors.white,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: 'Beranda'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt_outlined), label: 'Pos'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.category_outlined), label: 'Kategori'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
