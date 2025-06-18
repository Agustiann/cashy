import 'package:cashy/features/category/presentation/bloc/category_event.dart';
import 'package:cashy/features/category/presentation/bloc/category_state.dart';
import 'package:cashy/features/auth/presentation/widgets/snackbar_helper.dart';
import 'package:cashy/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:cashy/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:cashy/features/transaction/presentation/widgets/transaction_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/bloc/category_bloc.dart';

import '../bloc/transaction_bloc.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isExpense = true;

  List<Category> categories = [];

  // *** CHANGED ***
  // Simpan selected category name, bukan id
  String? selectedCategoryName;
  // Tetap simpan id juga untuk reference, tapi tidak untuk simpan ke transaksi
  String? selectedCategoryId;

  List<String> expenseTypes = [];
  String? selectedExpenseType;

  TextEditingController dateController = TextEditingController();

  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    context.read<TransactionBloc>().add(LoadSources());
  }

  void _loadCategories() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final userId = user.id;
    final type = isExpense ? 'expense' : 'income';
    context.read<CategoryBloc>().add(LoadCategories(userId, type));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is TransactionFailure) {
          showCustomSnackBar(
              context, 'Gagal simpan transaksi: ${state.message}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Tambah Transaksi",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryLoaded) {
              setState(() {
                categories = state.categories;

                if (categories.isNotEmpty) {
                  selectedCategoryId = categories.first.id; // *** CHANGED ***
                  selectedCategoryName = categories.first.name; // *** CHANGED ***
                }
              });
            }
          },
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = false;
                                _loadCategories();
                              });
                              context
                                  .read<TransactionBloc>()
                                  .add(LoadSources());
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: !isExpense ? Colors.green : Colors.white,
                                borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withAlpha(77),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Pemasukan',
                                style: GoogleFonts.montserrat(
                                  color:
                                      !isExpense ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = true;
                                _loadCategories();
                              });
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: isExpense ? Colors.red : Colors.white,
                                borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withAlpha(77),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Pengeluaran',
                                style: GoogleFonts.montserrat(
                                  color:
                                      isExpense ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isExpense)
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state is SourceLoading && expenseTypes.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is SourceLoaded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                expenseTypes = state.sources;
                                if (selectedExpenseType == null ||
                                    !expenseTypes
                                        .contains(selectedExpenseType)) {
                                  selectedExpenseType = expenseTypes.isNotEmpty
                                      ? expenseTypes.first
                                      : null;
                                }
                              });
                            }
                          });
                        } else if (state is SourceError &&
                            expenseTypes.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (expenseTypes.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              "Tipe pengeluaran tidak tersedia",
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        // Tampilkan dropdown dengan data yang sudah disimpan walaupun state bukan SourceLoaded
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tipe Pengeluaran",
                                style: GoogleFonts.montserrat(fontSize: 16),
                              ),
                              DropdownButton<String>(
                                value: selectedExpenseType,
                                isExpanded: true,
                                items: expenseTypes.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(getSourceLabel(value)),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedExpenseType = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (isExpense) const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, isExpense ? 0 : 0, 16, 0),
                    child: TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        CurrencyInputFormatter(
                          leadingSymbol: 'Rp',
                          useSymbolPadding: true,
                          thousandSeparator: ThousandSeparator.Period,
                          mantissaLength: 0,
                        ),
                      ],
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: "Total Dana",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Kategori",
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: selectedCategoryName, // *** CHANGED ***
                      isExpanded: true,
                      hint: const Text("Pilih kategori"),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: categories.map((Category cat) {
                        return DropdownMenuItem<String>(
                          value: cat.name, // *** CHANGED ***
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedCategoryName = value!; // *** CHANGED ***
                          selectedCategoryId = categories
                              .firstWhere((cat) => cat.name == value)
                              .id; // *** CHANGED, optional to keep id ***
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      readOnly: true,
                      controller: dateController,
                      decoration: const InputDecoration(labelText: "Tanggal"),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day),
                        );

                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);

                          dateController.text = formattedDate;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: noteController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        labelText: isExpense
                            ? "Detail Pengeluaran"
                            : "Detail Pemasukan",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final user = Supabase.instance.client.auth.currentUser;
                        if (user == null) {
                          showCustomSnackBar(context, 'User belum login');
                          return;
                        }

                        final amountText = amountController.text.trim();
                        final noteText = noteController.text.trim();
                        final dateText = dateController.text.trim();

                        if (amountText.isEmpty ||
                            selectedCategoryName == null || // *** CHANGED ***
                            dateText.isEmpty) {
                          showCustomSnackBar(context, 'Mohon isi semua data');
                          return;
                        }

                        final cleanAmountText =
                            amountText.replaceAll(RegExp(r'[^0-9]'), '');
                        final amount = double.tryParse(cleanAmountText);
                        if (amount == null) {
                          showCustomSnackBar(
                              context, 'Jumlah dana tidak valid');
                          return;
                        }

                        final date = DateTime.tryParse(dateText);
                        if (date == null) {
                          showCustomSnackBar(context, 'Tanggal tidak valid');
                          return;
                        }

                        context.read<TransactionBloc>().add(AddNewTransaction(
                              userId: user.id,
                              amount: amount,
                              category: selectedCategoryName!, // *** CHANGED ***
                              date: date,
                              note: noteText,
                              source: isExpense ? selectedExpenseType : null,
                            ));
                      },
                      child: const Text("Simpan"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
