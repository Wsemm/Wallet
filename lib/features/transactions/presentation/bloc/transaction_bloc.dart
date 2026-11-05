import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/core/di/injection.dart';
import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

export 'transaction_event.dart';
export 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;
  StreamSubscription<List<TransactionEntity>>? _subscription;
  StreamSubscription<List<TransactionGroupEntity>>? _subscriptionGroups;
  StreamSubscription? _transactionSubscription;
  List<TransactionEntity>? currentTrans;

  TransactionBloc(this._repository) : super(const TransactionState()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<TransactionsUpdated>(_onTransactionsUpdated);
    on<AddSelectedTransToArchive>(_addSelectedTransToArchive);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    await _subscription?.cancel();
    _subscription = _repository.watchAllTransactions().listen(
      (transactions) {
        TransactionGroupBloc bloc = sl<TransactionGroupBloc>();

        _transactionSubscription = bloc.stream.listen((transactionGroupState) {
          if (transactionGroupState.status == TransactionGroupStatus.loaded) {}
        });

        var transactionsGroups = bloc.state.transactionsGroups;

        // Map transactions to new instances with group details
        final updatedTransactions = transactions.map((transaction) {
          if (transaction.groupId == null || transactionsGroups.isEmpty) {
            return transaction;
          }

          // Find matching group using transaction.groupId
          final matchingGroup = transactionsGroups
              .where((group) => group.id == transaction.groupId)
              .firstOrNull; // Dart 3.0+ built-in property

          if (matchingGroup != null) {
            return transaction.copyWith(
              groupName: matchingGroup.name,
              groupDesc: matchingGroup.description,
            );
          }

          return transaction;
        }).toList();
        add(TransactionsUpdated(updatedTransactions));
        currentTrans = updatedTransactions;
      },
      onError: (error) {
        log(error.toString());
        emit(
          state.copyWith(
            status: TransactionStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  // Future<void> _onLoadTransactionsGroups(
  //   LoadTransactionsGroupsEvent event,
  //   Emitter<TransactionState> emit,
  // ) async {
  //   emit(state.copyWith(status: TransactionStatus.loading));
  //   await _subscriptionGroups?.cancel();
  //   _subscriptionGroups = _repository.watchAllTransactionsGroups().listen(
  //     (transactionsGroup) {
  //       add(TransactionGroupUpdated(transactionsGroup));
  //     },
  //     onError: (error) {
  //       log(error.toString());
  //       emit(
  //         state.copyWith(
  //           status: TransactionStatus.error,
  //           errorMessage: error.toString(),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<TransactionState> emit,
  ) {
    emit(
      state.copyWith(
        status: TransactionStatus.loaded,
        transactions: event.transactions,
      ),
    );
  }

  // void _onTransactionGroupUpdated(
  //   TransactionGroupUpdated event,
  //   Emitter<TransactionState> emit,
  // ) {
  //   emit(
  //     state.copyWith(
  //       status: TransactionStatus.loaded,
  //       transactionsGroups: event.transactionGroup,
  //     ),
  //   );
  // }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      int result = await _repository.insertTransaction(event.transaction);
      log("add opreation: $result");
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Future<void> _onAddTransactionGroup(
  //   AddTransactionGroupEvent event,
  //   Emitter<TransactionState> emit,
  // ) async {
  //   try {
  //     await _repository.insertTransactionGroup(event.transactionGroupEntity);
  //   } catch (e) {
  //     emit(
  //       state.copyWith(
  //         status: TransactionStatus.error,
  //         errorMessage: e.toString(),
  //       ),
  //     );
  //   }
  // }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.updateTransaction(event.transaction);
      emit(state.copyWith(status: TransactionStatus.updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.deleteTransaction(event.id);
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  _addSelectedTransToArchive(
    AddSelectedTransToArchive event,
    Emitter<TransactionState> state,
  ) {
    var updateTrabs = currentTrans;

    currentTrans!
        .where((element) => event.ids.contains(element.id))
        .forEach(
          (element) =>
              add(UpdateTransactionEvent(element.copyWith(isArchived: true))),
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
