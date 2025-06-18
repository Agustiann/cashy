import 'package:cashy/features/financial_report/presentation/screens/report_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ Tambahkan ini
import 'package:cashy/features/auth/presentation/screens/login_page.dart';
import '../bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  String email = "";

  Color avatarColor = Colors.orange;

  String getInitials(String name) {
    if (name.trim().isEmpty) return "";

    List<String> words = name.trim().split(RegExp(r"\s+"));

    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final userMeta = user.userMetadata;

      setState(() {
        username = userMeta?['display_name'] ?? 'Unknown';
        email = user.email ?? 'No Email';
        final colorHex = userMeta?['avatar_color'];
        if (colorHex != null) {
          avatarColor = _hexToColor(colorHex);
        }
      });
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: avatarColor,
                    child: Text(
                      getInitials(username),
                      style: const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ReportPage()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pie_chart, color: Colors.blue, size: 35),
                    const SizedBox(width: 12),
                    Text(
                      'Laporan Keuangan',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () {
                context.read<LoginBloc>().add(LogoutButtonPressed());
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(successMessage: "Sign Out Berhasil!"),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: Text(
                "Sign Out",
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
