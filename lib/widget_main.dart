import 'package:flutter/material.dart';

class MainWrapperStateless extends StatelessWidget {
  MainWrapperStateless({super.key});

  late final TextTheme textTheme;

  void buildinit(BuildContext context) {
    try{
      textTheme;
    } catch(e) {
      // on LATE INIT error
      textTheme = Theme.of(context).textTheme;
    }
  }

  @override
  Widget build(BuildContext context) {

    return const Placeholder();
  }
}


class MainWrapperStateful extends StatefulWidget {
  MainWrapperStateful({super.key});

  Widget build(BuildContext context) {
    return const Placeholder();
  }

  late final Function(void Function() fn) setState;

  void dispose() {
  }

  void initState() {
    
  }

  late BuildContext context;

  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  State<MainWrapperStateful> createState() => _MainWrapperStatefulState();
}

class _MainWrapperStatefulState extends State<MainWrapperStateful> {


  @override
  Widget build(BuildContext context) {

    return widget.build(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    widget.dispose();
  }

  @override
  void initState() {
    super.initState();

    widget.setState = setState;
    widget.initState();
    widget.context = context;
  }
}