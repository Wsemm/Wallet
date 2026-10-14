import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';
import 'package:wallet/features/transactionsGroup/domain/repositories/transaction_group_repository.dart';

part 'transaction_group_event.dart';
part 'transaction_group_state.dart';

class TransactionGroupBloc
    extends Bloc<TransactionGroupEvent, TransactionGroupState> {
  final TransactionGroupRepository _repository;

  StreamSubscription<List<TransactionGroupEntity>>? _subscriptionGroups;

  TransactionGroupBloc(this._repository) : super(TransactionGroupState()) {
    on<LoadTransactionsGroupsEvent>(_onLoadTransactionsGroups);
    on<TransactionGroupUpdated>(_onTransactionGroupUpdated);
    on<AddTransactionGroupEvent>(_onAddTransactionGroup);
    on<DeleteTransactionGroupEvent>(_onDeleteTransactionGroup);
    on<UpdateTransactionGroupEvent>(_onUpdateTransactionGroup);
  }

  Future<void> _onLoadTransactionsGroups(
    LoadTransactionsGroupsEvent event,
    Emitter<TransactionGroupState> emit,
  ) async {
    emit(state.copyWith(status: TransactionGroupStatus.loading));
    await _subscriptionGroups?.cancel();
    // await Future.delayed(Duration(seconds: 2));
    _subscriptionGroups = _repository.watchAllTransactionsGroups().listen(
      (transactionsGroup) {
        add(TransactionGroupUpdated(transactionsGroup));
      },
      onError: (error) {
        log(error.toString());
        emit(
          state.copyWith(
            status: TransactionGroupStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  void _onTransactionGroupUpdated(
    TransactionGroupUpdated event,
    Emitter<TransactionGroupState> emit,
  ) {
    emit(
      state.copyWith(
        status: TransactionGroupStatus.loaded,
        transactionsGroups: event.transactionGroup,
      ),
    );
  }

  Future<void> _onAddTransactionGroup(
    AddTransactionGroupEvent event,
    Emitter<TransactionGroupState> emit,
  ) async {
    try {
      await _repository.insertTransactionGroup(event.transactionGroupEntity);
      // add(LoadTransactionsGroupsEvent());
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionGroupStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteTransactionGroup(
    DeleteTransactionGroupEvent event,
    Emitter<TransactionGroupState> emit,
  ) async {
    try {
      await _repository.deleteTransactionGroup(event.id);
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionGroupStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateTransactionGroup(
    UpdateTransactionGroupEvent event,
    Emitter<TransactionGroupState> emit,
  ) async {
    try {
      var result = await _repository.updateTransactionGroup(
        event.transactionGroup,
      );
      emit(state.copyWith(status: TransactionGroupStatus.updated));
      log("group update status: $result");
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionGroupStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
