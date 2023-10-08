import 'package:image/image.dart' as image;

import '../headers.dart';

mixin LinuxNotifications {
  static Future<void> showLinuxNotificationWithBodyMarkup() async {
    await flutterLocalNotificationsPlugin.show(
      id++,
      'notification with body markup',
      '<b>bold text</b>\n'
          '<i>italic text</i>\n'
          '<u>underline text</u>\n'
          'https://example.com\n'
          '<a href="https://example.com">example.com</a>',
      null,
    );
  }

  static Future<void> showLinuxNotificationWithCategory() async {
    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      category: LinuxNotificationCategory.emailArrived,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'notification with category',
      null,
      notificationDetails,
    );
  }

  static Future<void> showLinuxNotificationWithByteDataIcon() async {
    final ByteData assetIcon = await rootBundle.load(
      'icons/appicondensity.png',
    );
    final image.Image? iconData = image.decodePng(
      assetIcon.buffer.asUint8List(),
    );
    final Uint8List iconBytes = iconData!.getBytes();
    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      icon: ByteDataLinuxIcon(
        LinuxRawIconData(
          data: iconBytes,
          width: iconData.width,
          height: iconData.height,
          channels: 4, // The icon has an alpha channel
          hasAlpha: true,
        ),
      ),
    );
    final NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'notification with byte data icon',
      null,
      notificationDetails,
    );
  }

  static Future<void> showLinuxNotificationWithPathIcon(String path) async {
    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(icon: FilePathLinuxIcon(path));
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'notification with file path icon',
      null,
      platformChannelSpecifics,
    );
  }

  static Future<void> showLinuxNotificationWithThemeIcon() async {
    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      icon: ThemeLinuxIcon('media-eject'),
    );
    final NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'notification with theme icon',
      null,
      notificationDetails,
    );
  }

  static Future<void> showLinuxNotificationWithThemeSound() async {
    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      sound: ThemeLinuxSound('message-new-email'),
    );
    final NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'notification with theme sound',
      null,
      notificationDetails,
    );
  }

  static Future<void> showLinuxNotificationWithCriticalUrgency() async {
    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'notification with critical urgency',
      null,
      notificationDetails,
    );
  }

  static Future<void> showLinuxNotificationWithTimeout() async {
    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      timeout: LinuxNotificationTimeout.fromDuration(
        const Duration(seconds: 1),
      ),
    );
    final NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'notification with timeout',
      null,
      notificationDetails,
    );
  }

  static Future<void> showLinuxNotificationSuppressSound() async {
    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      suppressSound: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'suppress notification sound',
      null,
      notificationDetails,
    );
  }

  static Future<void> showLinuxNotificationTransient() async {
    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      transient: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'transient notification',
      null,
      notificationDetails,
    );
  }

  static Future<void> showLinuxNotificationResident() async {
    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      resident: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'resident notification',
      null,
      notificationDetails,
    );
  }

  static Future<void> showLinuxNotificationDifferentLocation() async {
    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(location: LinuxNotificationLocation(10, 10));
    const NotificationDetails notificationDetails = NotificationDetails(
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'notification on different screen location',
      null,
      notificationDetails,
    );
  }

  static Future<LinuxServerCapabilities> getLinuxCapabilities() =>
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              LinuxFlutterLocalNotificationsPlugin>()!
          .getCapabilities();
}
