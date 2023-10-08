import 'package:flutter/cupertino.dart';
import 'package:timezone/timezone.dart' as tz;

import 'headers.dart';
import 'notification/anroid_notifications.dart';
import 'notification/linux_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage(
    this.notificationAppLaunchDetails, {
    Key? key,
  }) : super(key: key);

  static const String routeName = '/';

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _linuxIconPathController =
      TextEditingController();

  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SecondPage(receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    print("LISTNING in HOME PAGE FOR SELECT NOTIFICATION STREAM");
    selectNotificationStream.stream.listen((String? payload) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => SecondPage(payload),
      ));
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child:
                        Text('Tap on a notification when it appears to trigger'
                            ' navigation'),
                  ),
                  InfoValueString(
                    title: 'Did notification launch app?',
                    value: widget.didNotificationLaunchApp,
                  ),
                  if (widget.didNotificationLaunchApp) ...<Widget>[
                    const Text('Launch notification details'),
                    InfoValueString(
                        title: 'Notification id',
                        value: widget.notificationAppLaunchDetails!
                            .notificationResponse?.id),
                    InfoValueString(
                        title: 'Action id',
                        value: widget.notificationAppLaunchDetails!
                            .notificationResponse?.actionId),
                    InfoValueString(
                        title: 'Input',
                        value: widget.notificationAppLaunchDetails!
                            .notificationResponse?.input),
                    InfoValueString(
                      title: 'Payload:',
                      value: widget.notificationAppLaunchDetails!
                          .notificationResponse?.payload,
                    ),
                  ],
                  PaddedElevatedButton(
                    buttonText: 'Show plain notification with payload',
                    onPressed: () async {
                      await AndroidNotifications.showNotification();
                    },
                  ),
                  PaddedElevatedButton(
                    buttonText:
                        'Show plain notification that has no title with '
                        'payload',
                    onPressed: () async {
                      await AndroidNotifications.showNotificationWithNoTitle();
                    },
                  ),
                  PaddedElevatedButton(
                    buttonText: 'Show plain notification that has no body with '
                        'payload',
                    onPressed: () async {
                      await AndroidNotifications.showNotificationWithNoBody();
                    },
                  ),
                  PaddedElevatedButton(
                    buttonText: 'Show notification with custom sound',
                    onPressed: () async {
                      await AndroidNotifications.showNotificationCustomSound();
                    },
                  ),
                  if (kIsWeb || !Platform.isLinux) ...<Widget>[
                    PaddedElevatedButton(
                      buttonText:
                          'Schedule notification to appear in 5 seconds '
                          'based on local time zone',
                      onPressed: () async {
                        await AndroidNotifications.zonedScheduleNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Schedule notification to appear in 5 seconds '
                          'based on local time zone using alarm clock',
                      onPressed: () async {
                        await AndroidNotifications
                            .zonedScheduleAlarmClockNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Repeat notification every minute',
                      onPressed: () async {
                        await AndroidNotifications.repeatNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Schedule daily 10:00:00 am notification in your '
                          'local time zone',
                      onPressed: () async {
                        await AndroidNotifications
                            .scheduleDailyTenAMNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Schedule daily 10:00:00 am notification in your '
                          "local time zone using last year's date",
                      onPressed: () async {
                        await AndroidNotifications
                            .scheduleDailyTenAMLastYearNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Schedule weekly 10:00:00 am notification in your '
                          'local time zone',
                      onPressed: () async {
                        await AndroidNotifications
                            .scheduleWeeklyTenAMNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Schedule weekly Monday 10:00:00 am notification '
                          'in your local time zone',
                      onPressed: () async {
                        await AndroidNotifications
                            .scheduleWeeklyMondayTenAMNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Check pending notifications',
                      onPressed: () async {
                        await checkPendingNotificationRequests();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Get active notifications',
                      onPressed: () async {
                        await getActiveNotifications();
                      },
                    ),
                  ],
                  PaddedElevatedButton(
                    buttonText:
                        'Schedule monthly Monday 10:00:00 am notification in '
                        'your local time zone',
                    onPressed: () async {
                      await AndroidNotifications
                          .scheduleMonthlyMondayTenAMNotification();
                    },
                  ),
                  PaddedElevatedButton(
                    buttonText:
                        'Schedule yearly Monday 10:00:00 am notification in '
                        'your local time zone',
                    onPressed: () async {
                      await AndroidNotifications
                          .scheduleYearlyMondayTenAMNotification();
                    },
                  ),
                  PaddedElevatedButton(
                    buttonText: 'Show notification with no sound',
                    onPressed: () async {
                      await AndroidNotifications.showNotificationWithNoSound();
                    },
                  ),
                  PaddedElevatedButton(
                    buttonText: 'Cancel latest notification',
                    onPressed: () async {
                      await AndroidNotifications.cancelNotification();
                    },
                  ),
                  PaddedElevatedButton(
                    buttonText: 'Cancel all notifications',
                    onPressed: () async {
                      await AndroidNotifications.cancelAllNotifications();
                    },
                  ),
                  const Divider(),
                  const Text(
                    'Notifications with actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  PaddedElevatedButton(
                    buttonText: 'Show notification with plain actions',
                    onPressed: () async {
                      await AndroidNotifications.showNotificationWithActions();
                    },
                  ),
                  if (Platform.isLinux)
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification with icon action (if supported)',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithIconAction();
                      },
                    ),
                  if (!Platform.isLinux)
                    PaddedElevatedButton(
                      buttonText: 'Show notification with text action',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithTextAction();
                      },
                    ),
                  if (!Platform.isLinux)
                    PaddedElevatedButton(
                      buttonText: 'Show notification with text choice',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithTextChoice();
                      },
                    ),
                  const Divider(),
                  if (Platform.isAndroid) ...<Widget>[
                    const Text(
                      'Android-specific examples',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                        'notifications enabled: $AndroidNotifications.notificationsEnabled'),
                    PaddedElevatedButton(
                      buttonText:
                          'Check if notifications are enabled for this app',
                      onPressed: _areNotifcationsEnabledOnAndroid,
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Request permission (API 33+)',
                      onPressed: () => _requestPermissions(),
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show plain notification with payload and update '
                          'channel description',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationUpdateChannelDescription();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show plain notification as public on every '
                          'lockscreen',
                      onPressed: () async {
                        await AndroidNotifications.showPublicNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification with custom vibration pattern, '
                          'red LED and red icon',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationCustomVibrationIconLed();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification using Android Uri sound',
                      onPressed: () async {
                        await AndroidNotifications.showSoundUriNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification that times out after 3 seconds',
                      onPressed: () async {
                        await AndroidNotifications.showTimeoutNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show insistent notification',
                      onPressed: () async {
                        await AndroidNotifications.showInsistentNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show big picture notification using local images',
                      onPressed: () async {
                        await AndroidNotifications.showBigPictureNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show big picture notification using base64 String '
                          'for images',
                      onPressed: () async {
                        await AndroidNotifications
                            .showBigPictureNotificationBase64();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show big picture notification using URLs for '
                          'Images',
                      onPressed: () async {
                        await AndroidNotifications
                            .showBigPictureNotificationURL();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show big picture notification, hide large icon '
                          'on expand',
                      onPressed: () async {
                        await AndroidNotifications
                            .showBigPictureNotificationHiddenLargeIcon();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show media notification',
                      onPressed: () async {
                        await AndroidNotifications.showNotificationMediaStyle();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show big text notification',
                      onPressed: () async {
                        await AndroidNotifications.showBigTextNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show inbox notification',
                      onPressed: () async {
                        await AndroidNotifications.showInboxNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show messaging notification',
                      onPressed: () async {
                        await AndroidNotifications.showMessagingNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show grouped notifications',
                      onPressed: () async {
                        await AndroidNotifications.showGroupedNotifications();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with tag',
                      onPressed: () async {
                        await AndroidNotifications.showNotificationWithTag();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Cancel notification with tag',
                      onPressed: () async {
                        await AndroidNotifications.cancelNotificationWithTag();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show ongoing notification',
                      onPressed: () async {
                        await AndroidNotifications.showOngoingNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification with no badge, alert only once',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithNoBadge();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show progress notification - updates every second',
                      onPressed: () async {
                        await AndroidNotifications.showProgressNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show indeterminate progress notification',
                      onPressed: () async {
                        await AndroidNotifications
                            .showIndeterminateProgressNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification without timestamp',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithoutTimestamp();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with custom timestamp',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithCustomTimestamp();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with custom sub-text',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithCustomSubText();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with chronometer',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithChronometer();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show full-screen notification',
                      onPressed: () async {
                        await showFullScreenNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification with number if the launcher '
                          'supports',
                      onPressed: () async {
                        await AndroidNotifications.showNotificationWithNumber();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with sound controlled by '
                          'alarm volume',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithAudioAttributeAlarm();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Create grouped notification channels',
                      onPressed: () async {
                        await createNotificationChannelGroup();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Delete notification channel group',
                      onPressed: () async {
                        await deleteNotificationChannelGroup();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Create notification channel',
                      onPressed: () async {
                        await createNotificationChannel();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Delete notification channel',
                      onPressed: () async {
                        await deleteNotificationChannel();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Get notification channels',
                      onPressed: () async {
                        await getNotificationChannels();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Start foreground service',
                      onPressed: () async {
                        await AndroidNotifications.startForegroundService();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Start foreground service with blue background '
                          'notification',
                      onPressed: () async {
                        await AndroidNotifications
                            .startForegroundServiceWithBlueBackgroundNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Stop foreground service',
                      onPressed: () async {
                        await AndroidNotifications.stopForegroundService();
                      },
                    ),
                  ],
                  if (!kIsWeb &&
                      (Platform.isIOS || Platform.isMacOS)) ...<Widget>[
                    const Text(
                      'iOS and macOS-specific examples',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Request permission',
                      onPressed: _requestPermissions,
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with subtitle',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithSubtitle();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with icon badge',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithIconBadge();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification with attachment (with thumbnail)',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithAttachment(
                                hideThumbnail: false);
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification with attachment (no thumbnail)',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithAttachment(
                                hideThumbnail: true);
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification with attachment (clipped thumbnail)',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithClippedThumbnailAttachment();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notifications with thread identifier',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationsWithThreadIdentifier();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification with time sensitive interruption '
                          'level',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithTimeSensitiveInterruptionLevel();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with banner but not in '
                          'notification centre',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationWithBannerNotInNotificationCentre();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText:
                          'Show notification in notification centre only',
                      onPressed: () async {
                        await AndroidNotifications
                            .showNotificationInNotificationCentreOnly();
                      },
                    ),
                  ],
                  if (!kIsWeb && Platform.isLinux) ...<Widget>[
                    const Text(
                      'Linux-specific examples',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder<LinuxServerCapabilities>(
                      future: LinuxNotifications.getLinuxCapabilities(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<LinuxServerCapabilities> snapshot,
                      ) {
                        if (snapshot.hasData) {
                          final LinuxServerCapabilities caps = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Capabilities of the current system:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                InfoValueString(
                                  title: 'Body text:',
                                  value: caps.body,
                                ),
                                InfoValueString(
                                  title: 'Hyperlinks in body text:',
                                  value: caps.bodyHyperlinks,
                                ),
                                InfoValueString(
                                  title: 'Images in body:',
                                  value: caps.bodyImages,
                                ),
                                InfoValueString(
                                  title: 'Markup in the body text:',
                                  value: caps.bodyMarkup,
                                ),
                                InfoValueString(
                                  title: 'Animated icons:',
                                  value: caps.iconMulti,
                                ),
                                InfoValueString(
                                  title: 'Static icons:',
                                  value: caps.iconStatic,
                                ),
                                InfoValueString(
                                  title: 'Notification persistence:',
                                  value: caps.persistence,
                                ),
                                InfoValueString(
                                  title: 'Sound:',
                                  value: caps.sound,
                                ),
                                InfoValueString(
                                  title: 'Actions:',
                                  value: caps.actions,
                                ),
                                InfoValueString(
                                  title: 'Action icons:',
                                  value: caps.actionIcons,
                                ),
                                InfoValueString(
                                  title: 'Other capabilities:',
                                  value: caps.otherCapabilities,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with body markup',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationWithBodyMarkup();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with category',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationWithCategory();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with byte data icon',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationWithByteDataIcon();
                      },
                    ),
                    Builder(
                      builder: (BuildContext context) => PaddedElevatedButton(
                        buttonText: 'Show notification with file path icon',
                        onPressed: () async {
                          final String path = _linuxIconPathController.text;
                          if (path.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter the icon path'),
                              ),
                            );
                            return;
                          }
                          await LinuxNotifications
                              .showLinuxNotificationWithPathIcon(path);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: TextField(
                        controller: _linuxIconPathController,
                        decoration: InputDecoration(
                          hintText: 'Enter the icon path',
                          constraints: const BoxConstraints.tightFor(
                            width: 300,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _linuxIconPathController.clear(),
                          ),
                        ),
                      ),
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with theme icon',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationWithThemeIcon();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with theme sound',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationWithThemeSound();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with critical urgency',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationWithCriticalUrgency();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification with timeout',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationWithTimeout();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Suppress notification sound',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationSuppressSound();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Transient notification',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationTransient();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Resident notification',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationResident();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Show notification on '
                          'different screen location',
                      onPressed: () async {
                        await LinuxNotifications
                            .showLinuxNotificationDifferentLocation();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content:
            Text('${pendingNotificationRequests.length} pending notification '
                'requests'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> createNotificationChannelGroup() async {
    const String channelGroupId = 'your channel group id';
    // create the group first
    const AndroidNotificationChannelGroup androidNotificationChannelGroup =
        AndroidNotificationChannelGroup(
            channelGroupId, 'your channel group name',
            description: 'your channel group description');
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannelGroup(androidNotificationChannelGroup);

    // create channels associated with the group
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(const AndroidNotificationChannel(
            'grouped channel id 1', 'grouped channel name 1',
            description: 'grouped channel description 1',
            groupId: channelGroupId));

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(const AndroidNotificationChannel(
            'grouped channel id 2', 'grouped channel name 2',
            description: 'grouped channel description 2',
            groupId: channelGroupId));

    await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Text('Channel group with name '
                  '${androidNotificationChannelGroup.name} created'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  Future<void> deleteNotificationChannelGroup() async {
    const String channelGroupId = 'your channel group id';
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannelGroup(channelGroupId);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Channel group with id $channelGroupId deleted'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      'your channel id 2',
      'your channel name 2',
      description: 'your channel description 2',
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content:
                  Text('Channel with name ${androidNotificationChannel.name} '
                      'created'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  Future<void> deleteNotificationChannel() async {
    const String channelId = 'your channel id 2';
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Channel with id $channelId deleted'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> getActiveNotifications() async {
    final Widget activeNotificationsDialogContent =
        await _getActiveNotificationsDialogContent();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: activeNotificationsDialogContent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> getActiveNotificationMessagingStyle(int id, String? tag) async {
    Widget dialogContent;
    try {
      final MessagingStyleInformation? messagingStyle =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .getActiveNotificationMessagingStyle(id, tag: tag);
      if (messagingStyle == null) {
        dialogContent = const Text('No messaging style');
      } else {
        dialogContent = SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('person: ${_formatPerson(messagingStyle.person)}\n'
                'conversationTitle: ${messagingStyle.conversationTitle}\n'
                'groupConversation: ${messagingStyle.groupConversation}'),
            const Divider(color: Colors.black),
            if (messagingStyle.messages == null) const Text('No messages'),
            if (messagingStyle.messages != null)
              for (final Message msg in messagingStyle.messages!)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('text: ${msg.text}\n'
                        'timestamp: ${msg.timestamp}\n'
                        'person: ${_formatPerson(msg.person)}'),
                    const Divider(color: Colors.black),
                  ],
                ),
          ],
        ));
      }
    } on PlatformException catch (error) {
      dialogContent = Text(
        'Error calling "getActiveNotificationMessagingStyle"\n'
        'code: ${error.code}\n'
        'message: ${error.message}',
      );
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Messaging style'),
        content: dialogContent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatPerson(Person? person) {
    if (person == null) {
      return 'null';
    }

    final List<String> attrs = <String>[];
    if (person.name != null) {
      attrs.add('name: "${person.name}"');
    }
    if (person.uri != null) {
      attrs.add('uri: "${person.uri}"');
    }
    if (person.key != null) {
      attrs.add('key: "${person.key}"');
    }
    if (person.important) {
      attrs.add('important: true');
    }
    if (person.bot) {
      attrs.add('bot: true');
    }
    if (person.icon != null) {
      attrs.add('icon: ${_formatAndroidIcon(person.icon)}');
    }
    return 'Person(${attrs.join(', ')})';
  }

  String _formatAndroidIcon(Object? icon) {
    if (icon == null) {
      return 'null';
    }
    if (icon is DrawableResourceAndroidIcon) {
      return 'DrawableResourceAndroidIcon("${icon.data}")';
    } else if (icon is ContentUriAndroidIcon) {
      return 'ContentUriAndroidIcon("${icon.data}")';
    } else {
      return 'AndroidIcon()';
    }
  }

  Future<void> getNotificationChannels() async {
    final Widget notificationChannelsDialogContent =
        await _getNotificationChannelsDialogContent();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: notificationChannelsDialogContent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Widget> _getNotificationChannelsDialogContent() async {
    try {
      final List<AndroidNotificationChannel>? channels =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .getNotificationChannels();

      return Container(
        width: double.maxFinite,
        child: ListView(
          children: <Widget>[
            const Text(
              'Notifications Channels',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.black),
            if (channels?.isEmpty ?? true)
              const Text('No notification channels')
            else
              for (AndroidNotificationChannel channel in channels!)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('id: ${channel.id}\n'
                        'name: ${channel.name}\n'
                        'description: ${channel.description}\n'
                        'groupId: ${channel.groupId}\n'
                        'importance: ${channel.importance.value}\n'
                        'playSound: ${channel.playSound}\n'
                        'sound: ${channel.sound?.sound}\n'
                        'enableVibration: ${channel.enableVibration}\n'
                        'vibrationPattern: ${channel.vibrationPattern}\n'
                        'showBadge: ${channel.showBadge}\n'
                        'enableLights: ${channel.enableLights}\n'
                        'ledColor: ${channel.ledColor}\n'),
                    const Divider(color: Colors.black),
                  ],
                ),
          ],
        ),
      );
    } on PlatformException catch (error) {
      return Text(
        'Error calling "getNotificationChannels"\n'
        'code: ${error.code}\n'
        'message: ${error.message}',
      );
    }
  }

  Future<void> _areNotifcationsEnabledOnAndroid() async {
    final bool? areEnabled = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Text(areEnabled == null
                  ? 'ERROR: received null'
                  : (areEnabled
                      ? 'Notifications are enabled'
                      : 'Notifications are NOT enabled')),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  Future<Widget> _getActiveNotificationsDialogContent() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 23) {
        return const Text(
          '"getActiveNotifications" is available only for Android 6.0 or newer',
        );
      }
    } else if (Platform.isIOS) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final List<String> fullVersion = iosInfo.systemVersion!.split('.');
      if (fullVersion.isNotEmpty) {
        final int? version = int.tryParse(fullVersion[0]);
        if (version != null && version < 10) {
          return const Text(
            '"getActiveNotifications" is available only for iOS 10.0 or newer',
          );
        }
      }
    }

    try {
      final List<ActiveNotification>? activeNotifications =
          await flutterLocalNotificationsPlugin.getActiveNotifications();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Active Notifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.black),
          if (activeNotifications!.isEmpty)
            const Text('No active notifications'),
          if (activeNotifications.isNotEmpty)
            for (ActiveNotification activeNotification in activeNotifications)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'id: ${activeNotification.id}\n'
                    'channelId: ${activeNotification.channelId}\n'
                    'groupKey: ${activeNotification.groupKey}\n'
                    'tag: ${activeNotification.tag}\n'
                    'title: ${activeNotification.title}\n'
                    'body: ${activeNotification.body}',
                  ),
                  if (Platform.isAndroid && activeNotification.id != null)
                    TextButton(
                      child: const Text('Get messaging style'),
                      onPressed: () {
                        getActiveNotificationMessagingStyle(
                            activeNotification.id!, activeNotification.tag);
                      },
                    ),
                  const Divider(color: Colors.black),
                ],
              ),
        ],
      );
    } on PlatformException catch (error) {
      return Text(
        'Error calling "getActiveNotifications"\n'
        'code: ${error.code}\n'
        'message: ${error.message}',
      );
    }
  }

  Future<void> showFullScreenNotification() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Turn off your screen'),
        content: const Text(
            'to see the full-screen intent in 5 seconds, press OK and TURN '
            'OFF your screen'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await flutterLocalNotificationsPlugin.zonedSchedule(
                  0,
                  'scheduled title',
                  'scheduled body',
                  tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
                  const NotificationDetails(
                      android: AndroidNotificationDetails(
                          'full screen channel id', 'full screen channel name',
                          channelDescription: 'full screen channel description',
                          priority: Priority.high,
                          importance: Importance.high,
                          fullScreenIntent: true)),
                  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                  uiLocalNotificationDateInterpretation:
                      UILocalNotificationDateInterpretation.absoluteTime);

              Navigator.pop(context);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
