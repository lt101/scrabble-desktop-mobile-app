import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/user-info/avatar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import 'sign_in_view.dart';

class AvatarOption extends StatefulWidget {
  AvatarOption(
      {super.key,
      required this.userName_,
      required this.isNewAccount,
      this.callback});
  final String userName_;
  final bool isNewAccount;
  StringCallback? callback;

  @override
  State<AvatarOption> createState() => _AvatarOptionState();
}

typedef void StringCallback(String avatarURL);

class _AvatarOptionState extends State<AvatarOption> {
  late String chosenAvatar;
  int selectedAvatar = -1;
  List<String> urlList = [];
  List<Image> imagesList = [];
  AvatarService avatarService = AvatarService();
  Future<bool>? _isComplete;

  @override
  void initState() {
    setURLs();
    super.initState();
  }

  @override
  void dispose() {
    if (urlList.isNotEmpty) {
      urlList.clear();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    for (Image image in imagesList) {
      precacheImage(image.image, context);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Scaffold(body: showProfilPictureOptions()),
    );
  }

  void setURLs() {
    urlList = [
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_1.jpg?alt=media&token=5f5f4122-705b-43a2-885c-1e427a787190',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_10.jpg?alt=media&token=7559a902-c99f-43a9-81d8-313e0fd297d5',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_11.jpg?alt=media&token=33171d95-fcaa-40d2-8f54-2aaa0bc106a3',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_12.jpg?alt=media&token=1aa7fa80-f5c1-4adf-b457-673bbb82aec9',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_13.jpg?alt=media&token=e4bbdbd2-9321-4627-9991-9f569cbd5f14',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_2.jpg?alt=media&token=034e39cb-91f4-4835-8239-171210151b94',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_3.jpg?alt=media&token=036565d1-5702-43c8-bf24-a9f2c82c0c07',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_4.jpg?alt=media&token=683738d0-6b24-41bd-9597-35a0f8d0bda2',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_5.jpg?alt=media&token=8c020d2a-e6cd-4d73-9cf8-27ae146747c1',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_6.jpg?alt=media&token=738255a0-fe3f-498c-9bd5-782483665a0f',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_7.jpg?alt=media&token=ee93afa3-56e6-4764-9463-330f63ca01fb',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_8.png?alt=media&token=3e306ae1-c8d9-47fd-8059-4d77fd3f9ef6',
      'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_9.jpg?alt=media&token=b7488b15-b5d7-46b8-b424-06fd7f88dada'
    ];
    for (String url in urlList) {
      imagesList.add(Image.network(url));
    }
    setState(() {
      _isComplete = Future.value(true);
    });
  }

  Widget showProfilPictureOptions() {
    String buttonText = widget.isNewAccount
        ? AppLocalizations.of(context)!.next
        : AppLocalizations.of(context)!.next;
    return Container(
      color: GetIt.instance<SettingService>().isLightMode
          ? Colors.white
          : const Color(0xff1c2541),
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          const SizedBox(
            height: 50,
          ),
          Text(
            AppLocalizations.of(context)!.choseProfilePic,
            style: TextStyle(
                color: GetIt.instance<SettingService>().isLightMode
                    ? Colors.black
                    : Colors.white,
                fontSize: 24),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: SizedBox(
              width: 600,
              child: gridAvatar(context),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Set user profile Picture
              avatarService.avatarURL = chosenAvatar;
              avatarService.userName = widget.userName_;
              String avatarChangeStatus =
                  await avatarService.updateUserProfil();
              if (widget.isNewAccount) {
                if (!mounted) return;
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SignIn()));
              } else {
                widget.callback!(chosenAvatar);
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Container(
                        height: 30,
                        child: Center(child: Text(avatarChangeStatus))),
                    actions: [
                      Center(
                        child: ElevatedButton(
                            child: const Text("Ok"),
                            onPressed: () => Navigator.pop(context)),
                      ),
                    ],
                  ),
                );
              }
            },
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all<Size>(Size(130, 60)),
              backgroundColor:
                  const MaterialStatePropertyAll<Color>(Colors.blueGrey),
            ),
            child: Text(
              buttonText,
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ]),
      ),
    );
  }

  Widget gridAvatar(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isComplete,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return gridBuilder(context);
        } else {
          return const Center(
            child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 27, 94, 32),
                )),
          );
        }
      },
    );
  }

  gridBuilder(BuildContext context) {
    return GridView.builder(
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        itemCount: urlList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          crossAxisCount: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedAvatar = index;
              });
              chosenAvatar = urlList[selectedAvatar];
            },
            child: Card(
              // check if the index is equal to the selected Card integer
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              color: selectedAvatar == index
                  ? Colors.blue
                  : const Color.fromARGB(255, 255, 255, 255),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: Image.network(urlList[index])),
              ),
            ),
          );
        });
  }
}
