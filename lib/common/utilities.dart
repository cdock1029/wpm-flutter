import 'package:flutter/widgets.dart';

class SystemPadding extends StatelessWidget {
  final Widget child;

  const SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 200),
        child: child);
  }
}
