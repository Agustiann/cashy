import 'package:cashy/features/category/domain/usecases/category_usecases.dart';
import 'package:cashy/features/category/domain/usecases/delete_category.dart';
import 'package:cashy/features/category/domain/usecases/update_category.dart';
import 'package:cashy/features/financial_report/data/datasources/report_remote_datasource.dart';
import 'package:cashy/features/financial_report/data/repositories/report_repository_impl.dart';
import 'package:cashy/features/financial_report/domain/usecases/report_usecase.dart';
import 'package:cashy/features/financial_report/presentation/bloc/report_bloc.dart';
import 'package:cashy/features/pos/data/datasources/pos_remote_datasource.dart';
import 'package:cashy/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:cashy/features/pos/domain/usecases/pos_usecase.dart';
import 'package:cashy/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:cashy/features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'package:cashy/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:cashy/features/transaction/domain/usecases/transaction_usecases.dart';
import 'package:cashy/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/auth_usecase.dart';
import 'features/auth/presentation/screens/login_page.dart';

import 'features/category/data/datasources/category_remote_datasource.dart';
import 'features/category/data/repositories/category_repository_impl.dart';
import 'features/category/domain/usecases/add_category.dart';
import 'features/category/presentation/bloc/category_bloc.dart';

import 'features/home/data/datasources/home_remote_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/usecases/get_transaction.dart';
import 'features/home/domain/usecases/get_budget_summary.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://cfhslshehhrvotayalpb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNmaHNsc2hlaGhydm90YXlhbHBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA1Mzk0MTUsImV4cCI6MjA1NjExNTQxNX0.Ddz5JDiRJ6VJc05OKHtR4twBMWR27A28uolM_SoS8-8',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;

    // Transaction feature
    final transactionRemoteDataSource =
        TransactionRemoteDataSourceImpl(supabaseClient);
    final transactionRepository =
        TransactionRepositoryImpl(transactionRemoteDataSource);
    final addTransactionUseCase = AddTransaction(transactionRepository);

    // Category feature
    final categoryRemoteDataSource =
        CategoryRemoteDataSourceImpl(supabaseClient);
    final categoryRepository = CategoryRepositoryImpl(categoryRemoteDataSource);

    // Home feature
    final homeRemoteDataSource = HomeRemoteDataSourceImpl(supabaseClient);
    final homeRepository = HomeRepositoryImpl(homeRemoteDataSource);
    final getTransactionsByDate = GetTransactionsByDate(homeRepository);
    final getBudgetSummary = GetBudgetSummary(homeRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(
            loginUseCase: LoginUseCase(
              AuthRepositoryImpl(
                AuthRemoteDataSourceImpl(supabaseClient),
              ),
            ),
            remoteDataSource: AuthRemoteDataSourceImpl(supabaseClient),
          ),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(
            getCategories: GetCategories(categoryRepository),
            addCategory: AddCategory(categoryRepository),
            deleteCategory: DeleteCategory(categoryRepository),
            updateCategory: UpdateCategory(categoryRepository),
          ),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) =>
              TransactionBloc(addTransactionUseCase: addTransactionUseCase),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(
            getTransactionsByDate: getTransactionsByDate,
            getBudgetSummary: getBudgetSummary,
          ),
        ),
        BlocProvider<PosBloc>(
          create: (context) => PosBloc(
            getPosSummary: GetPosSummary(
              PosRepositoryImpl(
                PosRemoteDataSourceImpl(Supabase.instance.client),
              ),
            ),
          ),
        ),
        BlocProvider<ReportBloc>(
          create: (context) => ReportBloc(
            ReportUseCase(
              ReportRepositoryImpl(
                ReportRemoteDatasource(Supabase.instance.client),
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        home: LoginPage(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade400),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
