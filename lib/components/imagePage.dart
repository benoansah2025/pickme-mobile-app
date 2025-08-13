import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';
import 'cachedImage.dart';

class ImagePage extends StatelessWidget {
  final String? image, title;
  final String? heroTag;
  final Color? backgroundColor;

  const ImagePage({
    super.key,
    @required this.image,
    @required this.title,
    this.heroTag,
    this.backgroundColor = BColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag ?? "non",
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          iconTheme: IconThemeData(
            color: backgroundColor == BColors.white ? BColors.black : BColors.white,
          ),
        ),
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            InteractiveViewer(
              child: cachedImage(
                context: context,
                height: MediaQuery.of(context).size.height,
                image: image,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
                placeholder: Images.imageLoadingError,
              ),
            ),
            if (title != null && title != "")
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  color: BColors.black.withOpacity(.6),
                  child: Text(
                    "$title",
                    style: Styles.h4White,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
