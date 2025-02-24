import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/counter_bloc.dart';
import 'bloc/counter_event.dart';
import 'bloc/counter_state.dart';

class CounterScreen extends StatefulWidget {
  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  Timer? _timer;
  bool _isRocketFlying = false;
  double _rocketPosition = 0;
  final GlobalKey _counterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _rocketPosition = MediaQuery.of(context).size.height;
      });
    });
  }

  void _startIncrement(BuildContext context) {
    setState(() {
      _isRocketFlying = true;
      _updateRocketPosition();
    });
    context.read<CounterBloc>().add(IncrementEvent());
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      context.read<CounterBloc>().add(IncrementEvent());
    });
  }

  void _startDecrement(BuildContext context) {
    setState(() {
      _isRocketFlying = true;
      _updateRocketPosition();
    });
    context.read<CounterBloc>().add(DecrementEvent());
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      context.read<CounterBloc>().add(DecrementEvent());
    });
  }

  void _stopAction() {
    _timer?.cancel();
    setState(() {
      _rocketPosition = MediaQuery.of(context).size.height;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isRocketFlying = false;
        });
      }
    });
  }

  void _updateRocketPosition() {
    final RenderBox? renderBox = _counterKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      _rocketPosition = position.dy - 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.black87],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            top: _rocketPosition,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: _isRocketFlying
                ? Icon(Icons.rocket_launch, size: 50, color: Colors.redAccent)
                : SizedBox(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<CounterBloc, CounterState>(
                  builder: (context, state) {
                    return Text(
                      '${state.counter}',
                      key: _counterKey,
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.blueAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.read<CounterBloc>().add(DecrementEvent()),
                      onLongPressStart: (_) => _startDecrement(context),
                      onLongPressEnd: (_) => _stopAction(),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(Icons.remove, size: 40, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 50),
                    GestureDetector(
                      onTap: () => context.read<CounterBloc>().add(IncrementEvent()),
                      onLongPressStart: (_) => _startIncrement(context),
                      onLongPressEnd: (_) => _stopAction(),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.greenAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(Icons.add, size: 40, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}