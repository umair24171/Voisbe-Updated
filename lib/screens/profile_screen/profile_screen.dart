import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
// import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
// import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/profile_screen/controller/update_profile_controller.dart';
import 'package:social_notes/screens/profile_screen/provider.dart/update_profile_provider.dart';
import 'package:social_notes/screens/profile_screen/widgets/bank_details_popup.dart';
// import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/profile_screen/widgets/custom_list_tile.dart';
import 'package:social_notes/screens/stripe_controller.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, this.isMainPro = false});
  static const routeName = '/profile';
  bool isMainPro;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _suggestions = [];
  String name = '';
  String username = '';
  String bio = '';
  String link = '';
  String contact = '';
  String price = '';
  String soundPack = 'Upload your sound pack';
  bool subscription = false;
  DateTime? dateOfBirth;

  showDatPicker() async {
    // final DateTime twelveYearsAgo =
    //     DateTime.now().subtract(const Duration(days: 12 * 365));
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (picked != null && picked != dateOfBirth) {
      setState(() {
        dateOfBirth = picked;
      });
    }
  }

  List<String> reservedNames = [
    "cristiano",
    "kyliejenner",
    "leomessi",
    "kendalljenner",
    "selenagomez",
    "zendaya",
    "kimkardashian",
    "beyonce",
    "arianagrande",
    "billieeilish",
    "neymarjr",
    "lalalalisa_m",
    "jennierubyjane",
    "tomholland2013",
    "virat.kohli",
    "khaby00",
    "khloekardashian",
    "sooyaaa__",
    "justinbieber",
    "thv",
    "roses_are_rosie",
    "badgalriri",
    "nickiminaj",
    "iamcardib",
    "jin",
    "agustd",
    "therock",
    "instagram",
    "zayn",
    "champagnepapi",
    "rkive",
    "kourtneykardash",
    "uarmyhope",
    "badbunnypr",
    "katrinakaif",
    "adele",
    "harrystyles",
    "kingjames",
    "jlo",
    "k.mbappe",
    "karolg",
    "gigihadid",
    "anushkasharma",
    "narendramodi",
    "eunwo.o_c",
    "dualipa",
    "charlidamelio",
    "ester_exposito",
    "mileycyrus",
    "georginagio",
    "actorleeminho",
    "gal_gadot",
    "fcbarcelona",
    "akshaykumar",
    "shawnmendes",
    "milliebobbybrown",
    "chrishemsworth",
    "dlwlrma",
    "oliviarodrigo",
    "mosalah",
    "rashmika_mandanna",
    "lelepons",
    "ursulolita",
    "priyankachopra",
    "lilireinhart",
    "handemiyy",
    "ddlovato",
    "blackpinkofficial",
    "whinderssonnunes",
    "shraddhakapoor",
    "meganfox",
    "haileybieber",
    "bn_sj2013",
    "kimberly.loaiza",
    "real__pcy",
    "katyperry",
    "davidbeckham",
    "camila_cabello",
    "paulpogba",
    "aliaabhatt",
    "dojacat",
    "iamsrk",
    "realmadrid",
    "jongsuk0206",
    "miakhalifa",
    "nasa",
    "bellahadid",
    "oohsehun",
    "niallhoran",
    "hoooooyeony",
    "addisonraee",
    "beingsalmankhan",
    "twicetagram",
    "emmawatson",
    "zacefron",
    "nike",
    "madelame",
    "virginia",
    "jenniferaniston",
    "iamhalsey",
    "paulodybala",
    "dovecameron",
    "antonelaroccuzzo",
    "camimendes",
    "theweeknd",
    "norafatehi",
    "iamzlatanibrahimovic",
    "karimbenzema",
    "nehakakkar",
    "skawngur",
    "chrisbrownofficial",
    "hi_high_hiy",
    "realstraykids",
    "songkang_b",
    "vindiesel",
    "sergioramos",
    "shakira",
    "louist91",
    "ladygaga",
    "varundvn",
    "kjapa",
    "dannapaola",
    "iansomerhalder",
    "saraalikhan95",
    "jannatzubair29",
    "deepikapadukone",
    "championsleague",
    "sabrinacarpenter",
    "juliette",
    "alluarjunonline",
    "maluma",
    "hazardeden_10",
    "hrithikroshan",
    "luisitocomunica",
    "jacksonwang852g7",
    "madisonbeer",
    "kunaguero",
    "elrubiuswtf",
    "mrbeast",
    "rohitsharma45",
    "madelyncline",
    "stephencurry30",
    "_jeongjaehyun",
    "jamesrodriguez10",
    "433",
    "eminem",
    "phil.coutinho",
    "noahschnapp",
    "rosalia.vt",
    "lewishamilton",
    "dixiedamelio",
    "anuel",
    "riaricis1795",
    "emmachamberlain",
    "thenotoriousmma",
    "kartikaaryan",
    "brentrivera",
    "kritisanon",
    "shahidkapoor",
    "dishapatani",
    "marcelotwelve",
    "nina",
    "manchesterunited",
    "cznburak",
    "thedeverakonda",
    "brunamarquezine",
    "natgeo",
    "nusr_et",
    "taehyung.bighitentertainment",
    "haileesteinfeld",
    "skuukzky",
    "garethbale11",
    "sadiesink_",
    "domelipa",
    "daviddobrik",
    "samantharuthprabhuoffl",
    "feliciathegoat",
    "anitta",
    "miguel.g.herran",
    "carryminati",
    "jungkook_bighitentertainment",
    "loganpaul",
    "johnnydepp",
    "phs1116",
    "xxxibgdrgn",
    "theestallion",
    "kiaraaliaadvani",
    "paulolondra",
    "evaluna",
    "leedongwook_official",
    "sommerray",
    "juandediospantoja",
    "tyga",
    "erling.haaland",
    "jbalvin",
    "jacquelinef143",
    "annehathaway",
    "hardikpandya93",
    "wi__wi__wi",
    "kevinhart4real",
    "henrycavill",
    "lanarhoades",
    "gianlucavacchi",
    "joeyking",
    "zkdlin",
    "bellapoarch",
    "holyhaein",
    "m10_official",
    "jacobelordi",
    "samoylovaoxana",
    "carlinhosmaiaof",
    "9gag",
    "gusein.gasanov",
    "do0_nct",
    "sunnyleone",
    "jimin_bighitentertainment",
    "aron.piper",
    "finnwolfhardofficial",
    "iambeckyg",
    "bhuvan.bam22",
    "anushkasen0408",
    "_imyour_joy",
    "taina",
    "tinistoessel",
    "natashawilona12",
    "emrata",
    "somsomi0309",
    "rohittt_15",
    "iammostwanteddd",
    "iamnagarjuna",
    "angelaaguiarangel",
    "louane",
    "sammihanratty",
    "sachintendulkar",
    "jackson_yee_",
    "danielaacallee",
    "romelu.lukaku",
    "perrieeele",
    "lisaandlena",
    "wizkhalifa",
    "angelalindvall",
    "lizzzak",
    "sabina",
    "gigihadid.xx",
    "fernanfloo",
    "ellise",
    "shane_van_gisbergen",
    "eljuanpazurita",
    "willyrex",
    "yuyacst",
    "victoriabeckham",
    "jadeywadey180",
    "ximeponch",
    "kaykay",
    "luisfonsi",
    "mariale",
    "kamalikapieris",
    "arsenal",
    "ozuna",
    "stephanyortizr",
    "mohamedramadanws",
    "willianborges88",
    "shilpashirodkar73",
    "juanpabarbot",
    "landonmcgregor",
    "dualipanews",
    "thehughjackman",
    "mehakdeep_singh",
    "karol.g",
    "amandacerny",
    "hinddeer",
    "adamlevine",
    "laliga",
    "rayanlvtt",
    "yusufdemirkol_",
    "fatimaezzahraofficial",
    "paniniamerica",
    "milliebobbybrownupdates",
    "luisitogarcia10",
    "nehakakkarlovers",
    "dmtod",
    "andresiniesta8",
    "pokimanelol",
    "mohamedsalah",
    "fedefederossi",
    "deynacorn",
    "fernandinho",
    "ddong_gg0",
    "davidbisbal",
    "siruthai.siva",
    "corona",
    "jana",
    "daddyyankee",
    "theellenshow",
    "lelettroniique",
    "mrwheelerparker",
    "sammy",
    "ross_lynch",
    "ravensofficial",
    "muhammadali",
    "kevin",
    "tylerthecreator",
    "andrenocetiii",
    "giovanni",
    "maitreyiramakant",
    "donghyun_m",
    "jenniferlopez",
    "sarkodie",
    "thejensie",
    "mrtonyvitello",
    "aishwaryaraibachchan_arb",
    "petesouza",
    "mariahcarey",
    "love_sadkid",
    "justinbieberr",
    "caradelevingne",
    "nikefootball",
    "naeun",
    "pabllovittar",
    "kyrieirving",
    "valeriabaroni",
    "leonardodicaprio",
    "twinmelody",
    "fakharzaman719",
    "fazeclan",
    "jessicaalba",
    "gianluigibuffon",
    "marcmarquez93",
    "jessicachastain",
    "liltjay",
    "iamlilimar",
    "jackgrazer",
    "tombrady",
    "lilpump",
    "yelyahwilliams",
    "nikkietutorials",
    "scooterbraun",
    "alexroe",
    "renner4real",
    "zahraelise",
    "milliegomez",
    "floydmayweather",
    "iamyashikaanand",
    "montesjulia08",
    "kingjames.lebron23",
    "theromymont",
    "martingarrix",
    "odell",
    "schwarzenegger",
    "natsumi",
    "jacksonwang852g7d",
    "missmariahsposts",
    "kourtneykardashiansnapchat",
    "victoriapaulsen",
    "ranveersingh",
    "acefamily",
    "bobby",
    "stanlee",
    "pierre",
    "justinbiebers",
    "jamescharles",
    "florence",
    "therock13",
    "davidbeckhamswag",
    "bellathorne",
    "eugenio_siller",
    "john",
    "joebiden",
    "mohanlal",
    "katelynnacon",
    "michelleobama",
    "travisscott",
    "meredithvieirashow",
    "eltonjohn",
    "rosalia",
    "kendalljennersnapchats",
    "justintimberlake",
    "victoriabeckhamofficial",
    "vindieselfacts",
    "rachelcomey",
    "andresiniesta8",
    "meganfox143",
    "djearworm",
    "scuderiaferrari",
    "neyo",
    "blakegray",
    "jordynwoods",
    "harry",
    "jacob",
    "nicholas",
    "lucy",
    "casey",
    "jackson",
    "hunter"
  ];

  @override
  void initState() {
    super.initState();
    // _bioController.addListener(() {
    //   setState(() {
    //     bio = _bioController.text;
    //   });
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UpdateProfileProvider>(context, listen: false)
          .getAllUserNames();
    });
  }

  // getAllUsers() {}
  TextEditingController _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? userNameError;
  String? linkError;
  String? contactError;
  String? priceError;
  // bool _validate = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var userProvider = Provider.of<UserProvider>(
      context,
    );
    userProvider.getUserData();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: whiteColor,
        backgroundColor: whiteColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.isMainPro)
              InkWell(
                onTap: () {
                  navPop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                ),
              ),
            if (!widget.isMainPro) const SizedBox(),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Edit Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox()
          ],
        ),
        centerTitle: true,
      ),
      body: userProvider.user == null
          ? SpinKitThreeBounce(
              color: whiteColor,
              size: 20,
            )
          : SizedBox(
              // alignment: Alignment.center,
              height: size.height,

              child: Stack(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (userProvider.user!.photoUrl.isNotEmpty ||
                      userProvider.imageFile != null)
                    Container(
                      height: size.height,
                      decoration: BoxDecoration(
                        image: userProvider.imageFile == null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  userProvider.user!.photoUrl.isNotEmpty
                                      ? userProvider.user!.photoUrl
                                      : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                                ),
                              )
                            : DecorationImage(
                                image: FileImage(userProvider.imageFile!),
                                fit: BoxFit.cover),
                      ),
                    ),
                  if (userProvider.user!.photoUrl.isEmpty &&
                      userProvider.imageFile == null)
                    Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              stops: [
                                0.25,
                                0.75,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xffee856d), Color(0xffed6a5a)])),
                    ),
                  // ColorFiltered(
                  //   colorFilter:
                  //       ColorFilter.mode(primaryColor, BlendMode.srcATop),
                  //   child: ShaderMask(
                  //     blendMode: BlendMode.srcATop,
                  //     shaderCallback: (Rect bounds) {
                  //       return LinearGradient(
                  //         begin: Alignment.topCenter,
                  //         end: Alignment.bottomCenter,
                  //         stops: const [1.0, 0],
                  //         colors: [primaryColor, primaryColor],
                  //       ).createShader(bounds);
                  //     },
                  //     child: Container(
                  //       height: size.height,
                  //       decoration: BoxDecoration(
                  //         gradient: LinearGradient(
                  //           begin: Alignment.topCenter,
                  //           end: Alignment.bottomCenter,
                  //           colors: [Colors.transparent, primaryColor],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      height: size.height,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xffED695A)],
                        ),
                      ),
                    ),
                  ),
                  CustomScrollView(slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (userProvider.user!.photoUrl.isNotEmpty ||
                              userProvider.imageFile != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Align(
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: whiteColor, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: userProvider.imageFile == null
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  userProvider.user!.photoUrl
                                                          .isNotEmpty
                                                      ? userProvider
                                                          .user!.photoUrl
                                                      : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D'),
                                              radius: 50,
                                            )
                                          : CircleAvatar(
                                              backgroundImage: FileImage(
                                                  userProvider.imageFile!),
                                              radius: 50,
                                            ),
                                    ),
                                    Positioned(
                                      left: 70,
                                      bottom: 5,
                                      child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              userProvider.pickImage();
                                            },
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (userProvider.user!.photoUrl.isEmpty &&
                              userProvider.imageFile == null)
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                userProvider.pickImage();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: whiteColor, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: CircleAvatar(
                                      backgroundColor: primaryColor,
                                      radius: 50,
                                      child: SvgPicture.asset(
                                        'assets/icons/Add profile picture.svg',
                                        // color: primar,
                                        height: 64,
                                        width: 64,
                                      ),
                                    )),
                              ),
                            ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                CustomListTile(
                                  // validate: _validate,

                                  textCapitalization: TextCapitalization.words,
                                  username: name.isEmpty
                                      ? userProvider.user!.username
                                      : name,
                                  name: 'Name',
                                  subtitile: name.isEmpty
                                      ? userProvider.user!.username
                                      : name,
                                  isLink: false,
                                  inputText: '',
                                  onChanged: (value) {
                                    setState(() {
                                      name = value;
                                    });
                                  },
                                ),
                                Consumer<UpdateProfileProvider>(
                                    builder: (context, allUserPro, _) {
                                  // _bioController.text=
                                  return CustomListTile(
                                    isUserName: true,
                                    userNameError: userNameError,
                                    username: name.isEmpty
                                        ? userProvider.user!.username
                                        : name,
                                    name: 'Username',
                                    isBio: false,
                                    subtitile: username.isEmpty
                                        ? userProvider.user!.name
                                        : username,
                                    isLink: false,
                                    inputText: '',
                                    onChanged: (value) {
                                      if (reservedNames.contains(value)) {
                                        if (value.isNotEmpty) {
                                          showWhiteOverlayPopup(
                                              context, Icons.error, null,
                                              title: 'Username reserved',
                                              isUsernameRes: true,
                                              message:
                                                  'The requested username has been reserved. If you are the rightful owner of the verified username on a different platform, kindly contact us via the email below.');
                                          setState(() {
                                            userNameError = 'Username reserved';
                                          });
                                        } else {
                                          setState(() {
                                            userNameError =
                                                'Username should not be empty';
                                          });
                                        }
                                      } else if (allUserPro.userNames
                                          .contains(value)) {
                                        if (value.isNotEmpty) {
                                          showWhiteOverlayPopup(
                                              context, Icons.error, null,
                                              title: 'Username taken',
                                              isUsernameRes: false,
                                              message:
                                                  'The chosen username is unavailable. Please select a different username');
                                          setState(() {
                                            userNameError = 'Username taken';
                                          });
                                        } else {
                                          setState(() {
                                            userNameError =
                                                'Username should not be empty';
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          userNameError = null;
                                          username = value;
                                        });
                                      }
                                    },
                                  );
                                }),
                                Consumer<UpdateProfileProvider>(
                                    builder: (context, profilePro, _) {
                                  if (_bioController.text.isEmpty) {
                                    _bioController.text =
                                        userProvider.user!.bio;
                                  }
                                  // _bioController.text =
                                  //     _bioController.text.isNotEmpty
                                  //         ? _bioController.text
                                  //         : userProvider.user!.bio;
                                  return Column(
                                    children: [
                                      CustomListTile(
                                        // validate: _validate,
                                        bioController: _bioController,
                                        username: name.isEmpty
                                            ? userProvider.user!.username
                                            : name,
                                        isLink: false,
                                        name: 'Biography',
                                        isBio: true,
                                        subtitile:
                                            _bioController.text.isNotEmpty
                                                ? _bioController.text
                                                : userProvider.user!.bio,
                                        inputText: '',
                                        onChanged: (value) {
                                          String text = value;
                                          if (text.contains('@')) {
                                            String query = text.split('@').last;
                                            if (query.isNotEmpty) {
                                              List<String> users =
                                                  profilePro.userNames;
                                              setState(() {
                                                _suggestions = users
                                                    .where((user) => user
                                                        .toLowerCase()
                                                        .contains(query
                                                            .toLowerCase()))
                                                    .toList();
                                              });
                                            } else {
                                              setState(() {
                                                _suggestions = [];
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              _suggestions = [];
                                            });
                                          }
                                        },
                                      ),
                                      ..._suggestions.map((user) => ListTile(
                                            title: Text(
                                              user,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: whiteColor,
                                                  fontFamily: fontFamily),
                                            ),
                                            onTap: () {
                                              // Replace @mention with the selected user
                                              String text = _bioController.text;
                                              String updatedText =
                                                  text.replaceAll(
                                                      RegExp(r'@\w*$'),
                                                      '@$user ');
                                              _bioController.text = updatedText;
                                              _bioController.selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: updatedText
                                                              .length));
                                              setState(() {
                                                _suggestions = [];
                                              });
                                            },
                                          )),
                                    ],
                                  );
                                }),

                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 15, vertical: 6),
                                //   child: Column(
                                //     children: [
                                //       Row(
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         children: [
                                //           Expanded(
                                //             flex: 3,
                                //             child: Padding(
                                //               padding: EdgeInsets.only(
                                //                   left: 8,
                                //                   top: dateOfBirth != null &&
                                //                           (DateTime.now()
                                //                                           .difference(dateOfBirth ??
                                //                                               userProvider.user!.dateOfBirth)
                                //                                           .inDays /
                                //                                       365)
                                //                                   .floor() <
                                //                               12
                                //                       ? 30
                                //                       : 8),
                                //               child: Text(
                                //                 'Date of birth',
                                //                 style: TextStyle(
                                //                   // height: 1,
                                //                   fontFamily: fontFamily,
                                //                   color: whiteColor,
                                //                   fontWeight: FontWeight.w600,
                                //                   fontSize: 14,
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //           Expanded(
                                //             flex: 9,
                                //             child: Padding(
                                //               padding:
                                //                   const EdgeInsets.symmetric(
                                //                       horizontal: 10,
                                //                       vertical: 0),
                                //               child: Column(
                                //                 crossAxisAlignment:
                                //                     CrossAxisAlignment.start,
                                //                 mainAxisAlignment:
                                //                     MainAxisAlignment.start,
                                //                 children: [
                                //                   if (dateOfBirth != null &&
                                //                       (DateTime.now()
                                //                                       .difference(dateOfBirth ??
                                //                                           userProvider
                                //                                               .user!
                                //                                               .dateOfBirth)
                                //                                       .inDays /
                                //                                   365)
                                //                               .floor() <
                                //                           12)
                                //                     Padding(
                                //                       padding:
                                //                           const EdgeInsets.only(
                                //                               bottom: 8),
                                //                       child: Text(
                                //                         'Must be over 12 years',
                                //                         style: TextStyle(
                                //                             height: 0,
                                //                             color: greenColor,
                                //                             fontSize: 12,
                                //                             fontFamily:
                                //                                 fontFamily),
                                //                       ),
                                //                     ),
                                //                   Stack(
                                //                     children: [
                                //                       Padding(
                                //                           padding:
                                //                               const EdgeInsets
                                //                                   .all(8.0),
                                //                           child: FieldForDate(
                                //                             onChanged: (value) {
                                //                               setState(() {
                                //                                 dateOfBirth = (value
                                //                                         as Timestamp)
                                //                                     .toDate();
                                //                               });
                                //                             },
                                //                             dateOfBirth: DateFormat
                                //                                     .yMMMd()
                                //                                 .format(dateOfBirth ??
                                //                                     userProvider
                                //                                         .user!
                                //                                         .dateOfBirth),
                                //                             showDatePicker:
                                //                                 showDatPicker,
                                //                           )),
                                //                     ],
                                //                   ),
                                //                 ],
                                //               ),
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //       Divider(
                                //         endIndent: 10,
                                //         indent: 10,
                                //         height: 1,
                                //         color: Colors.white.withOpacity(0.2),
                                //       )
                                //     ],
                                //   ),
                                // ),

                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                top: dateOfBirth != null &&
                                                        (DateTime.now()
                                                                        .difference(dateOfBirth ??
                                                                            userProvider.user!.dateOfBirth)
                                                                        .inDays /
                                                                    365)
                                                                .floor() <
                                                            12
                                                    ? 20
                                                    : 0,
                                              ),
                                              child: Text(
                                                'Date of birth',
                                                style: TextStyle(
                                                  // height: 1,
                                                  fontFamily: fontFamily,
                                                  color: whiteColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 9,
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      // vertical: ,
                                                      horizontal: 4),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (dateOfBirth != null &&
                                                          (DateTime.now()
                                                                          .difference(dateOfBirth ??
                                                                              userProvider.user!.dateOfBirth)
                                                                          .inDays /
                                                                      365)
                                                                  .floor() <
                                                              12)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 8),
                                                          child: Text(
                                                            'Must be over 12 years',
                                                            style: TextStyle(
                                                                height: 0,
                                                                color:
                                                                    greenColor,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    fontFamily),
                                                          ),
                                                        ),
                                                      Container(
                                                        height: 34,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.59,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 30,
                                                                left: 13,
                                                                bottom: 8,
                                                                top: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: blackColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Text(
                                                          DateFormat.yMMMd().format(
                                                              dateOfBirth ??
                                                                  userProvider
                                                                      .user!
                                                                      .dateOfBirth),
                                                          // textAlign:
                                                          //     TextAlign.center,
                                                          style: TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  fontFamily),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  left: size.width * 0.52,
                                                  bottom: 1,
                                                  child: Container(
                                                    // height: 20,
                                                    // width: 20,
                                                    padding:
                                                        const EdgeInsets.all(9),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        showDatPicker();
                                                      },
                                                      child: const Icon(
                                                        Icons.edit_outlined,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      endIndent: 10,
                                      indent: 10,
                                      height: 1,
                                      color: Colors.white.withOpacity(0.2),
                                    )
                                  ],
                                ),

                                CustomListTile(
                                  username: name.isEmpty
                                      ? userProvider.user!.username
                                      : name,
                                  name: 'Link',
                                  linkError: linkError,
                                  subtitile: link.isNotEmpty
                                      ? link
                                      : userProvider.user!.link,
                                  isLink: true,
                                  inputText: '',
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      if ((
                                              // !value.startsWith('http://') &&
                                              //       !value.startsWith('https://') &&
                                              !value.startsWith('www')) ||
                                          !value.contains('.')) {
                                        setState(() {
                                          linkError = 'Please add valid link';
                                        });
                                      } else {
                                        setState(() {
                                          linkError = null;
                                          link = value;
                                        });
                                      }
                                    }
                                  },
                                ),

                                CustomListTile(
                                  username: name.isEmpty
                                      ? userProvider.user!.username
                                      : name,
                                  name: 'Contact',
                                  contactError: contactError,
                                  subtitile: contact.isNotEmpty
                                      ? contact
                                      : userProvider.user!.contact,
                                  isLink: true,
                                  inputText: '',
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      if (!value.contains('@') ||
                                          !value.contains('.')) {
                                        setState(() {
                                          contactError =
                                              'Invalid email address';
                                        });
                                      } else {
                                        setState(() {
                                          contactError = null;
                                          contact = value;
                                        });
                                      }
                                    }
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 5),
                                    child: Text(
                                      'Verified Users Only',
                                      style: TextStyle(
                                          fontFamily: fontFamily,
                                          color: whiteColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 25),
                                      child: Text(
                                        'Subscription',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: fontFamily,
                                            color: userProvider
                                                    .user!.isSubscriptionEnable
                                                ? whiteColor
                                                : Colors.grey),
                                      ),
                                    ),
                                    Consumer<UserProvider>(
                                        builder: (context, sub, child) {
                                      return GestureDetector(
                                        onTap: () async {
                                          if (userProvider
                                                  .user!.isSubscriptionEnable ==
                                              true) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userProvider.user!.uid)
                                                .update({
                                              'isSubscriptionEnable': false
                                            });
                                          } else {
                                            final parentContext = context;
                                            showDialog(
                                                context: parentContext,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                      backgroundColor:
                                                          whiteColor,
                                                      elevation: 0,
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      content: BankDetails(
                                                        changeSub: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(userProvider
                                                                  .user!.uid)
                                                              .update({
                                                            'isSubscriptionEnable':
                                                                true
                                                          });
                                                        },
                                                        user:
                                                            userProvider.user!,
                                                        stripeFunction: () {
                                                          if (!userProvider
                                                              .user!
                                                              .isVerified) {
                                                            // Provider.of<PaymentController>(
                                                            //         context,
                                                            //         listen:
                                                            //             false)
                                                            //     .makePayment(
                                                            //         amount: '5',
                                                            //         currency:
                                                            //             'usd',
                                                            //         addSubFunction:
                                                            //             () async {
                                                            //           await FirebaseFirestore
                                                            //               .instance
                                                            //               .collection(
                                                            //                   'users')
                                                            //               .doc(userProvider
                                                            //                   .user!
                                                            //                   .uid)
                                                            //               .update({
                                                            //             'isVerified':
                                                            //                 true
                                                            //           });
                                                            //         });
                                                          }
                                                        },
                                                      ),
                                                    ));
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                            // width: 100,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 7),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          //  !userProvider
                                                          //         .user!.isVerified
                                                          //     ?
                                                          userProvider.user!
                                                                  .isSubscriptionEnable
                                                              ? primaryColor
                                                              : const Color(
                                                                  0xff6f6f6f),
                                                      // :
                                                      // const Color(
                                                      //     0xff6f6f6f),
                                                      // : sub.isSubscription
                                                      //     ? primaryColor
                                                      //     : blackColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(18),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      18))),
                                                  child: Text(
                                                    'ON',
                                                    style: TextStyle(
                                                        color: whiteColor),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          //  !userProvider
                                                          //         .user!.isVerified
                                                          //     ?
                                                          userProvider.user!
                                                                  .isSubscriptionEnable
                                                              ? const Color(
                                                                  0xff6f6f6f)
                                                              : const Color(
                                                                  0xffcdcdcd),
                                                      // : sub.isSubscription
                                                      //     ? blackColor
                                                      //     : primaryColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topRight: Radius
                                                                  .circular(18),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          18))),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 7),
                                                  child: Text(
                                                    'OFF',
                                                    style: TextStyle(
                                                        color: whiteColor),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 5),
                                  child: Text(
                                    'If enabled users will be able to subscribe to you for a monthly payment (starting from USD 4.0) and receive the subscriber special for the time of being subscribed.',
                                    style: TextStyle(
                                        color: userProvider
                                                .user!.isSubscriptionEnable
                                            ? whiteColor
                                            : Colors.grey,
                                        fontFamily: fontFamily,
                                        fontSize: 12),
                                  ),
                                ),
                                Divider(
                                  endIndent: 25,
                                  indent: 25,
                                  height: 1,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                // Consumer<UpdateProfileProvider>(
                                //     builder: (context, updatePro, _) {
                                //   return CustomListTile(
                                //     isVerifiedForPrice:
                                //         userProvider.isSubscription,
                                //     isPrice: true,
                                //     username: name.isEmpty
                                //         ? userProvider.user!.username
                                //         : name,
                                //     name: 'Price per month',
                                //     priceError: priceError,
                                //     subtitile:
                                // updatePro.price.isNotEmpty
                                //         ? updatePro.price
                                //         : userProvider.user!.price.toString(),
                                //     isLink: true,
                                //     inputText: '',
                                //     onChanged: (value) {
                                //       if (value.isNotEmpty) {
                                //         if (double.parse(value) < 3.99) {
                                //           setState(() {
                                //             priceError =
                                //                 'Price should be greater than 3.99';
                                //           });
                                //           log("errr $priceError $value");
                                //         } else {
                                //           setState(() {
                                //             priceError = null;
                                //             updatePro.price = value;
                                //           });
                                //         }
                                //       }
                                //       // setState(() {
                                //       //   price = value;
                                //       // });
                                //     },
                                //   );
                                // }),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Padding(
                                          // ignore: prefer_const_constructors
                                          padding: EdgeInsets.only(
                                            left: 23,
                                          ),
                                          child: Text(
                                            'Price per month',
                                            style: TextStyle(
                                              // height: 1,
                                              fontFamily: fontFamily,
                                              color: userProvider.user!
                                                      .isSubscriptionEnable
                                                  ? whiteColor
                                                  : Colors.grey,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      // vertical: ,
                                                      horizontal: 4),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 34,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.59,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 30,
                                                            left: 13,
                                                            bottom: 8,
                                                            top: 8),
                                                    decoration: BoxDecoration(
                                                      color: userProvider.user!
                                                              .isSubscriptionEnable
                                                          ? blackColor
                                                          : const Color(
                                                              0xff6f6f6f),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Consumer<
                                                            UpdateProfileProvider>(
                                                        builder: (context,
                                                            updatePro, _) {
                                                      return Text(
                                                        updatePro.price
                                                                .isNotEmpty
                                                            ? updatePro.price
                                                            : userProvider
                                                                .user!.price
                                                                .toString(),
                                                        // textAlign:
                                                        //     TextAlign.center,
                                                        style: TextStyle(
                                                            color: whiteColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                fontFamily),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              left: size.width * 0.52,
                                              bottom: 1,
                                              child: Container(
                                                // height: 20,
                                                // width: 20,
                                                padding:
                                                    const EdgeInsets.all(9),
                                                decoration: BoxDecoration(
                                                  color: userProvider.user!
                                                          .isSubscriptionEnable
                                                      ? primaryColor
                                                      : const Color(0xffcdcdcd),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    if (userProvider
                                                            .user!.isVerified &&
                                                        userProvider.user!
                                                            .isSubscriptionEnable) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          backgroundColor:
                                                              whiteColor,
                                                          elevation: 0,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          content: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    whiteColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15)),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Provider.of<UpdateProfileProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .setPrice(
                                                                              '4.0');
                                                                      navPop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        '\$4.0',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                fontFamily),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 1,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Provider.of<UpdateProfileProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .setPrice(
                                                                              '10.0');
                                                                      navPop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        '\$10.0',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                fontFamily),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 1,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Provider.of<UpdateProfileProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .setPrice(
                                                                              '20.0');
                                                                      navPop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        '\$20.0',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                fontFamily),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 1,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Provider.of<UpdateProfileProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .setPrice(
                                                                              '50.0');
                                                                      navPop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        '\$50.0',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                fontFamily),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 1,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Provider.of<UpdateProfileProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .setPrice(
                                                                              '100.0');
                                                                      navPop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        '\$100.0',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                fontFamily),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      showWhiteOverlayPopup(
                                                          context,
                                                          Icons.error_outline,
                                                          null,
                                                          title: 'Error',
                                                          message:
                                                              'You need to be verified to add the price',
                                                          isUsernameRes: false);
                                                    }
                                                  },
                                                  child: const Icon(
                                                    Icons.edit_outlined,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Divider(
                                //   endIndent: 10,
                                //   indent: 10,
                                //   height: 1,
                                //   color: Colors.white.withOpacity(0.2),
                                // )
                                // CustomListTile(
                                //   validate: _validate,
                                //   username: name.isEmpty
                                //       ? userProvider.user!.username
                                //       : name,
                                //   name: 'Sound Pack',
                                //   subtitile: soundPack,
                                //   isLink: true,
                                //   isSound: true,
                                //   inputText: '',
                                //   onChanged: (value) {
                                //     setState(() {
                                //       soundPack = value;
                                //     });
                                //   },
                                // ),
                                // // CustomListTile(
                                // //   name: 'Pricing',
                                // //   subtitile: '',
                                // //   isLink: true,
                                // //   inputText: 'USD 4.99',
                                // // ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 25, vertical: 5),
                                //   child: Text(
                                //     'As a verified user you are able to upload and offer your own sound pack. Subscribers will then be able to use your sounds that will be included in their subscription. Your sound will appear in their sound library, ready to be used non-commercially. ',
                                //     style: TextStyle(
                                //         color: whiteColor,
                                //         fontFamily: fontFamily,
                                //         fontSize: 12),
                                //   ),
                                // ),

                                Divider(
                                  endIndent: 10,
                                  indent: 10,
                                  height: 1,
                                  color: Colors.white.withOpacity(0.2),
                                ),

                                Consumer<UpdateProfileProvider>(
                                    builder: (context, updatePro, _) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, right: 20, top: 5),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                          style: ButtonStyle(
                                              fixedSize:
                                                  const WidgetStatePropertyAll(
                                                      Size(145, 40)),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      whiteColor)),
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if (userProvider
                                                  .user!.isVerified) {
                                                if (userNameError == null &&
                                                    linkError == null &&
                                                    contactError == null &&
                                                    (DateTime.now()
                                                                    .difference(dateOfBirth ??
                                                                        userProvider
                                                                            .user!
                                                                            .dateOfBirth)
                                                                    .inDays /
                                                                365)
                                                            .floor() >=
                                                        12) {
                                                  userProvider
                                                      .setUserLoading(true);

                                                  String? image;
                                                  if (userProvider.imageFile !=
                                                      null) {
                                                    image =
                                                        await AddNoteController()
                                                            .uploadFile(
                                                                'profile',
                                                                userProvider
                                                                    .imageFile!,
                                                                context);
                                                  }

                                                  // if(image == null && userProvider.user!.photoUrl.isEmpty){
                                                  //   userProvider.setUserLoading(false);
                                                  //   showSnackBar(context, 'Please select image');
                                                  //   return;
                                                  // }
                                                  navPush(BottomBar.routeName,
                                                      context);

                                                  UpdateProfileController()
                                                      .updateProfile(
                                                          name.isEmpty
                                                              ? userProvider
                                                                  .user!.username
                                                              : name,
                                                          username.isEmpty
                                                              ? userProvider
                                                                  .user!.name
                                                              : username,
                                                          _bioController.text
                                                                  .isNotEmpty
                                                              ? _bioController
                                                                  .text
                                                              : userProvider
                                                                  .user!.bio,
                                                          link.isEmpty
                                                              ? userProvider
                                                                  .user!.link
                                                              : link,
                                                          contact.isEmpty
                                                              ? userProvider
                                                                  .user!.contact
                                                              : contact,
                                                          userProvider
                                                              .isSubscription,
                                                          updatePro.price
                                                                  .isNotEmpty
                                                              ? double.parse(
                                                                  updatePro
                                                                      .price)
                                                              : userProvider
                                                                  .user!.price,
                                                          updatePro.fileUrls,
                                                          image ??
                                                              userProvider.user!
                                                                  .photoUrl,
                                                          dateOfBirth ??
                                                              userProvider.user!
                                                                  .dateOfBirth,
                                                          context)
                                                      .then((value) {
                                                    userProvider
                                                        .setUserLoading(false);
                                                    userProvider.removeImage();
                                                  });
                                                }
                                              } else {
                                                if (userNameError == null &&
                                                    linkError == null &&
                                                    contactError == null &&
                                                    (DateTime.now()
                                                                    .difference(dateOfBirth ??
                                                                        userProvider
                                                                            .user!
                                                                            .dateOfBirth)
                                                                    .inDays /
                                                                365)
                                                            .floor() >=
                                                        12) {
                                                  userProvider
                                                      .setUserLoading(true);

                                                  String? image;
                                                  if (userProvider.imageFile !=
                                                      null) {
                                                    image =
                                                        await AddNoteController()
                                                            .uploadFile(
                                                                'profile',
                                                                userProvider
                                                                    .imageFile!,
                                                                context);
                                                  }

                                                  // if(image == null && userProvider.user!.photoUrl.isEmpty){
                                                  //   userProvider.setUserLoading(false);
                                                  //   showSnackBar(context, 'Please select image');
                                                  //   return;
                                                  // }
                                                  navPush(BottomBar.routeName,
                                                      context);

                                                  UpdateProfileController()
                                                      .updateProfile(
                                                          name.isEmpty
                                                              ? userProvider
                                                                  .user!.username
                                                              : name,
                                                          username.isEmpty
                                                              ? userProvider
                                                                  .user!.name
                                                              : username,
                                                          _bioController.text
                                                                  .isNotEmpty
                                                              ? _bioController
                                                                  .text
                                                              : userProvider
                                                                  .user!.bio,
                                                          link.isEmpty
                                                              ? userProvider
                                                                  .user!.link
                                                              : link,
                                                          contact.isEmpty
                                                              ? userProvider
                                                                  .user!.contact
                                                              : contact,
                                                          userProvider
                                                              .isSubscription,
                                                          updatePro.price
                                                                  .isNotEmpty
                                                              ? double.parse(
                                                                  updatePro
                                                                      .price)
                                                              : userProvider
                                                                  .user!.price,
                                                          updatePro.fileUrls,
                                                          image ??
                                                              userProvider.user!
                                                                  .photoUrl,
                                                          dateOfBirth ??
                                                              userProvider.user!
                                                                  .dateOfBirth,
                                                          context)
                                                      .then((value) {
                                                    userProvider
                                                        .setUserLoading(false);
                                                    userProvider.removeImage();
                                                  });
                                                }
                                              }
                                            } else {
                                              setState(() {
                                                _formKey.currentState!
                                                    .validate();
                                              });
                                            }
                                          },
                                          icon: Icon(
                                            Icons.check,
                                            color: blackColor,
                                            size: 25,
                                          ),
                                          label: userProvider.userLoading
                                              ? SpinKitThreeBounce(
                                                  color: blackColor,
                                                  size: 13,
                                                )
                                              : Text(
                                                  'Save profile',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: blackColor,
                                                      fontFamily: fontFamily),
                                                )),
                                    ),
                                  );
                                })
                              ],
                            ),
                          )

                          // CustomListTile(
                          //   name: 'Pricing',
                          //   subtitile: '',
                          //   isLink: true,
                          //   inputText: 'jennaotizer@gmail.com',
                          // ),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
    );
  }
}

