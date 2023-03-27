import 'dart:io';

import 'package:flutter/material.dart';
import 'package:focused_image_widget/focused_image_widget.dart';
import 'package:image_provider/image_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/painting/image_provider.dart' as imgprov;
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
    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.centerRight,
      children: [
        toggle == 1
            ? SizedBox.shrink()
            : Material(
                /// can add custom color or the color will be white
                /// toggle button color based on toggle state
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30.0),
                child: IconButton(
                  splashRadius: 19.0,
                  iconSize: 60,
                  color: Colors.transparent.withOpacity(0),

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
                          toggle == 1
                              ? Icons.arrow_back_ios
                              : Icons.photo_album,
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
        AnimatedContainer(
          duration: Duration(milliseconds: widget.animationDurationInMilli),
          height: (toggle == 0) ? 0 : MediaQuery.of(context).size.height * 0.4,
          width: (toggle == 0) ? 0 : MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.grey.shade800.withOpacity(0.8),
          ),
          child: Stack(
            fit: StackFit.loose,
            children: [
              GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                children: [
                  if (toggle == 1)
                    ...widget.photoCheckerMap.entries.map((item) {
                      if (item.value.contentData == null) return Container();
                      final data = item.value.contentData;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              fit: StackFit.loose,
                              children: [
                                Builder(builder: (context) {
                                  late final imgprov.ImageProvider<Object> image;
                                  if (data?.path != null) {
                                    final file = File(data!.path!);
                                    image = MemoryImage(file.readAsBytesSync());
                                  }else {
                                    image = const AssetImage('image_provider_assets/imgs/placeholder.jpg',package: 'image_provider');
                                  }
                                  return ImageHolder(
                                      image: DecorationImage(
                                          image: image),
                                      child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .aspectRatio *
                                              175,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .aspectRatio *
                                              175,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: DecorationImage(
                                                  image: image,
                                                  fit: BoxFit.fill))));
                                }),
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: GestureDetector(
                                      onTap: () => context
                                          .read<CameraViewModel>()
                                          .removeImageByIndex(item.key),
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
              Positioned(
                top: -6,
                left: -6,
                child: IconButton(
                    onPressed: () {
                      setState(
                        () {
                          if (toggle == 0) {
                            toggle = 1;
                            _con.forward();
                          } else {
                            toggle = 0;
                            _con.reverse();
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.cancel)),
              )
            ],
          ),
        ),
      ],
    );
  }
}
