# Graph Report - .  (2026-06-08)

## Corpus Check
- Corpus is ~28,938 words - fits in a single context window. You may not need a graph.

## Summary
- 264 nodes · 268 edges · 33 communities (23 shown, 10 thin omitted)
- Extraction: 94% EXTRACTED · 6% INFERRED · 0% AMBIGUOUS · INFERRED: 16 edges (avg confidence: 0.85)
- Token cost: 121,603 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Home Screen UI|Home Screen UI]]
- [[_COMMUNITY_Windows Native Window|Windows Native Window]]
- [[_COMMUNITY_App Core & Notification Flow|App Core & Notification Flow]]
- [[_COMMUNITY_Linux App Runner|Linux App Runner]]
- [[_COMMUNITY_Windows Flutter Runner|Windows Flutter Runner]]
- [[_COMMUNITY_Apple Plugin Bootstrap|Apple Plugin Bootstrap]]
- [[_COMMUNITY_Add Course Screen|Add Course Screen]]
- [[_COMMUNITY_Splash Screen UI|Splash Screen UI]]
- [[_COMMUNITY_Notification Screen UI|Notification Screen UI]]
- [[_COMMUNITY_Web App Manifest|Web App Manifest]]
- [[_COMMUNITY_Apple AppDelegate Lifecycle|Apple AppDelegate Lifecycle]]
- [[_COMMUNITY_App Entry & Timezone Init|App Entry & Timezone Init]]
- [[_COMMUNITY_Notification Service|Notification Service]]
- [[_COMMUNITY_Platform Unit Tests|Platform Unit Tests]]
- [[_COMMUNITY_App Icon Branding|App Icon Branding]]
- [[_COMMUNITY_iOS Icon Asset Catalog|iOS Icon Asset Catalog]]
- [[_COMMUNITY_iOS Launch Asset Catalog|iOS Launch Asset Catalog]]
- [[_COMMUNITY_macOS Icon Asset Catalog|macOS Icon Asset Catalog]]
- [[_COMMUNITY_iOS LLDB Debug Helper|iOS LLDB Debug Helper]]
- [[_COMMUNITY_Android Plugin Registrant|Android Plugin Registrant]]
- [[_COMMUNITY_Android Main Activity|Android Main Activity]]
- [[_COMMUNITY_iOS Scene Delegate|iOS Scene Delegate]]
- [[_COMMUNITY_Android Build Config|Android Build Config]]
- [[_COMMUNITY_iOS Build Env Script|iOS Build Env Script]]
- [[_COMMUNITY_Course Model|Course Model]]
- [[_COMMUNITY_macOS Build Env Script|macOS Build Env Script]]
- [[_COMMUNITY_NotificationService Class|NotificationService Class]]
- [[_COMMUNITY_iOS Launch Image|iOS Launch Image]]

## God Nodes (most connected - your core abstractions)
1. `WindowClassRegistrar` - 8 edges
2. `Create()` - 7 edges
3. `Destroy()` - 7 edges
4. `scheduleCourseNotifications` - 6 edges
5. `AppDelegate` - 5 edges
6. `_MyApplication` - 5 edges
7. `wWinMain()` - 5 edges
8. `Win32Window()` - 5 edges
9. `MessageHandler()` - 5 edges
10. `Course model` - 5 edges

## Surprising Connections (you probably didn't know these)
- `main()` --semantically_similar_to--> `wWinMain()`  [INFERRED] [semantically similar]
  linux/runner/main.cc → windows/runner/main.cpp
- `_MyApplication` --semantically_similar_to--> `Win32Window()`  [INFERRED] [semantically similar]
  linux/runner/my_application.cc → windows/runner/win32_window.cpp
- `iOS App Icon (AppIcon.appiconset, 20x20 to 1024x1024 variants)` --semantically_similar_to--> `App Icon — white calendar with red X on black rounded square`  [INFERRED] [semantically similar]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png → assets/icon.png
- `macOS App Icon — Flutter logo on white rounded-square (squircle) background` --semantically_similar_to--> `App Icon — white calendar with red X on black rounded square`  [INFERRED] [semantically similar]
  macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png → assets/icon.png
- `Web App Icon — Flutter logo (transparent background, standard and maskable variants)` --semantically_similar_to--> `App Icon — white calendar with red X on black rounded square`  [INFERRED] [semantically similar]
  web/icons/Icon-512.png → assets/icon.png

## Hyperedges (group relationships)
- **Course notification scheduling flow** — notifications_notification_screen_togglemorningreminder, services_notification_service_schedulecoursenotifications, services_notification_service_schedulenotification, services_notification_service_cancelall, services_notification_service_getdayname [EXTRACTED 1.00]
- **Course persistence and reschedule lifecycle** — features_home_screen_savecourses, features_home_screen_loaddata, concept_shared_preferences_persistence, models_course_model_course, services_notification_service_schedulecoursenotifications [INFERRED 0.85]
- **Course creation flow** — features_home_screen_gotoaddcoursescreen, schedule_add_course_screen_addcoursescreen, schedule_add_course_screen_savecourse, models_course_model_course [EXTRACTED 1.00]
- **Flutter plugin registration bootstrap across platforms** — runner_appdelegate_didinitializeimplicitflutterengine, runner_generatedpluginregistrant_registerwithregistry, flutter_generatedpluginregistrant_registergeneratedplugins [INFERRED 0.85]
- **Cross-platform Plugin Registration** — plugins_generatedpluginregistrant_generatedpluginregistrant, flutter_generated_plugin_registrant_fl_register_plugins, flutter_generated_plugin_registrant_registerplugins [INFERRED 0.85]
- **Native App Bootstrap Entry Points** — runner_main_main, runner_main_wwinmain, runner_my_application_myapplication, runner_flutter_window_flutterwindow [INFERRED 0.75]
- **App Branding Icon Set (all platform/resolution variants)** — app_icon_artwork, android_launcher_icon, ios_app_icon [INFERRED 0.95]
- **App Branding — platform icons and launch imagery** — macos_app_icon, web_app_icon, app_icon_artwork, ios_launch_image [INFERRED 0.75]

