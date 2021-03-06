// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

// Project imports:
import 'package:syphon/global/assets.dart';
import 'package:syphon/global/dimensions.dart';
import 'package:syphon/global/strings.dart';
import 'package:syphon/global/values.dart';
import 'package:syphon/store/index.dart';
import 'package:syphon/store/settings/actions.dart';
import 'package:syphon/views/widgets/buttons/button-solid.dart';
import './action.dart';
import './first.dart';
import './landing.dart';
import './second.dart';
import './third.dart';

// Store

// Styling Widgets

// Local Components

class Intro extends StatefulWidget {
  const Intro({Key key}) : super(key: key);

  IntroState createState() => IntroState();
}

class IntroState extends State<Intro> {
  final String title = 'Intro';

  int currentStep = 0;
  bool onboarding = false;
  String loginText = Strings.buttonIntroExistQuestion;
  PageController pageController;

  final List<Widget> sections = [
    LandingSection(),
    FirstSection(),
    SecondSection(),
    ThirdSection(),
    ActionSection(),
  ];

  IntroState({Key key});

  @override
  void initState() {
    super.initState();

    pageController = PageController(
      initialPage: 0,
      keepPage: false,
      viewportFraction: 1.5,
    );
    // NOTE: SchedulerBinding still needed to have navigator context in dialogs
    SchedulerBinding.instance.addPostFrameCallback((_) {
      onMounted();
    });
  }

  @protected
  void onMounted() {
    // init authenticated navigation

    final store = StoreProvider.of<AppState>(context);
    final alphaAgreement = store.state.settingsStore.alphaAgreement;
    double width = MediaQuery.of(context).size.width;

    if (alphaAgreement == null || true) {
      final termsTitle = Platform.isIOS
          ? Strings.titleDialogTerms
          : Strings.titleDialogTermsAlpha;

      showDialog(
        context: context,
        barrierDismissible: false,
        child: Container(
          constraints: BoxConstraints(
            minWidth: width * 0.9,
          ),
          child: SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              termsTitle,
              textAlign: TextAlign.center,
            ),
            titlePadding: EdgeInsets.only(left: 24, right: 24, top: 24),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(24),
                child: Image(
                  width: 98,
                  height: 98,
                  image: AssetImage(Assets.appIconPng),
                ),
              ),
              Text(
                Strings.confirmationThanks,
                textAlign: TextAlign.center,
              ),
              Visibility(
                visible: !Platform.isIOS,
                child: Text(
                  Strings.confirmationAlphaVersion,
                  textAlign: TextAlign.center,
                ),
              ),
              Visibility(
                visible: !Platform.isIOS,
                child: Text(
                  Strings.confirmationAlphaWarning,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w100),
                ),
              ),
              Text(
                Strings.confirmationAlphaWarningAlt,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
              Text(
                Strings.confirmationConclusion,
                textAlign: TextAlign.center,
              ),
              Text(
                Strings.confirmationAppTermsOfService,
                style: TextStyle(fontSize: 12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SimpleDialogOption(
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: FlatButton(
                      child: Text('I Agree'),
                      onPressed: () async {
                        await store.dispatch(acceptAgreement());
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }

  String buildButtonString() {
    switch (currentStep) {
      case 0:
        return 'let\'s go';
      case 4:
        return 'count me in';
      default:
        return 'next';
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
      ),
      body: StoreConnector<AppState, AppState>(
        distinct: true,
        converter: (Store<AppState> store) => store.state,
        builder: (context, state) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 6,
              fit: FlexFit.tight,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: Dimensions.mediaSizeMin,
                ),
                child: PageView(
                  pageSnapping: true,
                  allowImplicitScrolling: true,
                  controller: pageController,
                  children: sections,
                  onPageChanged: (index) {
                    setState(() {
                      currentStep = index;
                      onboarding = index != 0 && index != sections.length - 1;
                    });
                  },
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: ButtonSolid(
                      text: buildButtonString(),
                      onPressed: () {
                        if (currentStep == 0) {
                          setState(() {
                            onboarding = true;
                          });
                        }

                        if (currentStep == sections.length - 2) {
                          setState(() {
                            loginText = Strings.buttonIntroExistQuestion;
                            onboarding = false;
                          });
                        }

                        if (currentStep == sections.length - 1) {
                          Navigator.pushNamed(
                            context,
                            '/signup',
                          );
                        }

                        pageController.nextPage(
                          duration: Duration(
                            milliseconds: Values.animationDurationDefault,
                          ),
                          curve: Curves.ease,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.center,
                direction: Axis.vertical,
                children: <Widget>[
                  Container(
                    height: Dimensions.inputHeight,
                    constraints: BoxConstraints(
                      minHeight: Dimensions.inputHeight,
                    ),
                    child: onboarding
                        ? Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SmoothPageIndicator(
                                controller: pageController, // PageController
                                count: sections.length,
                                effect: WormEffect(
                                  spacing: 16,
                                  dotHeight: 12,
                                  dotWidth: 12,
                                  paintStyle: PaintingStyle.fill,
                                  strokeWidth: 12,
                                  activeDotColor:
                                      Theme.of(context).primaryColor,
                                ), // your preferred effect
                              ),
                            ],
                          )
                        : TouchableOpacity(
                            activeOpacity: 0.4,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/login',
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  loginText,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    Strings.buttonIntroExistAction,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Theme.of(context).primaryColor
                                              : Colors.white,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
