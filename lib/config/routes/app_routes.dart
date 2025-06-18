// import 'package:flutter/material.dart';

// import 'package:go_router/go_router.dart';

// import '../../features/auth/presentation/screens/login_page.dart';
// import '../../features/home/presentation/screens/main_page.dart';
// import '../../features/pos/presentation/screens/pos_page.dart';
// import '../../features/category/presentation/screens/category_page.dart';
// import '../../features/financial_report/presentation/screens/report_page.dart';
// import '../../features/auth/presentation/screens/profile_page.dart';
// import '../../features/transaction/presentation/screens/transaction_page.dart';

// class AppRoutes {
//   static final GoRouter router = GoRouter(
//     initialLocation: '/login',
//     routes: [
//       GoRoute(
//         path: '/login',
//         builder: (context, state) => LoginPage(),
//       ),
//       GoRoute(
//         path: '/main',
//         builder: (context, state) => const MainPage(),
//         routes: [
//           GoRoute(
//             path: 'pos',
//             builder: (context, state) => const PosPage(),
//           ),
//           GoRoute(
//             path: 'category',
//             builder: (context, state) => const CategoryPage(),
//           ),
//           GoRoute(
//             path: 'report',
//             builder: (context, state) => const ReportPage(),
//           ),
//           GoRoute(
//             path: 'profile',
//             builder: (context, state) => ProfilePage(),
//           ),
//           GoRoute(
//             path: 'transaction',
//             builder: (context, state) => const TransactionPage(),
//           ),
//         ],
//       ),
//     ],
//   );
// }
