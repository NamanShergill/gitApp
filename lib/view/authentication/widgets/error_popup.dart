import 'package:dio_hub/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:dio_hub/common/animations/scale_expanded_widget.dart';
import 'package:dio_hub/view/authentication/widgets/base_auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorPopup extends StatelessWidget {
  final String error;
  const ErrorPopup(this.error, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ScaleExpandedSection(
      child: BaseAuthDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Error'.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(
              height: 32,
            ),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const Divider(
              height: 32,
            ),
            Center(
              child: MaterialButton(
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context)
                      .add(ResetStates());
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}