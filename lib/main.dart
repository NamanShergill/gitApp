import 'package:dio_hub/app/Dio/response_handler.dart';
import 'package:dio_hub/app/global.dart';
import 'package:dio_hub/app/settings/font.dart';
import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:dio_hub/controller/deep_linking_handler.dart';
import 'package:dio_hub/controller/internet_connectivity.dart';
import 'package:dio_hub/providers/landing_navigation_provider.dart';
import 'package:dio_hub/providers/search_data_provider.dart';
import 'package:dio_hub/providers/users/current_user_provider.dart';
import 'package:dio_hub/routes/router.gr.dart';
import 'package:dio_hub/services/authentication/auth_service.dart';
import 'package:dio_hub/style/border_radiuses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Error popup stream initialised.
  ResponseHandler.getErrorStream();
  // Success popup stream initialised.
  ResponseHandler.getSuccessStream();
  // Connectivity check stream initialised.
  InternetConnectivity.networkStatusService();
  await Future.wait([
    setupAppCache(),
    setUpSharedPrefs(),
  ]);
  final initLink = await initUniLink();
  uniLinkStream();
  final auth = await AuthService.isAuthenticated;
  runApp(MyApp(
    initLink,
    authenticated: auth,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp(this.initDeepLink, {Key? key, required this.authenticated})
      : super(key: key);
  final String? initDeepLink;
  final bool authenticated;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Initialise Authentication Bloc and add event to check auth state.
        BlocProvider(
          create: (_) => AuthenticationBloc(authenticated: authenticated),
          lazy: false,
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                lazy: false,
                create: (_) => CurrentUserProvider(
                    authenticationBloc:
                        BlocProvider.of<AuthenticationBloc>(context)),
              ),
              ChangeNotifierProvider(
                create: (_) => NavigationProvider(''),
              ),
              ChangeNotifierProvider(
                create: (_) => SearchDataProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => FontSettings(),
              ),
              ChangeNotifierProvider(
                create: (_) => PaletteSettings(),
              ),
            ],
            builder: (context, child) {
              final palette =
                  Provider.of<PaletteSettings>(context).currentSetting;
              return Portal(
                child: MaterialApp.router(
                  theme: ThemeData(
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    unselectedWidgetColor: palette.faded1,
                    accentColor: palette.accent,
                    cardColor: palette.primary,
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(palette.secondary),
                      ),
                    ),
                    appBarTheme:
                        AppBarTheme(color: palette.primary, elevation: 5),
                    iconTheme: IconThemeData(color: palette.baseElements),
                    textTheme: const TextTheme(
                      bodyText1: TextStyle(),
                      bodyText2: TextStyle(),
                      headline1: TextStyle(fontWeight: FontWeight.bold),
                      headline2: TextStyle(fontWeight: FontWeight.bold),
                      headline3: TextStyle(fontWeight: FontWeight.bold),
                      headline4: TextStyle(fontWeight: FontWeight.bold),
                      headline5: TextStyle(fontWeight: FontWeight.bold),
                      headline6: TextStyle(fontWeight: FontWeight.bold),
                      subtitle1: TextStyle(),
                      subtitle2: TextStyle(),
                      caption: TextStyle(),
                      button: TextStyle(),
                      overline: TextStyle(),
                    ).apply(
                        displayColor: palette.baseElements,
                        bodyColor: palette.baseElements),
                    primaryColor: palette.accent,
                    scrollbarTheme: ScrollbarThemeData(
                        thumbColor:
                            MaterialStateProperty.all<Color>(Colors.grey)),
                    dialogTheme: DialogTheme(
                      backgroundColor: palette.primary,
                      shape:
                          RoundedRectangleBorder(borderRadius: medBorderRadius),
                      titleTextStyle: TextStyle(color: palette.baseElements),
                      contentTextStyle: TextStyle(color: palette.baseElements),
                    ),
                    scaffoldBackgroundColor: palette.primary,
                    primaryIconTheme:
                        IconThemeData(color: palette.baseElements),
                    accentIconTheme: IconThemeData(color: palette.accent),
                    dividerColor: Colors.grey.withOpacity(0.7),
                    brightness: Brightness.dark,
                    backgroundColor: palette.primary,
                    buttonTheme: ButtonThemeData(
                      textTheme: ButtonTextTheme.primary,
                      padding: EdgeInsets.zero,
                      colorScheme: const ColorScheme.dark(),
                      shape:
                          RoundedRectangleBorder(borderRadius: medBorderRadius),
                    ),
                    dividerTheme: DividerThemeData(
                        color: palette.baseElements, thickness: 0.04),
                    fontFamily:
                        Provider.of<FontSettings>(context).currentSetting,
                  ),
                  routerDelegate: customRouter.delegate(initialRoutes: [
                    LandingLoadingScreenRoute(initLink: initDeepLink)
                  ]),
                  routeInformationParser: customRouter.defaultRouteParser(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
