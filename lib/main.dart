import 'headers.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (kDebugMode) {
    print('Backgroun NOTIFICATION RECIVED ${toString(notificationResponse)}');
  }
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationHelper().initialize(notificationTapBackground);

  runApp(
    MaterialApp(
      initialRoute: AppRoutes.initialRoute,
      routes: <String, WidgetBuilder>{
        HomePage.routeName: (_) =>
            HomePage(NotificationHelper.notificationAppLaunchDetails),
        SecondPage.routeName: (_) =>
            SecondPage(NotificationHelper.selectedNotificationPayload)
      },
    ),
  );
}
