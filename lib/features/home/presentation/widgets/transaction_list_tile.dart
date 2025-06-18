import 'package:flutter/material.dart';
import '../../domain/entities/home_entity.dart';
import 'package:intl/intl.dart';
import 'package:cashy/features/pos/presentation/widgets/pos_format_currency.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionListTile({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm('id_ID').format(transaction.createdAt);
    return Card(
      elevation: 4,
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          transaction.type == 'income' ? Icons.download : Icons.upload,
          color: transaction.type == 'income' ? Colors.green : Colors.red,
        ),
        title: Text(formatCurrency(transaction.amount)),
        subtitle: Text(transaction.note ?? ''),
        trailing: Text(time, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
