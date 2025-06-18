import 'package:cashy/features/financial_report/presentation/bloc/report_bloc.dart';
import 'package:cashy/features/financial_report/presentation/bloc/report_event.dart';
import 'package:cashy/features/financial_report/presentation/bloc/report_state.dart';
import 'package:cashy/features/financial_report/presentation/widgets/report_download.dart';
import 'package:cashy/features/financial_report/presentation/widgets/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool isMonthlySelected = true;
  late List<String> months;
  late List<String> years;
  String selectedPeriod = '';
  final List<String> exportCategories = ['Semua Kategori'];

  final List<String> exportFormats = ['XLS'];

  final Map<int, String> monthMap = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'Mei',
    6: 'Jun',
    7: 'Jul',
    8: 'Agu',
    9: 'Sep',
    10: 'Okt',
    11: 'Nov',
    12: 'Des',
  };

  List<String> getMonthsUntilNow() {
    final now = DateTime.now();
    return List.generate(now.month, (i) => monthMap[now.month - i]!);
  }

  @override
  void initState() {
    super.initState();
    months = getMonthsUntilNow();
    years = getYears();
    selectedPeriod = months.first;

    context.read<ReportBloc>().add(FetchReportsThisYearUntilNow()); // fetch initial
  }

  void _showExportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ReportDownload(
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Laporan Keuangan',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              _showExportBottomSheet(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMonthlySelected = true;
                            months = getMonthsUntilNow();
                            selectedPeriod = months.first;
                          });
                          context
                              .read<ReportBloc>()
                              .add(FetchReportsThisYearUntilNow()); // refresh
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isMonthlySelected ? Colors.green : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(8)),
                            boxShadow: [
                             if (!isMonthlySelected)
                                BoxShadow(
                                  color: Colors.grey.withAlpha(77),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                                'Bulanan',
                                style: TextStyle(
                                  color: isMonthlySelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ))),
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMonthlySelected = false;
                            years = getYears();
                            selectedPeriod = years.first;
                          });
                          context
                              .read<ReportBloc>()
                              .add(FetchYearlyReport(selectedPeriod)); // refresh
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                !isMonthlySelected ? Colors.green : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(8)),
                            boxShadow: [
                             if (isMonthlySelected)
                                BoxShadow(
                                  color: Colors.grey.withAlpha(77),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text('Tahunan',
                                style: TextStyle(
                                  color: !isMonthlySelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ))),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                    if (state is ReportLoading) {
                    return const Center(
                        child: CircularProgressIndicator()); 
                    } else if (state is ReportError) {
                    return Center(child: Text(state.message)); 
                    } else if (state is ReportLoaded) {
                    final report = state.report;

                    final monthlyData = <String, Map<String, double>>{};
                    for (var entry in report) {
                      final monthKey = monthMap[entry.date.month]!;
                      monthlyData[monthKey] ??= {
                        'income': 0.0,
                        'expense': 0.0
                      };
                      monthlyData[monthKey]!['income'] = 
                         (monthlyData[monthKey]!['income']! + entry.totalIncome);
                      monthlyData[monthKey]!['expense'] = 
                         (monthlyData[monthKey]!['expense']! + entry.totalExpense);
                    }

                    final displayList = isMonthlySelected ? months : years;

                    return ListView.builder(
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final item = displayList[index];
                        final isSelected = item == selectedPeriod;

                        final income = isMonthlySelected
                            ? (monthlyData[item]?['income'] ?? 0.0)
                            : report
                                .fold(0.0, (sum, r) => sum + r.totalIncome);
                        final expense = isMonthlySelected
                            ? (monthlyData[item]?['expense'] ?? 0.0)
                            : report
                                .fold(0.0, (sum, r) => sum + r.totalExpense);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPeriod = item;
                            });
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                   vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                   Container(
                                      width: 60,
                                      padding: const EdgeInsets.symmetric(
                                         vertical: 6, horizontal: 10),
                                      decoration: BoxDecoration(
                                      color: isSelected
                                         ? Colors.orange
                                         : Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(item,
                                         style: const TextStyle(
                                             color: Colors.white,
                                             fontWeight: FontWeight.bold))),
                                   const SizedBox(width: 20),
                                   Container(
                                      width: 110,
                                      child: Text(
                                         'Rp. ${income.toStringAsFixed(0)}',
                                         textAlign: TextAlign.left,
                                         style: const TextStyle(
                                             color: Colors.green,
                                             fontWeight: FontWeight.w600),
                                      ),
                                   ),
                                   const SizedBox(width: 20),
                                   Container(
                                      width: 110,
                                      child: Text(
                                         'Rp. ${expense.toStringAsFixed(0)}',
                                         textAlign: TextAlign.left,
                                         style: const TextStyle(
                                             color: Colors.red,
                                             fontWeight: FontWeight.w600),
                                      ),
                                   ),
                                  ],
                                )),
                          ),
                        );
                      },
                    );
                    }
                    return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

