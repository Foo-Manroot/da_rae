import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class SlideMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;

  SlideMenu({this.child, this.menuItems});

  final _log = Logger ("SlideMenu.dart");

  @override
  _SlideMenuState createState() => new _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200)
    );
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = new Tween(
        begin: const Offset(0.0, 0.0),
        end: const Offset(-0.2, 0.0)
    ).animate(new CurveTween(curve: Curves.decelerate).animate(_controller));

    return new GestureDetector(
        onTap: (){
          _controller.animateTo(.0);
        },
        onHorizontalDragUpdate: (data) {
          // we can access context.size here
          setState(() {
            _controller.value -= data.primaryDelta / context.size.width;

            widget._log.fine ("Showing value of the animationController: $_controller.value");
          });
        },
        onHorizontalDragEnd: (data) {
          if (data.primaryVelocity > 2500)
            //close menu on fast swipe in the right direction
            _controller.animateTo(.0);
          // fully open if dragged a lot to left or on fast swipe to left
          else if (_controller.value >= .5 || data.primaryVelocity < -2500)
            _controller.animateTo(1.0);
          else // close if none of above
            _controller.animateTo(.0);
        },
        child: new Stack(
          children: <Widget>[
            new SlideTransition(position: animation, child: widget.child),
            new Positioned.fill(
              child: new LayoutBuilder(
                builder: (context, constraint) {
                  return new AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return new Stack(
                        children: <Widget>[
                          new Positioned(
                            right: .0,
                            top: .0,
                            bottom: .0,
                            width: constraint.maxWidth * 2 * animation.value.dx * -1,
                            child: new Container(
                              color: Color(0xFFFFFF),
                              alignment: Alignment.center,
                              child: new Row(
                                children: widget.menuItems.map((child) {
                                  return new Expanded(
                                    child: child,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      );
  }
}