class FieldForDate extends StatefulWidget {
  const FieldForDate(
      {super.key,
      required this.dateOfBirth,
      required this.showDatePicker,
      required this.onChanged});
  final String dateOfBirth;
  final VoidCallback showDatePicker;
  final ValueChanged<String> onChanged;

  @override
  State<FieldForDate> createState() => _FieldForDateState();
}

class _FieldForDateState extends State<FieldForDate> {
  late TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController(text: widget.dateOfBirth);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return TextFormField(
      controller: controller,
      // initialValue:
      // DateFormat.yMMMd()
      //     .format(dateOfBirth ?? userProvider.user!.dateOfBirth),

      readOnly: true,
      onChanged: (value) {
        widget.onChanged(value);
      },
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(color: whiteColor, fontSize: 14, fontFamily: fontFamily),
      decoration: InputDecoration(
        fillColor: blackColor,
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.only(
          bottom: 0,
          top: 0,
          left: 14,
          right: 0,
        ),
        isDense: true,
        suffixIconConstraints:
            const BoxConstraints(minHeight: 18, minWidth: 18),
        suffix: Container(
          // height: 20,
          // width: 20,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            onTap: () {
              widget.showDatePicker();
            },
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
        constraints: BoxConstraints(
          minHeight: 34,
          maxHeight: 34,
          // widget.validate &&
          //         widget.validator != null
          //     ? 54
          //     : 34,
          maxWidth: size.width * 0.8,
          minWidth: size.width * 0.8,
        ),
      ),
    );
  }
}
