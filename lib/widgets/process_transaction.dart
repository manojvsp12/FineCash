import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:fine_cash/providers/txn_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:moor/moor.dart' as moor;
import 'package:line_awesome_icons/line_awesome_icons.dart';

class ProcessTransaction extends StatelessWidget {
  final BuildContext context;
  final FineCashRepository repo;
  final TxnProvider txnProvider;
  const ProcessTransaction({Key key, this.context, this.repo, this.txnProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllFieldsFormBloc(context, repo, txnProvider),
      child: Builder(
        builder: (context) {
          return Expanded(
            child: Scaffold(
              body: TransactionForm(context),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 12),
                  FloatingActionButton.extended(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    onPressed: () {
                      BlocProvider.of<AllFieldsFormBloc>(context).submit();
                    },
                    icon: Icon(Icons.send),
                    label: Text('SUBMIT'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TransactionForm extends StatelessWidget {
  final BuildContext ctx;

  TransactionForm(this.ctx);

  @override
  Widget build(BuildContext context) {
    final formBloc = BlocProvider.of<AllFieldsFormBloc>(ctx);
    return FormBlocListener<AllFieldsFormBloc, String, String>(
      onSubmitting: (ctx, state) {},
      onSuccess: (ctx, state) {
        Scaffold.of(ctx).showSnackBar(SnackBar(
            backgroundColor: Colors.greenAccent,
            content: Text('Transaction added successfully.')));
      },
      onFailure: (ctx, state) {
        // Scaffold.of(ctx).showSnackBar(SnackBar(
        //     backgroundColor: Colors.redAccent,
        //     content: Text('Failed to Sign in.')));
      },
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: <Widget>[
              TextFieldBlocBuilder(
                maxLength: 130,
                hideOnEmptySuggestions: true,
                hideOnLoadingSuggestions: true,
                showSuggestionsWhenIsEmpty: false,
                clearTextIcon: Icon(Icons.clear),
                textFieldBloc: formBloc.accountText,
                decoration: InputDecoration(
                  labelText: 'Account',
                  helperText: 'Account Head Name',
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              TextFieldBlocBuilder(
                maxLength: 130,
                hideOnEmptySuggestions: true,
                hideOnLoadingSuggestions: true,
                showSuggestionsWhenIsEmpty: false,
                clearTextIcon: Icon(Icons.clear),
                textFieldBloc: formBloc.subAccountText,
                decoration: InputDecoration(
                  labelText: 'Sub Account',
                  helperText: 'Sub Account Name',
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              TextFieldBlocBuilder(
                keyboardType: TextInputType.number,
                maxLength: 30,
                hideOnEmptySuggestions: true,
                hideOnLoadingSuggestions: true,
                showSuggestionsWhenIsEmpty: false,
                clearTextIcon: Icon(Icons.clear),
                textFieldBloc: formBloc.amount,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  helperText: 'Amount',
                  prefixIcon: Icon(LineAwesomeIcons.rupee),
                ),
              ),
              TextFieldBlocBuilder(
                maxLength: 200,
                hideOnEmptySuggestions: true,
                hideOnLoadingSuggestions: true,
                showSuggestionsWhenIsEmpty: false,
                clearTextIcon: Icon(Icons.clear),
                textFieldBloc: formBloc.descText,
                decoration: InputDecoration(
                  labelText: 'Description',
                  helperText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              DateTimeFieldBlocBuilder(
                clearIcon: Icon(Icons.clear),
                dateTimeFieldBloc: formBloc.dateAndTime,
                canSelectTime: true,
                format: DateFormat('dd-MM-yyyy  hh:mm'),
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                decoration: InputDecoration(
                  labelText: 'Date and Time',
                  prefixIcon: Icon(Icons.date_range),
                  helperText: 'Date and Time',
                ),
              ),
              RadioButtonGroupFieldBlocBuilder<String>(
                selectFieldBloc: formBloc.crOrDr,
                decoration: InputDecoration(
                  labelText: 'Credit or Debit',
                  helperText: 'Any one must be selected',
                  prefixIcon: SizedBox(),
                ),
                itemBuilder: (ctx, item) => item,
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class AllFieldsFormBloc extends FormBloc<String, String> {
  final BuildContext context;
  final FineCashRepository repo;
  TxnProvider txnProvider;
  TextFieldBloc accountText;
  TextFieldBloc subAccountText;
  TextFieldBloc descText;
  TextFieldBloc amount;
  InputFieldBloc<DateTime, Object> dateAndTime;
  SelectFieldBloc<String, dynamic> crOrDr;

  AllFieldsFormBloc(this.context, this.repo, this.txnProvider) {
    accountText = TextFieldBloc(
        suggestions: (_) =>
            Future.value(txnProvider.accountList.map((e) => e).toList()));
    subAccountText = TextFieldBloc(
        suggestions: (_) =>
            Future.value(txnProvider.subAccountList.map((e) => e).toList()));
    descText = TextFieldBloc();
    amount = TextFieldBloc();
    dateAndTime =
        InputFieldBloc<DateTime, Object>(initialValue: DateTime.now());
    crOrDr = SelectFieldBloc(
      items: ['Credit', 'Debit'],
    );
    addFieldBlocs(fieldBlocs: [
      accountText,
      subAccountText,
      amount,
      descText,
      dateAndTime,
      crOrDr
    ]);
  }

  @override
  void onSubmitting() async {
    var isError = false;
    try {
      if (accountText.value.isEmpty) {
        accountText.addError('Account Cannot be empty');
        isError = true;
      }
      if (subAccountText.value.isEmpty) {
        subAccountText.addError('Sub-Account Cannot be empty');
        isError = true;
      }
      if (amount.value.isEmpty) {
        amount.addError('Amount cannot be empty');
        isError = true;
      }
      if (crOrDr.value == null) {
        crOrDr.addError('Any one must be selected');
        isError = true;
      }
      if (isError)
        emitFailure();
      else {
        print('success');
        print(await repo.addTxn(TransactionsCompanion.insert(
          accountHead: accountText.value,
          subAccountHead: moor.Value(subAccountText.value),
          credit: crOrDr.value.toString() == 'Credit'
              ? moor.Value(amount.valueToDouble)
              : moor.Value.absent(),
          debit: crOrDr.value.toString() == 'Debit'
              ? moor.Value(amount.valueToDouble)
              : moor.Value.absent(),
          desc: moor.Value(descText.value),
        )));
        emitSuccess(canSubmitAgain: true);
      }
    } catch (e) {
      emitFailure();
    }
  }
}