## Communities (33 total, 10 thin omitted)

### Community 0 - "Home Screen UI"
Cohesion: 0.06
Nodes (31): dart:convert, ../core/models/course_model.dart, ../core/services/notification_service.dart, package:flutter/material.dart, package:shared_preferences/shared_preferences.dart, notifications/notification_screen.dart, schedule/add_course_screen.dart, build (+23 more)

### Community 1 - "Windows Native Window"
Cohesion: 0.12
Nodes (21): OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle(), GetWindowClass(), MessageHandler() (+13 more)

### Community 2 - "App Core & Notification Flow"
Cohesion: 0.12
Nodes (21): morning_reminder setting flag, SharedPreferences persistence (saved_courses), _goToAddCourseScreen, HomeScreen, _loadData, _markAbsent, _saveCourses, SplashScreen (+13 more)

### Community 3 - "Linux App Runner"
Cohesion: 0.12
Nodes (7): fl_register_plugins(), main(), my_application_activate(), my_application_new(), _MyApplication, dart_entrypoint_arguments, parent_instance

### Community 4 - "Windows Flutter Runner"
Cohesion: 0.13
Nodes (6): RegisterPlugins(), FlutterWindow (Windows), wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 5 - "Apple Plugin Bootstrap"
Cohesion: 0.13
Nodes (12): RegisterGeneratedPlugins(), NSWindow, iOS AppDelegate, macOS AppDelegate, iOS didInitializeImplicitFlutterEngine, GeneratedPluginRegistrant, -registerWithRegistry, iOS registerWithRegistry (+4 more)

### Community 6 - "Add Course Screen"
Cohesion: 0.17
Nodes (11): ../../core/models/course_model.dart, package:flutter/material.dart, AddCourseScreen, _AddCourseScreenState, build, _buildCounterButton, dispose, InkWell (+3 more)

### Community 7 - "Splash Screen UI"
Cohesion: 0.17
Nodes (11): home_screen.dart, package:flutter/material.dart, build, dispose, initState, Row, Scaffold, SizedBox (+3 more)

### Community 8 - "Notification Screen UI"
Cohesion: 0.18
Nodes (10): ../../core/models/course_model.dart, ../../core/services/notification_service.dart, package:flutter/material.dart, package:shared_preferences/shared_preferences.dart, build, initState, NotificationScreen, _NotificationScreenState (+2 more)

### Community 9 - "Web App Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 10 - "Apple AppDelegate Lifecycle"
Cohesion: 0.20
Nodes (4): FlutterAppDelegate, FlutterImplicitEngineDelegate, AppDelegate, AppDelegate

### Community 11 - "App Entry & Timezone Init"
Cohesion: 0.20
Nodes (9): features/splash_screen.dart, core/services/notification_service.dart, package:flutter/material.dart, package:timezone/timezone.dart, package:timezone/data/latest_all.dart, build, DevamsizlikTakipApp, main (+1 more)

### Community 12 - "Notification Service"
Cohesion: 0.25
Nodes (7): package:timezone/timezone.dart, ../models/course_model.dart, package:flutter_local_notifications/flutter_local_notifications.dart, cancelAll, _getDayName, NotificationService, _scheduleNotification

### Community 13 - "Platform Unit Tests"
Cohesion: 0.29
Nodes (3): RunnerTests, RunnerTests, XCTestCase

### Community 14 - "App Icon Branding"
Cohesion: 0.40
Nodes (6): Android Launcher Icon (mipmap hdpi/mdpi/xhdpi/xxhdpi/xxxhdpi), App Icon — white calendar with red X on black rounded square, Calendar app branding: minimalist flat calendar glyph (white outline, three top binding rings, 3x4 grid of day cells) on a near-black rounded-square ground; one cell marked by a small red square crossed out with a grey X — implies a scheduling/calendar app emphasizing a cancelled, blocked, or unavailable day. Same artwork used across all platforms/resolutions., iOS App Icon (AppIcon.appiconset, 20x20 to 1024x1024 variants), macOS App Icon — Flutter logo on white rounded-square (squircle) background, Web App Icon — Flutter logo (transparent background, standard and maskable variants)

### Community 15 - "iOS Icon Asset Catalog"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 16 - "iOS Launch Asset Catalog"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 17 - "macOS Icon Asset Catalog"
Cohesion: 0.40
Nodes (4): images, info, author, version

## Knowledge Gaps
- **122 isolated node(s):** `flutter_export_environment.sh script`, `-registerWithRegistry`, `images`, `version`, `author` (+117 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Win32Window()` connect `Windows Native Window` to `Linux App Runner`, `Windows Flutter Runner`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `_MyApplication` connect `Linux App Runner` to `Windows Native Window`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **Why does `wWinMain()` connect `Windows Flutter Runner` to `Linux App Runner`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `flutter_export_environment.sh script`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry` to the rest of the system?**
  _124 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Home Screen UI` be split into smaller, more focused modules?**
  _Cohesion score 0.0625 - nodes in this community are weakly interconnected._
- **Should `Windows Native Window` be split into smaller, more focused modules?**
  _Cohesion score 0.12169312169312169 - nodes in this community are weakly interconnected._
- **Should `App Core & Notification Flow` be split into smaller, more focused modules?**
  _Cohesion score 0.11904761904761904 - nodes in this community are weakly interconnected._