import 'package:client_leger/services/settings/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get_it/get_it.dart';

class ScrabbleLogoImage extends StatelessWidget {
  const ScrabbleLogoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: Image(
          image: GetIt.instance<SettingService>().isLightMode
              ? const AssetImage(
                  'assets/images/scrabble-logo-client-web.png',
                )
              : const AssetImage(
                  'assets/images/white-logo.png',
                )),
    );
  }
}
// class ScrabbleLogoImage extends StatelessWidget {
//   const ScrabbleLogoImage({super.key});

//   @override
//   Widget build(BuildContext context) {

//   }
// }