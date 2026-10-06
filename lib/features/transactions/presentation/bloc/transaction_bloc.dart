import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

export 'transaction_event.dart';
export 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;
  StreamSubscription<List<TransactionEntity>>? _subscription;

  TransactionBloc(this._repository) : super(const TransactionState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<TransactionsUpdated>(_onTransactionsUpdated);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    await _subscription?.cancel();
    _subscription = _repository.watchAllTransactions().listen(
      (transactions) {
        add(TransactionsUpdated(transactions));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: TransactionStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(
      status: TransactionStatus.loaded,
      transactions: event.transactions,
    ));
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.insertTransaction(event.transaction);
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.deleteTransaction(event.id);
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
