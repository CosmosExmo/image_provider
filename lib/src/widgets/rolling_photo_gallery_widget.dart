import 'package:flutter/material.dart';
import 'package:focused_image_widget/focused_image_widget.dart';
import 'package:image_provider/image_provider.dart';
import 'package:provider/provider.dart';

import '../ui/views/camera_view/camera_viewmodel.dart';

class RollingGalleryShowCase extends StatefulWidget {
  final double width;
  final double height;
  final Map<int, CameraItemMetadata> photoCheckerMap;
  final Icon? suffixIcon;
  final Icon? prefixIcon;
  final int animationDurationInMilli;
  final bool rtl;
  final bool autoFocus;
  final bool closeSearchOnSuffixTap;
  final Color? color;
  final Color? textFieldColor;
  final Color? searchIconColor;
  final Color? textFieldIconColor;
  final bool boxShadow;

  const RollingGalleryShowCase({
    Key? key,

    /// The width cannot be null
    required this.width,

    /// The textController cannot be null
    this.suffixIcon,
    this.prefixIcon,

    /// Height of wrapper container
    this.height = 100,

    /// choose your custom color
    this.color = Colors.white,

    /// choose your custom color for the search when it is expanded
    this.textFieldColor = Colors.white,

    /// choose your custom color for the search when it is expanded
    this.searchIconColor = Colors.black,

    /// choose your custom color for the search when it is expanded
    this.textFieldIconColor = Colors.black,

    /// The onSuffixTap cannot be null
    this.animationDurationInMilli = 375,
    required this.photoCheckerMap,

    /// make the search bar to open from right to left
    this.rtl = false,

    /// make the keyboard to show automatically when the searchbar is expanded
    this.autoFocus = false,

    /// close the search on suffix tap
    this.closeSearchOnSuffixTap = false,

    /// enable/disable the box shadow decoration
    this.boxShadow = true,

    /// can add list of inputformatters to control the input
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RollingGalleryShowCaseBarState createState() =>
      _RollingGalleryShowCaseBarState();
}

///toggle - 0 => false or closed
///toggle 1 => true or open
int toggle = 0;

/// * use this variable to check current text from OnChange
String textFieldValue = '';

class _RollingGalleryShowCaseBarState extends State<RollingGalleryShowCase>
    with SingleTickerProviderStateMixin {
  ///initializing the AnimationController
  late AnimationController _con;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    ///Initializing the animationController which is responsible for the expanding and shrinking of the search bar
    _con = AnimationController(
      vsync: this,

      /// animationDurationInMilli is optional, the default value is 375
      duration: Duration(milliseconds: widget.animationDurationInMilli),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Container(
      height: widget.height,

      ///if the rtl is true, search bar will be from right to left
      alignment:
          widget.rtl ? Alignment.centerRight : const Alignment(-1.0, 0.0),

      ///Using Animated container to expand and shrink the widget
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.animationDurationInMilli),
        height: 70,
        width: (toggle == 0) ? 70 : widget.width,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          /// can add custom  color or the color will be white
          color: toggle == 1 ? widget.textFieldColor : widget.color,
          borderRadius: BorderRadius.circular(30.0),

          /// show boxShadow unless false was passed
          boxShadow: !widget.boxShadow
              ? null
              : [
                  const BoxShadow(
                    color: Colors.black26,
                    spreadRadius: -10.0,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: widget.animationDurationInMilli),
              left: (toggle == 0) ? 20.0 : 40.0,
              curve: Curves.easeOut,
              top: 11.0,
              child: AnimatedOpacity(
                opacity: (toggle == 0) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.topCenter,
                  width: widget.width / 1.3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 30),
                        ...widget.photoCheckerMap.entries.map((item) {
                          if(item.value.contentData == null) return Container();
                           final data = item.value.contentData;
                           return Padding(
                            padding: const EdgeInsets.only(right: 3.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                   ImageHolder(image: DecorationImage(image: AssetImage(data!.path!)),child: CircleAvatar(
                                        radius: 20.0,
                                        backgroundImage: data.path != null
                                            ? AssetImage(data.path!)
                                            : null,
                                      ),),
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: GestureDetector(
                                          onTap: () => context
                                              .read<CameraViewModel>()
                                              .removeImageByIndex(
                                                  item.key),
                                          child: const Icon(Icons.cancel,
                                              color: Colors.red, size: 18)),
                                    ),
                                  ],
                                ),
                                Text(item.value.title!),
                              ],
                            ),
                          );

                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ///Using material widget here to get the ripple effect on the prefix icon
            Material(
              /// can add custom color or the color will be white
              /// toggle button color based on toggle state
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30.0),
              child: IconButton(
                splashRadius: 19.0,
                iconSize: 60,

                ///if toggle is 1, which means it's open. so show the back icon, which will close it.
                ///if the toggle is 0, which means it's closed, so tapping on it will expand the widget.
                ///prefixIcon is of type Icon
                icon: widget.prefixIcon != null
                    ? toggle == 1
                        ? Icon(
                            Icons.arrow_back_ios,
                            color: widget.textFieldIconColor,
                          )
                        : widget.prefixIcon!
                    : Icon(
                        toggle == 1 ? Icons.arrow_back_ios : Icons.photo_album,
                        // search icon color when closed
                        color: Colors.white,
                        size: 35.0,
                      ),
                onPressed: () {
                  setState(
                    () {
                      ///if the search bar is closed
                      if (toggle == 0) {
                        toggle = 1;
                        ///forward == expand
                        _con.forward();
                      } else {
                        ///if the search bar is expanded
                        toggle = 0;
                        ///if the autoFocus is true, the keyboard will close, automatically
                        ///reverse == close
                        _con.reverse();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
