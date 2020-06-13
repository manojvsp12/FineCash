import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ProcessTransaction extends StatelessWidget {
  const ProcessTransaction({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllFieldsFormBloc(),
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
                    onPressed: () {},
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
      onSubmitting: (ctx, state) {
        //TODO update form submission
        formBloc.close();
      },
      onSuccess: (ctx, state) {},
      onFailure: (ctx, state) {
        Scaffold.of(ctx)
            .showSnackBar(SnackBar(content: Text(state.failureResponse)));
      },
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: <Widget>[
              TextFieldBlocBuilder(
                showSuggestionsWhenIsEmpty: false,
                clearTextIcon: Icon(Icons.clear),
                textFieldBloc: formBloc.text1,
                decoration: InputDecoration(
                  labelText: 'Account',
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              TextFieldBlocBuilder(
                showSuggestionsWhenIsEmpty: false,
                clearTextIcon: Icon(Icons.clear),
                textFieldBloc: formBloc.text1,
                decoration: InputDecoration(
                  labelText: 'Sub Account',
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              TextFieldBlocBuilder(
                showSuggestionsWhenIsEmpty: false,
                clearTextIcon: Icon(Icons.clear),
                textFieldBloc: formBloc.text1,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              DateTimeFieldBlocBuilder(
                clearIcon: Icon(Icons.clear),
                dateTimeFieldBloc: formBloc.dateAndTime1,
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
                selectFieldBloc: formBloc.select2,
                decoration: InputDecoration(
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
  final text1 = TextFieldBloc(
    suggestions: (pattern) {
      print(pattern);
      return Future.value(['acct1', 'acct2']);
    },
  );

  final boolean1 = BooleanFieldBloc();

  final boolean2 = BooleanFieldBloc();

  final select1 = SelectFieldBloc(
    items: ['Credit', 'Debit'],
  );

  final select2 = SelectFieldBloc(
    items: ['Credit', 'Debit'],
  );

  final multiSelect1 = MultiSelectFieldBloc<String, dynamic>(
    items: ['Credit', 'Debit'],
  );

  final date1 = InputFieldBloc<DateTime, Object>();

  final dateAndTime1 = InputFieldBloc<DateTime, Object>(initialValue: DateTime.now());

  final time1 = InputFieldBloc<TimeOfDay, Object>();

  AllFieldsFormBloc() {
    addFieldBlocs(fieldBlocs: [
      text1,
      boolean1,
      boolean2,
      select1,
      select2,
      multiSelect1,
      date1,
      dateAndTime1,
      time1,
    ]);
  }

  void addErrors() {
    text1.addError('Awesome Error!');
    boolean1.addError('Awesome Error!');
    boolean2.addError('Awesome Error!');
    select1.addError('Awesome Error!');
    select2.addError('Awesome Error!');
    multiSelect1.addError('Awesome Error!');
    date1.addError('Awesome Error!');
    dateAndTime1.addError('Awesome Error!');
    time1.addError('Awesome Error!');
  }

  @override
  void onSubmitting() async {
    try {
      await Future<void>.delayed(Duration(milliseconds: 500));

      emitSuccess(canSubmitAgain: true);
    } catch (e) {
      emitFailure();
    }
  }
}
