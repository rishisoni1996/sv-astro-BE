import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtil {
  static SharedPreferences? _instance;

  static setInstance(SharedPreferences preferences) => _instance = preferences;

  static Future<bool> save(SharedPrefEnum _key, dynamic _param) async {
    if (_param is String)
      return await _instance!.setString(_key.toString(), _param);
    else if (_param is double)
      return await _instance!.setDouble(_key.toString(), _param);
    else if (_param is int)
      return await _instance!.setInt(_key.toString(), _param);
    else if (_param is bool)
      return await _instance!.setBool(_key.toString(), _param);
    else
      return false;
  }

  static String? getString(SharedPrefEnum _key) {
    if (_instance!.containsKey(_key.toString()))
      return _instance!.getString(_key.toString());
    else
      return null;
  }

  static double? getDouble(SharedPrefEnum _key) {
    if (_instance!.containsKey(_key.toString()))
      return _instance!.getDouble(_key.toString());
    else
      return null;
  }

  static int? getInt(SharedPrefEnum _key) {
    if (_instance!.containsKey(_key.toString()))
      return _instance!.getInt(_key.toString());
    else
      return null;
  }

  static bool? getBool(SharedPrefEnum _key) {
    if (_instance!.containsKey(_key.toString()))
      return _instance!.getBool(_key.toString());
    else
      return false;
  }

  static Future<bool> saveForMembership(String _key, dynamic _param) async {
    if (_param is bool)
      return await _instance!.setBool(_key.toString(), _param);
    else
      return false;
  }

  static bool? getBoolForMembership(String _key) {
    if (_instance!.containsKey(_key.toString()))
      return _instance!.getBool(_key.toString());
    else
      return false;
  }

  static Future<bool> clear() async => _instance!.clear();

  static Future<bool> remove(SharedPrefEnum _key) async =>
      _instance!.remove(_key.toString());

  /// Store deferred deep link for post-login navigation
  /// [type] - "event" or "club"
  /// [id] - The event or club ID
  static Future<void> savePendingDeepLink(String id, {String type = 'event'}) async {
    final data = '{"type":"$type","id":"$id","timestamp":${DateTime.now().millisecondsSinceEpoch}}';
    await save(SharedPrefEnum.PENDING_DEEP_LINK, data);
  }

  /// Retrieve and clear pending deep link
  /// Returns map with 'type' ('event' or 'club'), 'id', and 'timestamp'
  static Future<Map<String, dynamic>?> consumePendingDeepLink() async {
    final dataString = getString(SharedPrefEnum.PENDING_DEEP_LINK);
    if (dataString == null || dataString.isEmpty) {
      return null;
    }

    // Clear immediately to avoid duplicate navigation
    await save(SharedPrefEnum.PENDING_DEEP_LINK, '');

    try {
      // Simple JSON parsing without dart:convert
      final typeMatch = RegExp(r'"type":"([^"]+)"').firstMatch(dataString);
      final idMatch = RegExp(r'"id":"([^"]+)"').firstMatch(dataString);
      // Legacy support: check for eventId if id not found
      final eventIdMatch = RegExp(r'"eventId":"([^"]+)"').firstMatch(dataString);
      final timestampMatch = RegExp(r'"timestamp":(\d+)').firstMatch(dataString);

      // Determine type and id
      final type = typeMatch?.group(1) ?? 'event';
      final id = idMatch?.group(1) ?? eventIdMatch?.group(1);

      if (id != null) {
        return {
          'type': type,
          'id': id,
          // Legacy support: also include eventId for backward compatibility
          if (type == 'event') 'eventId': id,
          if (type == 'club') 'clubId': id,
          'timestamp': timestampMatch != null ? int.parse(timestampMatch.group(1)!) : 0,
        };
      }
      return null;
    } catch (e) {
      print('Error parsing pending deep link: $e');
      return null;
    }
  }

  /// Check if there's a pending deep link
  static bool hasPendingDeepLink() {
    final dataString = getString(SharedPrefEnum.PENDING_DEEP_LINK);
    return dataString != null && dataString.isNotEmpty;
  }
}

class SharedPrefUtilGlobal {
  static SharedPreferences? _instance;

  static setInstance(SharedPreferences preferences) => _instance = preferences;

  static Future<bool> saveGlobalSharedPref(String _key, dynamic _param) async {
    if (_param is bool)
      return await _instance!.setBool(_key.toString(), _param);
    else
      return false;
  }

  static bool? getGlobalSharedPref(String _key) {
    if (_instance!.containsKey(_key.toString()))
      return _instance!.getBool(_key.toString());
    else
      return false;
  }

  static Future<bool> clear() async => _instance!.clear();

  static Future<bool> remove(SharedPrefEnum _key) async =>
      _instance!.remove(_key.toString());
}

const String IS_USER_SUBSCRIBE = "IS_USER_SUBSCRIBE";
const String IS_RATE_US = "IS_RATE_US";

enum SharedPrefEnum {
  APP_LANGUAGE,
  IS_LOGGED_IN,
  IS_APP_INTRO_SHOW,
  USER_TOKEN,
  REFRESH_TOKEN,
  TOKEN_EXPIRES,
  PHONE_NUMBER,
  SESSION_ID,
  USER_DATA,
  USER_EMAIL,
  BOX_CODE,
  BOX_ACCESS_TOKEN,
  DROPBOX_ACCESS_TOKEN,
  GOOGLE_DRIVE_TOKEN,
  ONE_DRIVE_ACCESS_TOKEN,
  ONE_DRIVE_USER_ID,
  ONE_DRIVE_CODE,
  PURCHASE_RECEIPT,
  IS_PASTE_TUTORIAL_SHOWN,
  LOGIN_TYPE,
  // IS_PHONE_NUMBER_SAVED,
  FIRST_LOADING,
  NO_OF_CREATE_DOC,
  IS_USER_SUBSCRIBE,
  DONE_FLAG_FOR_PROFILE,
  APP_USES_TYPE,
  VISIBILITY,
  FIRST_TIME_SIGNATURE_MSG,
  FIRST_TIME_INITIAL_MSG,
  NOTIFICATION_FLAG,
  ONBOARDING, INTRO_SHOWN, IS_SUBSCRIBED,
  INTRO_COMPLETED,
  LOCATION_PERMISSION_STATUS,
  COMMUNITY_ORDER,
  PENDING_DEEP_LINK,  // Store pending deep link data for deferred navigation
  IS_SUPER_ADMIN  // Whether the current user is a super admin (role.id == 1)
}
