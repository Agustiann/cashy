import 'package:flutter/material.dart';
import 'package:cashy/features/financial_report/data/datasources/report_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportDownload extends StatefulWidget {
  const ReportDownload({Key? key}) : super(key: key);

  @override
  _ReportDownloadState createState() => _ReportDownloadState();
}

class _ReportDownloadState extends State<ReportDownload> {
  List<String> transactionTypes = ['Semua tipe'];
  String? selectedType = 'Semua tipe';
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  final Map<String, String> transactionTypeMap = {
    'Pemasukan': 'income',
    'Pengeluaran': 'expense',
  };

  @override
  void initState() {
    super.initState();
    _loadTransactionTypes();
  }

  Future<void> _loadTransactionTypes() async {
    final types = await ReportRemoteDatasource(Supabase.instance.client)
        .getTransactionTypes();

    final filteredTypes = types
        .where((type) => type.toLowerCase() != 'semua tipe')
        .toSet()
        .toList();

    setState(() {
      transactionTypes = ['Semua tipe', ...filteredTypes];

      if (!transactionTypes.contains(selectedType)) {
        selectedType = 'Semua tipe';
      }
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  Future<void> _exportPdf() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final fromDate = fromDateController.text;
    final toDate = toDateController.text;
    final title = titleController.text;

    final filterType = selectedType == 'Semua tipe'
        ? null
        : transactionTypeMap[selectedType ?? ''];

    final response = await client
        .from('transactions')
        .select()
        .eq('user_id', user!.id)
        .gte('date', fromDate)
        .lte('date', toDate)
        .order('date')
        .order('created_at');

    List data = response;

    if (filterType != null) {
      data = data.where((item) => item['type'] == filterType).toList();
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(title,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Tipe Transaksi: ${selectedType ?? '-'}'),
          pw.SizedBox(height: 20),
          pw.Text('Nama: ${user.userMetadata?["display_name"] ?? '-'}'),
          pw.Text('Email: ${user.email ?? '-'}'),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: [
              'Tanggal',
              'Waktu',
              'Nominal',
              'Tipe',
              'Kategori',
              'Keterangan',
              'Tipe Pengeluaran'
            ],
            data: data.map((item) {
              final date = item['date'] ?? '-';
              final time =
                  DateFormat.Hm().format(DateTime.parse(item['created_at']));
              final amount = item['amount'].toString();
              final type = item['type'] ?? '-';
              final category = item['category'] ?? '-';
              final note = item['note'] ?? '-';
              final source = item['source'] ?? '-';
              return [date, time, 'Rp $amount', type, category, note, source];
            }).toList(),
          )
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Judul',
            ),
          ),
          GestureDetector(
            onTap: () => _selectDate(context, fromDateController),
            child: AbsorbPointer(
              child: TextFormField(
                controller: fromDateController,
                decoration: const InputDecoration(
                  labelText: 'Dari Tanggal',
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _selectDate(context, toDateController),
            child: AbsorbPointer(
              child: TextFormField(
                controller: toDateController,
                decoration: const InputDecoration(
                  labelText: 'Sampai Tanggal',
                ),
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tipe',
            ),
            value: selectedType,
            items: transactionTypes.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedType = val),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('BATAL',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _exportPdf,
                  child: const Text('EKSPOR',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
