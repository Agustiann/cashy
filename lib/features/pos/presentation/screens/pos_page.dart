import 'package:cashy/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:cashy/features/pos/presentation/bloc/pos_event.dart';
import 'package:cashy/features/pos/presentation/bloc/pos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/pos_format_currency.dart';

class PosPage extends StatelessWidget {
  const PosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    context.read<PosBloc>().add(LoadPosEvent(userId));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<PosBloc, PosState>(
          builder: (context, state) {
            if (state is PosLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PosLoaded) {
              final data = state.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Dana',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency(data.needs + data.wants + data.savings),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCard(
                    context: context,
                    title: 'Kebutuhan',
                    amount: formatCurrency(data.needs),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context: context,
                    title: 'Keinginan',
                    amount: formatCurrency(data.wants),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context: context,
                    title: 'Tabungan',
                    amount: formatCurrency(data.savings),
                    color: Colors.red,
                  ),
                ],
              );
            } else if (state is PosError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String amount,
    required Color color,
    required BuildContext context,
  }) {
    String description = '';
    if (title == 'Kebutuhan') {
      description =
          'Dana untuk biaya hidup seperti sewa, tagihan, transportasi, makanan, dan kebutuhan sehari-hari.';
    } else if (title == 'Keinginan') {
      description =
          'Dana untuk keinginan, seperti hiburan, belanja barang, dan keinginan lainnya.';
    } else if (title == 'Tabungan') {
      description =
          'Dana untuk kebutuhan darurat, menabung, berinvestasi, atau melunasi utang.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ]),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(title),
                  content: Text(description),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(77),
              foregroundColor: Colors.white,
            ),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }
}
