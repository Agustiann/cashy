import 'package:flutter/material.dart';
import 'package:cashy/features/financial_report/data/datasources/report_remote_datasource.dart';
import 'package:pdf/pdf.dart';
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

  final Map<String, String> typeTranslation = {
    'income': 'Pemasukan',
    'expense': 'Pengeluaran',
  };

  final Map<String, String> sourceTranslation = {
    'wants': 'Keinginan',
    'needs': 'Kebutuhan',
    'savings': 'Tabungan',
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
        pageFormat: PdfPageFormat.a4.landscape.applyMargin(
          left: 2.54 * PdfPageFormat.cm,
          top: 2.54 * PdfPageFormat.cm,
          right: 2.54 * PdfPageFormat.cm,
          bottom: 2.54 * PdfPageFormat.cm,
        ),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              title,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text('${selectedType ?? '-'}'),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Nama: ${user.userMetadata?["display_name"] ?? '-'}'),
          pw.Text('Email: ${user.email ?? '-'}'),
          pw.SizedBox(height: 20),
          pw.Table(
            columnWidths: {
              0: pw.FixedColumnWidth(2.69 * PdfPageFormat.cm),
              1: pw.FixedColumnWidth(1.63 * PdfPageFormat.cm),
              2: pw.FixedColumnWidth(3.71 * PdfPageFormat.cm),
              3: pw.FixedColumnWidth(2.74 * PdfPageFormat.cm),
              4: pw.FixedColumnWidth(3.55 * PdfPageFormat.cm),
              5: pw.FixedColumnWidth(7.70 * PdfPageFormat.cm),
              6: pw.FixedColumnWidth(2.67 * PdfPageFormat.cm),
            },
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF87CEFA),
                ),
                children: [
                  for (final header in [
                    'Tanggal',
                    'Waktu',
                    'Nominal',
                    'Tipe',
                    'Kategori',
                    'Keterangan',
                    'Sumber Anggaran'
                  ])
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        header,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                ],
              ),
              ...data.map((item) {
                final date = item['date'] ?? '-';
                final time = DateFormat.Hm().format(
                    DateTime.parse(item['created_at'] ?? item['date']));
                final amount = item['amount'].toString();

                final typeRaw = item['type'] ?? '-';
                final type = typeTranslation[typeRaw] ?? typeRaw;

                final category = item['category'] ?? '-';
                final note = item['note'] ?? '-';

                final sourceRaw = item['source'] ?? '-';
                final source = sourceTranslation[sourceRaw] ?? sourceRaw;

                return pw.TableRow(children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(date)),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(time)),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Rp $amount')),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(type)),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(category)),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(note)),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(source)),
                ]);
              }),
            ],
          ),
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

