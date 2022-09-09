part of image_provider;

class RadialMenu extends StatefulWidget {
  final List<RadialMenuEntry> entries;
  final double size;
  final double entrySize;
  final IconData icon;

  const RadialMenu({
    Key? key,
    required this.entries,
    this.size = 160,
    this.entrySize = 85,
    this.icon = Icons.menu,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    Size subCategorySize = Size(widget.entrySize, widget.entrySize);
    Size mainSize = Size(widget.size, widget.size);

    return SizedBox(
      width: mainSize.width,
      height: mainSize.height,
      child: Stack(
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'togglePartners',
            elevation: 0,
            onPressed: () {
              setState(() {
                open = !open;
              });
            },
            child: Icon(widget.icon),
          ),
          if (open)
            ...widget.entries
                .asMap()
                .map(
                  (index, entry) => MapEntry(
                    index,
                    _CenterRotated(
                      angle: pi / 2 + index * pi / (widget.entries.length - 1),
                      size: subCategorySize,
                      parentSize: mainSize,
                      child: FloatingActionButton(
                        mini: true,
                        child: Icon(entry.icon),
                        onPressed: () {
                          entry.onTap!();
                          setState(() {
                            open = !open;
                          });
                        },
                      ),
                      /* child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .floatingActionButtonTheme
                              .backgroundColor,
                        ),
                        child: InkWell(
                          onTap: () {
                            entry.onTap();
                            setState(() {
                              open = !open;
                            });
                          },
                          child: Icon(
                            entry.icon,
                            color: Theme.of(context).accentIconTheme.color,
                          ),
                        ),
                      ), */
                    ),
                  ),
                )
                .values
                .toList()
        ],
      ),
    );
  }
}

class _CenterRotated extends StatelessWidget {
  final Size parentSize;
  final Size size;
  final double angle;
  final Widget? child;

  const _CenterRotated({
    this.angle = 0,
    required this.size,
    required this.parentSize,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      origin: Offset(
        parentSize.width / 2.1 - size.width / 1.9,
        parentSize.height / 2.1 - size.height / 1.9,
      ),
      child: SizedBox(
        width: size.width / 1.8,
        height: size.height / 1.8,
        child: Transform.rotate(
          angle: -angle,
          child: child,
        ),
      ),
    );
  }
}

class RadialMenuEntry {
  final Function? onTap;
  final IconData icon;
  final double iconSize;

  RadialMenuEntry({
    this.onTap,
    required this.icon,
    iconColor,
    this.iconSize = 24,
  });
}
