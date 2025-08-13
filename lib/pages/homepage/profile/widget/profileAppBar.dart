import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

class ProfileAppBar extends StatelessWidget {
  final void Function() onEdit;

  const ProfileAppBar({
    super.key,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: BColors.primaryColor,
      pinned: true,
      expandedHeight: 170,
      centerTitle: false,
      title: Text("Profile", style: Styles.h4WhiteBold),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          margin: const EdgeInsets.only(top: 80),
          child: ListTile(
            leading: userModel?.data!.user!.picture != null
                ? circular(
                    child: cachedImage(
                      context: context,
                      image: "${userModel!.data!.user!.picture}",
                      height: 60,
                      width: 60,
                      placeholder: Images.defaultProfilePicOffline,
                    ),
                    size: 60,
                  )
                : CircleAvatar(
                    backgroundColor: BColors.white,
                    radius: 30,
                    child: Text(
                      getDisplayName(),
                      style: Styles.h3BlackBold,
                    ),
                  ),
            title: Text(
              "${userModel!.data!.user!.name}",
              style: Styles.h5WhiteBold,
            ),
            subtitle: Text(
              "${userModel!.data!.user!.phone}",
              style: Styles.h6White,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: BColors.white,
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          height: 15,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: BColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
