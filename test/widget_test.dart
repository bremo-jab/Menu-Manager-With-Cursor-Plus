// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:menu_manager/main.dart';
import 'package:menu_manager/app/routes/app_pages.dart';
import 'package:menu_manager/app/controllers/auth_controller.dart';
import 'package:menu_manager/app/services/notification_service.dart';
import 'package:menu_manager/app/controllers/notifications_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([
  SharedPreferences,
  AuthController,
  NotificationService,
  NotificationsController,
])
void main() {
  late MockSharedPreferences mockPrefs;
  late MockAuthController mockAuthController;
  late MockNotificationService mockNotificationService;
  late MockNotificationsController mockNotificationsController;

  setUp(() async {
    // Initialize mocks
    mockPrefs = MockSharedPreferences();
    mockAuthController = MockAuthController();
    mockNotificationService = MockNotificationService();
    mockNotificationsController = MockNotificationsController();

    // Setup SharedPreferences mock
    SharedPreferences.setMockInitialValues({});

    // Setup GetX bindings
    Get.put<SharedPreferences>(mockPrefs);
    Get.put<AuthController>(mockAuthController);
    Get.put<NotificationService>(mockNotificationService);
    Get.put<NotificationsController>(mockNotificationsController);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('SplashPage should show loading indicator',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      GetMaterialApp(
        title: 'Menu Manager',
        initialRoute: Routes.LOGIN,
        getPages: AppPages.routes,
      ),
    );
    await tester.pump();

    // Verify that we see the loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('App should use Cairo font', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      GetMaterialApp(
        title: 'Menu Manager',
        initialRoute: Routes.LOGIN,
        getPages: AppPages.routes,
      ),
    );
    await tester.pump();

    // Verify that the app uses Cairo font
    final textWidget = tester.widget<Text>(find.text('Menu Manager'));
    expect(textWidget.style?.fontFamily, 'Cairo');
  });

  testWidgets('App should use correct theme colors',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      GetMaterialApp(
        title: 'Menu Manager',
        initialRoute: Routes.LOGIN,
        getPages: AppPages.routes,
      ),
    );
    await tester.pump();

    // Verify gradient colors in the container
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    final gradient = decoration.gradient as LinearGradient;

    expect(gradient.colors[0], const Color(0xFF1E3C72));
    expect(gradient.colors[1], const Color(0xFF2A5298));
  });

  group('Authentication Flow Tests', () {
    testWidgets('Should redirect to login when not logged in',
        (WidgetTester tester) async {
      // Setup mock preferences
      when(mockPrefs.getBool('isLoggedIn')).thenReturn(false);
      when(mockPrefs.getString('userId')).thenReturn(null);

      // Setup auth controller mock
      when(mockAuthController.checkLoginStatus())
          .thenAnswer((_) async => false);
      when(mockAuthController.checkUserStateAndRedirect())
          .thenAnswer((_) async {
        Get.offAllNamed(Routes.LOGIN);
      });

      // Build app and wait for redirect
      await tester.pumpWidget(
        GetMaterialApp(
          title: 'Menu Manager',
          initialRoute: Routes.LOGIN,
          getPages: AppPages.routes,
        ),
      );
      await tester.pumpAndSettle();

      // Verify redirect to login
      verify(mockAuthController.checkUserStateAndRedirect()).called(1);
    });

    testWidgets('Should redirect to restaurant info when profile incomplete',
        (WidgetTester tester) async {
      // Setup mock preferences
      when(mockPrefs.getBool('isLoggedIn')).thenReturn(true);
      when(mockPrefs.getString('userId')).thenReturn('test_user');

      // Setup auth controller mock
      when(mockAuthController.checkLoginStatus()).thenAnswer((_) async => true);
      when(mockAuthController.checkRestaurantProfileCompletion())
          .thenAnswer((_) async => false);
      when(mockAuthController.checkUserStateAndRedirect())
          .thenAnswer((_) async {
        Get.offAllNamed(Routes.RESTAURANT_SETUP);
      });

      // Build app and wait for redirect
      await tester.pumpWidget(
        GetMaterialApp(
          title: 'Menu Manager',
          initialRoute: Routes.LOGIN,
          getPages: AppPages.routes,
        ),
      );
      await tester.pumpAndSettle();

      // Verify redirect to restaurant info
      verify(mockAuthController.checkUserStateAndRedirect()).called(1);
    });

    testWidgets('Should redirect to dashboard when profile complete',
        (WidgetTester tester) async {
      // Setup mock preferences
      when(mockPrefs.getBool('isLoggedIn')).thenReturn(true);
      when(mockPrefs.getString('userId')).thenReturn('test_user');

      // Setup auth controller mock
      when(mockAuthController.checkLoginStatus()).thenAnswer((_) async => true);
      when(mockAuthController.checkRestaurantProfileCompletion())
          .thenAnswer((_) async => true);
      when(mockAuthController.checkUserStateAndRedirect())
          .thenAnswer((_) async {
        Get.offAllNamed(Routes.MENU);
      });

      // Build app and wait for redirect
      await tester.pumpWidget(
        GetMaterialApp(
          title: 'Menu Manager',
          initialRoute: Routes.LOGIN,
          getPages: AppPages.routes,
        ),
      );
      await tester.pumpAndSettle();

      // Verify redirect to dashboard
      verify(mockAuthController.checkUserStateAndRedirect()).called(1);
    });
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        title: 'Menu Manager',
        initialRoute: Routes.LOGIN,
        getPages: AppPages.routes,
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
