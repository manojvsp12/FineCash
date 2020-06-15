// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fine_cash_repo.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final String accountHead;
  final String subAccountHead;
  final String desc;
  final double credit;
  final double debit;
  final DateTime createdDTime;
  final bool isSynced;
  final String txnOwner;
  Transaction(
      {@required this.id,
      @required this.accountHead,
      this.subAccountHead,
      this.desc,
      this.credit,
      this.debit,
      @required this.createdDTime,
      @required this.isSynced,
      @required this.txnOwner});
  factory Transaction.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Transaction(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      accountHead: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}account_head']),
      subAccountHead: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}sub_account_head']),
      desc: stringType.mapFromDatabaseResponse(data['${effectivePrefix}desc']),
      credit:
          doubleType.mapFromDatabaseResponse(data['${effectivePrefix}credit']),
      debit:
          doubleType.mapFromDatabaseResponse(data['${effectivePrefix}debit']),
      createdDTime: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_d_time']),
      isSynced:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}is_synced']),
      txnOwner: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}txn_owner']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || accountHead != null) {
      map['account_head'] = Variable<String>(accountHead);
    }
    if (!nullToAbsent || subAccountHead != null) {
      map['sub_account_head'] = Variable<String>(subAccountHead);
    }
    if (!nullToAbsent || desc != null) {
      map['desc'] = Variable<String>(desc);
    }
    if (!nullToAbsent || credit != null) {
      map['credit'] = Variable<double>(credit);
    }
    if (!nullToAbsent || debit != null) {
      map['debit'] = Variable<double>(debit);
    }
    if (!nullToAbsent || createdDTime != null) {
      map['created_d_time'] = Variable<DateTime>(createdDTime);
    }
    if (!nullToAbsent || isSynced != null) {
      map['is_synced'] = Variable<bool>(isSynced);
    }
    if (!nullToAbsent || txnOwner != null) {
      map['txn_owner'] = Variable<String>(txnOwner);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      accountHead: accountHead == null && nullToAbsent
          ? const Value.absent()
          : Value(accountHead),
      subAccountHead: subAccountHead == null && nullToAbsent
          ? const Value.absent()
          : Value(subAccountHead),
      desc: desc == null && nullToAbsent ? const Value.absent() : Value(desc),
      credit:
          credit == null && nullToAbsent ? const Value.absent() : Value(credit),
      debit:
          debit == null && nullToAbsent ? const Value.absent() : Value(debit),
      createdDTime: createdDTime == null && nullToAbsent
          ? const Value.absent()
          : Value(createdDTime),
      isSynced: isSynced == null && nullToAbsent
          ? const Value.absent()
          : Value(isSynced),
      txnOwner: txnOwner == null && nullToAbsent
          ? const Value.absent()
          : Value(txnOwner),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      accountHead: serializer.fromJson<String>(json['accountHead']),
      subAccountHead: serializer.fromJson<String>(json['subAccountHead']),
      desc: serializer.fromJson<String>(json['desc']),
      credit: serializer.fromJson<double>(json['credit']),
      debit: serializer.fromJson<double>(json['debit']),
      createdDTime: serializer.fromJson<DateTime>(json['createdDTime']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      txnOwner: serializer.fromJson<String>(json['txnOwner']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountHead': serializer.toJson<String>(accountHead),
      'subAccountHead': serializer.toJson<String>(subAccountHead),
      'desc': serializer.toJson<String>(desc),
      'credit': serializer.toJson<double>(credit),
      'debit': serializer.toJson<double>(debit),
      'createdDTime': serializer.toJson<DateTime>(createdDTime),
      'isSynced': serializer.toJson<bool>(isSynced),
      'txnOwner': serializer.toJson<String>(txnOwner),
    };
  }

  Transaction copyWith(
          {int id,
          String accountHead,
          String subAccountHead,
          String desc,
          double credit,
          double debit,
          DateTime createdDTime,
          bool isSynced,
          String txnOwner}) =>
      Transaction(
        id: id ?? this.id,
        accountHead: accountHead ?? this.accountHead,
        subAccountHead: subAccountHead ?? this.subAccountHead,
        desc: desc ?? this.desc,
        credit: credit ?? this.credit,
        debit: debit ?? this.debit,
        createdDTime: createdDTime ?? this.createdDTime,
        isSynced: isSynced ?? this.isSynced,
        txnOwner: txnOwner ?? this.txnOwner,
      );
  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('accountHead: $accountHead, ')
          ..write('subAccountHead: $subAccountHead, ')
          ..write('desc: $desc, ')
          ..write('credit: $credit, ')
          ..write('debit: $debit, ')
          ..write('createdDTime: $createdDTime, ')
          ..write('isSynced: $isSynced, ')
          ..write('txnOwner: $txnOwner')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          accountHead.hashCode,
          $mrjc(
              subAccountHead.hashCode,
              $mrjc(
                  desc.hashCode,
                  $mrjc(
                      credit.hashCode,
                      $mrjc(
                          debit.hashCode,
                          $mrjc(
                              createdDTime.hashCode,
                              $mrjc(
                                  isSynced.hashCode, txnOwner.hashCode)))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.accountHead == this.accountHead &&
          other.subAccountHead == this.subAccountHead &&
          other.desc == this.desc &&
          other.credit == this.credit &&
          other.debit == this.debit &&
          other.createdDTime == this.createdDTime &&
          other.isSynced == this.isSynced &&
          other.txnOwner == this.txnOwner);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String> accountHead;
  final Value<String> subAccountHead;
  final Value<String> desc;
  final Value<double> credit;
  final Value<double> debit;
  final Value<DateTime> createdDTime;
  final Value<bool> isSynced;
  final Value<String> txnOwner;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.accountHead = const Value.absent(),
    this.subAccountHead = const Value.absent(),
    this.desc = const Value.absent(),
    this.credit = const Value.absent(),
    this.debit = const Value.absent(),
    this.createdDTime = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.txnOwner = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    @required String accountHead,
    this.subAccountHead = const Value.absent(),
    this.desc = const Value.absent(),
    this.credit = const Value.absent(),
    this.debit = const Value.absent(),
    this.createdDTime = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.txnOwner = const Value.absent(),
  }) : accountHead = Value(accountHead);
  static Insertable<Transaction> custom({
    Expression<int> id,
    Expression<String> accountHead,
    Expression<String> subAccountHead,
    Expression<String> desc,
    Expression<double> credit,
    Expression<double> debit,
    Expression<DateTime> createdDTime,
    Expression<bool> isSynced,
    Expression<String> txnOwner,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountHead != null) 'account_head': accountHead,
      if (subAccountHead != null) 'sub_account_head': subAccountHead,
      if (desc != null) 'desc': desc,
      if (credit != null) 'credit': credit,
      if (debit != null) 'debit': debit,
      if (createdDTime != null) 'created_d_time': createdDTime,
      if (isSynced != null) 'is_synced': isSynced,
      if (txnOwner != null) 'txn_owner': txnOwner,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int> id,
      Value<String> accountHead,
      Value<String> subAccountHead,
      Value<String> desc,
      Value<double> credit,
      Value<double> debit,
      Value<DateTime> createdDTime,
      Value<bool> isSynced,
      Value<String> txnOwner}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      accountHead: accountHead ?? this.accountHead,
      subAccountHead: subAccountHead ?? this.subAccountHead,
      desc: desc ?? this.desc,
      credit: credit ?? this.credit,
      debit: debit ?? this.debit,
      createdDTime: createdDTime ?? this.createdDTime,
      isSynced: isSynced ?? this.isSynced,
      txnOwner: txnOwner ?? this.txnOwner,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountHead.present) {
      map['account_head'] = Variable<String>(accountHead.value);
    }
    if (subAccountHead.present) {
      map['sub_account_head'] = Variable<String>(subAccountHead.value);
    }
    if (desc.present) {
      map['desc'] = Variable<String>(desc.value);
    }
    if (credit.present) {
      map['credit'] = Variable<double>(credit.value);
    }
    if (debit.present) {
      map['debit'] = Variable<double>(debit.value);
    }
    if (createdDTime.present) {
      map['created_d_time'] = Variable<DateTime>(createdDTime.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (txnOwner.present) {
      map['txn_owner'] = Variable<String>(txnOwner.value);
    }
    return map;
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  final GeneratedDatabase _db;
  final String _alias;
  $TransactionsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _accountHeadMeta =
      const VerificationMeta('accountHead');
  GeneratedTextColumn _accountHead;
  @override
  GeneratedTextColumn get accountHead =>
      _accountHead ??= _constructAccountHead();
  GeneratedTextColumn _constructAccountHead() {
    return GeneratedTextColumn(
      'account_head',
      $tableName,
      false,
    );
  }

  final VerificationMeta _subAccountHeadMeta =
      const VerificationMeta('subAccountHead');
  GeneratedTextColumn _subAccountHead;
  @override
  GeneratedTextColumn get subAccountHead =>
      _subAccountHead ??= _constructSubAccountHead();
  GeneratedTextColumn _constructSubAccountHead() {
    return GeneratedTextColumn(
      'sub_account_head',
      $tableName,
      true,
    );
  }

  final VerificationMeta _descMeta = const VerificationMeta('desc');
  GeneratedTextColumn _desc;
  @override
  GeneratedTextColumn get desc => _desc ??= _constructDesc();
  GeneratedTextColumn _constructDesc() {
    return GeneratedTextColumn(
      'desc',
      $tableName,
      true,
    );
  }

  final VerificationMeta _creditMeta = const VerificationMeta('credit');
  GeneratedRealColumn _credit;
  @override
  GeneratedRealColumn get credit => _credit ??= _constructCredit();
  GeneratedRealColumn _constructCredit() {
    return GeneratedRealColumn(
      'credit',
      $tableName,
      true,
    );
  }

  final VerificationMeta _debitMeta = const VerificationMeta('debit');
  GeneratedRealColumn _debit;
  @override
  GeneratedRealColumn get debit => _debit ??= _constructDebit();
  GeneratedRealColumn _constructDebit() {
    return GeneratedRealColumn(
      'debit',
      $tableName,
      true,
    );
  }

  final VerificationMeta _createdDTimeMeta =
      const VerificationMeta('createdDTime');
  GeneratedDateTimeColumn _createdDTime;
  @override
  GeneratedDateTimeColumn get createdDTime =>
      _createdDTime ??= _constructCreatedDTime();
  GeneratedDateTimeColumn _constructCreatedDTime() {
    return GeneratedDateTimeColumn('created_d_time', $tableName, false,
        defaultValue: currentDateAndTime);
  }

  final VerificationMeta _isSyncedMeta = const VerificationMeta('isSynced');
  GeneratedBoolColumn _isSynced;
  @override
  GeneratedBoolColumn get isSynced => _isSynced ??= _constructIsSynced();
  GeneratedBoolColumn _constructIsSynced() {
    return GeneratedBoolColumn('is_synced', $tableName, false,
        defaultValue: Constant(false));
  }

  final VerificationMeta _txnOwnerMeta = const VerificationMeta('txnOwner');
  GeneratedTextColumn _txnOwner;
  @override
  GeneratedTextColumn get txnOwner => _txnOwner ??= _constructTxnOwner();
  GeneratedTextColumn _constructTxnOwner() {
    return GeneratedTextColumn(
      'txn_owner',
      $tableName,
      false,
    )..clientDefault = () => user;
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountHead,
        subAccountHead,
        desc,
        credit,
        debit,
        createdDTime,
        isSynced,
        txnOwner
      ];
  @override
  $TransactionsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'transactions';
  @override
  final String actualTableName = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('account_head')) {
      context.handle(
          _accountHeadMeta,
          accountHead.isAcceptableOrUnknown(
              data['account_head'], _accountHeadMeta));
    } else if (isInserting) {
      context.missing(_accountHeadMeta);
    }
    if (data.containsKey('sub_account_head')) {
      context.handle(
          _subAccountHeadMeta,
          subAccountHead.isAcceptableOrUnknown(
              data['sub_account_head'], _subAccountHeadMeta));
    }
    if (data.containsKey('desc')) {
      context.handle(
          _descMeta, desc.isAcceptableOrUnknown(data['desc'], _descMeta));
    }
    if (data.containsKey('credit')) {
      context.handle(_creditMeta,
          credit.isAcceptableOrUnknown(data['credit'], _creditMeta));
    }
    if (data.containsKey('debit')) {
      context.handle(
          _debitMeta, debit.isAcceptableOrUnknown(data['debit'], _debitMeta));
    }
    if (data.containsKey('created_d_time')) {
      context.handle(
          _createdDTimeMeta,
          createdDTime.isAcceptableOrUnknown(
              data['created_d_time'], _createdDTimeMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced'], _isSyncedMeta));
    }
    if (data.containsKey('txn_owner')) {
      context.handle(_txnOwnerMeta,
          txnOwner.isAcceptableOrUnknown(data['txn_owner'], _txnOwnerMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Transaction.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(_db, alias);
  }
}

class MetaData extends DataClass implements Insertable<MetaData> {
  final int id;
  final String accountHead;
  final String icon;
  final int color;
  MetaData(
      {@required this.id,
      @required this.accountHead,
      @required this.icon,
      @required this.color});
  factory MetaData.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return MetaData(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      accountHead: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}account_head']),
      icon: stringType.mapFromDatabaseResponse(data['${effectivePrefix}icon']),
      color: intType.mapFromDatabaseResponse(data['${effectivePrefix}color']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || accountHead != null) {
      map['account_head'] = Variable<String>(accountHead);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    return map;
  }

  MetaDatasCompanion toCompanion(bool nullToAbsent) {
    return MetaDatasCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      accountHead: accountHead == null && nullToAbsent
          ? const Value.absent()
          : Value(accountHead),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
    );
  }

  factory MetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return MetaData(
      id: serializer.fromJson<int>(json['id']),
      accountHead: serializer.fromJson<String>(json['accountHead']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountHead': serializer.toJson<String>(accountHead),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
    };
  }

  MetaData copyWith({int id, String accountHead, String icon, int color}) =>
      MetaData(
        id: id ?? this.id,
        accountHead: accountHead ?? this.accountHead,
        icon: icon ?? this.icon,
        color: color ?? this.color,
      );
  @override
  String toString() {
    return (StringBuffer('MetaData(')
          ..write('id: $id, ')
          ..write('accountHead: $accountHead, ')
          ..write('icon: $icon, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(id.hashCode,
      $mrjc(accountHead.hashCode, $mrjc(icon.hashCode, color.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is MetaData &&
          other.id == this.id &&
          other.accountHead == this.accountHead &&
          other.icon == this.icon &&
          other.color == this.color);
}

class MetaDatasCompanion extends UpdateCompanion<MetaData> {
  final Value<int> id;
  final Value<String> accountHead;
  final Value<String> icon;
  final Value<int> color;
  const MetaDatasCompanion({
    this.id = const Value.absent(),
    this.accountHead = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
  });
  MetaDatasCompanion.insert({
    this.id = const Value.absent(),
    @required String accountHead,
    @required String icon,
    @required int color,
  })  : accountHead = Value(accountHead),
        icon = Value(icon),
        color = Value(color);
  static Insertable<MetaData> custom({
    Expression<int> id,
    Expression<String> accountHead,
    Expression<String> icon,
    Expression<int> color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountHead != null) 'account_head': accountHead,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
    });
  }

  MetaDatasCompanion copyWith(
      {Value<int> id,
      Value<String> accountHead,
      Value<String> icon,
      Value<int> color}) {
    return MetaDatasCompanion(
      id: id ?? this.id,
      accountHead: accountHead ?? this.accountHead,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountHead.present) {
      map['account_head'] = Variable<String>(accountHead.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }
}

class $MetaDatasTable extends MetaDatas
    with TableInfo<$MetaDatasTable, MetaData> {
  final GeneratedDatabase _db;
  final String _alias;
  $MetaDatasTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _accountHeadMeta =
      const VerificationMeta('accountHead');
  GeneratedTextColumn _accountHead;
  @override
  GeneratedTextColumn get accountHead =>
      _accountHead ??= _constructAccountHead();
  GeneratedTextColumn _constructAccountHead() {
    return GeneratedTextColumn(
      'account_head',
      $tableName,
      false,
    );
  }

  final VerificationMeta _iconMeta = const VerificationMeta('icon');
  GeneratedTextColumn _icon;
  @override
  GeneratedTextColumn get icon => _icon ??= _constructIcon();
  GeneratedTextColumn _constructIcon() {
    return GeneratedTextColumn(
      'icon',
      $tableName,
      false,
    );
  }

  final VerificationMeta _colorMeta = const VerificationMeta('color');
  GeneratedIntColumn _color;
  @override
  GeneratedIntColumn get color => _color ??= _constructColor();
  GeneratedIntColumn _constructColor() {
    return GeneratedIntColumn(
      'color',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [id, accountHead, icon, color];
  @override
  $MetaDatasTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'meta_datas';
  @override
  final String actualTableName = 'meta_datas';
  @override
  VerificationContext validateIntegrity(Insertable<MetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('account_head')) {
      context.handle(
          _accountHeadMeta,
          accountHead.isAcceptableOrUnknown(
              data['account_head'], _accountHeadMeta));
    } else if (isInserting) {
      context.missing(_accountHeadMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon'], _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color'], _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetaData map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return MetaData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $MetaDatasTable createAlias(String alias) {
    return $MetaDatasTable(_db, alias);
  }
}

abstract class _$FineCashRepository extends GeneratedDatabase {
  _$FineCashRepository(QueryExecutor e)
      : super(SqlTypeSystem.defaultInstance, e);
  $TransactionsTable _transactions;
  $TransactionsTable get transactions =>
      _transactions ??= $TransactionsTable(this);
  $MetaDatasTable _metaDatas;
  $MetaDatasTable get metaDatas => _metaDatas ??= $MetaDatasTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [transactions, metaDatas];
}
