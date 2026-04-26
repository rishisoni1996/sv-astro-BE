import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/modules/auth/models/token_refresh_response.dart';
import 'package:flutter_app/modules/home/frozen_user/frozen_user_screen.dart';
import 'package:flutter_app/utils/deep_link_handler.dart';
import 'package:flutter_app/utils/api_utils/base_response.dart';
import 'package:flutter_app/utils/shared_preferences_utils/share_preferences_utils.dart';

class ApiConsts {
  ApiConsts._();

  /// PRODUCTION
  static String baseUrl = "https://api.abroadclubs.com/api/v1";

  /// STAGING
  // static String baseUrl = "http://3.230.213.53:3000/api/v1";

  /// LOCAL 01
  // static String baseUrl = "https://5a3d-2409-40c1-6019-202f-7d42-9391-bf88-3f05.ngrok-free.app/api/v1";

  /// LOCAL 02
  // static String baseUrl = "http://localhost:3000/api/v1";
  static const int connectionTimeout = 30;

  // Auth APIs
  static const String guestAuthAPI = "/auth/guest";
  static const String updatePhoneNumber = "/auth/phone";
  static const String registerStep1API = "/auth/register/step1";
  static const String registerVerifyOtpAPI = "/auth/register/verify-otp";
  static const String registerInterestsAPI = "/auth/register/interests";
  static const String registerCompleteAPI = "/auth/register/complete";
  static const String loginSendOtpAPI = "/auth/otp/send-login";
  static const String loginVerifyOtpAPI = "/auth/otp/verify-login";
  static const String refreshTokenAPI = "/auth/refresh";
  static const String getUserProfileAPI = "/auth/me";

  // User APIs
  static const String userInterestsAPI = "/user-interests";
  static const String updateProfileAPI = "/profile/me";
  static const String changePhoneAPI = "/profile/me/phone";
  static const String changePhoneVerifyOtpAPI = "/profile/me/phone/verify-otp";
  static const String profileVerificationAPI = "/profile/verification";
  static const String emailOtpVerificationAPI = "/profile/email-otp-verification";

  /// Get user profile by ID - GET /profile/{id}
  /// Usage: ApiConsts.getUserProfileByIdAPI(userId)
  static String getUserProfileByIdAPI(String userId) => "/profile/$userId";

  /// Get user profile by username - GET /profile/username/{username}
  /// Usage: ApiConsts.getUserProfileByUsernameAPI(username)
  static String getUserProfileByUsernameAPI(String username) =>
      "/profile/username/$username";

  // File APIs
  static const String uploadFileAPI = "/files/upload";

  // Location APIs
  static const String getLocationsAPI = "/locations";

  // Community APIs
  static const String createCommunityAPI = "/communities";
  static const String getCommunitiesAPI = "/communities";
  static const String joinNearbyCommunitiesAPI = "/communities/join-nearby";
  static const String updateCommunityAPI =
      "/communities"; // PATCH /communities/{id}
  static const String getPublicCommunitiesListAPI = "/public-communities";

  /// Get community by ID - GET /communities/{id}
  /// Usage: ApiConsts.getCommunityByIdAPI(communityId)
  static String getCommunityByIdAPI(String communityId) =>
      "/communities/$communityId";
  // Event Invitation APIs
  static const String getPublicCommunitiesAPI =
      "/event-invitations/public-communities";
  // Topic APIs
  static const String createTopicAPI = "/topics";
  static const String getTopicsAPI = "/topics";

  /// Update topic - PATCH /topics/{id}
  /// Usage: ApiConsts.updateTopicAPI(topicId)
  static String updateTopicAPI(String topicId) => "/topics/$topicId";

  /// Delete topic - DELETE /topics/{id}
  /// Usage: ApiConsts.deleteTopicAPI(topicId)
  static String deleteTopicAPI(String topicId) => "/topics/$topicId";

  // Member APIs
  /// Add member to community - POST /communities/{id}/members
  /// Usage: ApiConsts.addMemberToCommunityAPI(communityId)
  static String addMemberToCommunityAPI(String communityId) =>
      "/communities/$communityId/members";

  /// Get community participants - GET /communities/{id}/participants
  /// Usage: ApiConsts.getCommunityParticipantsAPI(communityId)
  static String getCommunityParticipantsAPI(String communityId) =>
      "/communities/$communityId/participants";

  /// Share community - POST /communities/share
  /// Usage: ApiConsts.shareCommunityAPI
  static const String shareCommunityAPI = "/communities/share";

  /// Leave community - DELETE /communities/{id}/leave
  /// Usage: ApiConsts.leaveCommunityAPI(communityId)
  /// Returns: 204 No Content on success
  static String leaveCommunityAPI(String communityId) =>
      "/communities/$communityId/leave";

  /// Update community member role - PATCH /communities/{id}/members/{userId}
  /// Usage: ApiConsts.updateMemberRoleAPI(communityId, userId)
  /// Body: { "role": "MEMBER" | "MODERATOR" | "LEADER" | "OWNER" }
  static String updateMemberRoleAPI(String communityId, String userId) =>
      "/communities/$communityId/members/$userId";

  // Report APIs
  static const String reportCommunityAPI = "/reports/community";
  static const String getReportCategoriesAPI = "/report-categories";
  static const String createReportAPI = "/reports";

  /// Report a community - POST /communities/report
  /// Body: { "communityId": int, "category": string, "description": string }
  static const String reportCommunityAPIV2 = "/communities/report";
  static const String getReportsAPI = "/reports";

  /// Report a user - POST /users/{id}/report
  /// Body: { "category": string, "description": string }
  static String reportUserAPI(String userId) => "/users/$userId/report";

  /// Get reported users - GET /users/reported
  static const String getReportedUsersAPI = "/users/reported";

  /// Bulk action on reported users - PATCH /users/reported/bulk-action
  /// Body: { "reportIds": [1, 2, 3], "action": "IGNORE" | "FREEZE" }
  static const String reportedUsersBulkActionAPI =
      "/users/reported/bulk-action";

  // Post APIs
  static const String createPostAPI = "/posts";
  static const String getPostsAPI = "/posts";

  /// Update post - PATCH /posts/{id}
  /// Usage: ApiConsts.updatePostAPI(postId)
  static String updatePostAPI(String postId) => "/posts/$postId";

  /// Post reaction (like/dislike) - POST /posts/{id}/reaction
  /// Usage: ApiConsts.postReactionAPI(postId)
  /// Body: {"type": "like" or "dislike"}
  static String postReactionAPI(String postId) => "/posts/$postId/reaction";

  /// Remove reaction (like/dislike) - DELETE /posts/{id}/reaction
  /// Usage: ApiConsts.removeReactionAPI(postId)
  /// Body: {"type": "like" or "dislike"}
  static String removeReactionAPI(String postId) => "/posts/$postId/reaction";

  /// Create comment - POST /posts/{id}/comments
  /// Usage: ApiConsts.createCommentAPI(postId)
  static String createCommentAPI(String postId) => "/posts/$postId/comments";

  /// Get comments - GET /posts/{id}/comments
  /// Usage: ApiConsts.getCommentsAPI(postId)
  static String getCommentsAPI(String postId) => "/posts/$postId/comments";

  /// Comment reaction (like) - POST /posts/comments/{id}/reactions
  /// Usage: ApiConsts.commentReactionAPI(commentId)
  /// Body: {"emoji": "👍"}
  static String commentReactionAPI(String commentId) =>
      "/posts/comments/$commentId/reactions";

  /// Switch post topic - PATCH /posts/{id}/topic
  /// Usage: ApiConsts.switchPostTopicAPI(postId)
  /// Body: {"topicId": 0}
  static String switchPostTopicAPI(String postId) => "/posts/$postId/topic";

  /// Delete post - DELETE /posts/{id}
  /// Usage: ApiConsts.deletePostAPI(postId)
  static String deletePostAPI(String postId) => "/posts/$postId";

  /// Vote on poll - POST /posts/{id}/vote (first time)
  /// Usage: ApiConsts.voteOnPollAPI(postId)
  /// Body: {"optionIds": [1, 2, 3]}
  static String voteOnPollAPI(String postId) => "/posts/$postId/vote";

  /// Update poll vote - PATCH /posts/{id}/vote (update existing vote)
  /// Usage: ApiConsts.updatePollVoteAPI(postId)
  /// Body: {"optionIds": [1, 2, 3]}
  static String updatePollVoteAPI(String postId) => "/posts/$postId/vote";

  // Event APIs
  /// Get events list - GET /events
  /// Query params: page, limit, startDateFrom, startDateTo, location, timezone, sortBy, sortOrder
  static const String getEventsAPI = "/events";
  static const String getFavoriteEventsAPI = "/events/favorites";

  /// Create event - POST /events
  static const String createEventAPI = "/events";

  /// Update event - PATCH /events/{id}
  static String updateEventAPI(int eventId) => "/events/$eventId";

  /// Delete event - DELETE /events/{id}
  /// Usage: ApiConsts.deleteEventAPI(eventId)
  static String deleteEventAPI(int eventId) => "/events/$eventId";

  /// Get event by ID - GET /events/{id}
  /// Usage: ApiConsts.getEventByIdAPI(eventId)
  static String getEventByIdAPI(int eventId) => "/events/$eventId";

  /// Add event to favorites - POST /events/{id}/favorite
  /// Remove event from favorites - DELETE /events/{id}/favorite
  /// Usage: ApiConsts.eventFavoriteAPI(eventId)
  static String eventFavoriteAPI(int eventId) => "/events/$eventId/favorite";

  /// Share event - POST /events/{id}/share
  /// Usage: ApiConsts.shareEventAPI(eventId)
  static String shareEventAPI(int eventId) => "/events/$eventId/share";

  /// Invite communities to event - POST /event-invitations/events/{eventId}/invitations
  /// Body: { "communityIds": [1, 2, 3] }
  static String inviteCommunitiesToEventAPI(int eventId) =>
      "/event-invitations/events/$eventId/invitations";

  /// Get event invitations - GET /event-invitations/events/{eventId}/invitations
  /// Returns list of communities invited to the event with their invitation status
  static String getEventInvitationsAPI(int eventId) =>
      "/event-invitations/events/$eventId/invitations";

  // Event Comment APIs
  /// Create event comment - POST /events/{id}/comments
  /// Usage: ApiConsts.createEventCommentAPI(eventId)
  /// Body: { "content": "comment text", "parentId": optionalParentId }
  static String createEventCommentAPI(int eventId) =>
      "/events/$eventId/comments";

  /// Get event comments - GET /events/{id}/comments
  /// Usage: ApiConsts.getEventCommentsAPI(eventId)
  static String getEventCommentsAPI(int eventId) => "/events/$eventId/comments";

  /// Delete event comment - DELETE /events/{eventId}/comments/{commentId}
  /// Usage: ApiConsts.deleteEventCommentAPI(eventId, commentId)
  static String deleteEventCommentAPI(int eventId, int commentId) =>
      "/events/$eventId/comments/$commentId";

  /// Event comment reaction - POST /events/comments/{id}/reactions
  /// Usage: ApiConsts.eventCommentReactionAPI(commentId)
  /// Body: {"emoji": "👍"}
  static String eventCommentReactionAPI(String commentId) =>
      "/events/comments/$commentId/reactions";

  /// Get event comment reactions - GET /events/comments/{id}/reactions
  /// Usage: ApiConsts.getEventCommentReactionsAPI(commentId)
  static String getEventCommentReactionsAPI(String commentId) =>
      "/events/comments/$commentId/reactions";

  // Friend APIs
  /// Get friends list - GET /friends
  /// Query params: page, limit
  static const String getFriendsAPI = "/friends";

  /// Send friend request - POST /friends/request
  /// Body: { "receiverId": userId }
  static const String friendRequestAPI = "/friends/request";

  /// Respond to friend request - POST /friends/respond/{id}
  /// Usage: ApiConsts.friendRespondAPI(friendRequestId)
  /// Body: { "accept": true } for accept, { "accept": false } for reject
  static String friendRespondAPI(int friendRequestId) =>
      "/friends/respond/$friendRequestId";

  /// Remove friend - DELETE /friends/{friendshipId}
  /// Usage: ApiConsts.removeFriendAPI(friendshipId)
  static String removeFriendAPI(int friendshipId) => "/friends/$friendshipId";

  /// Freeze user (admin) - POST /admin/freezeUser
  /// Body: { "userId": int }
  static const String freezeUserAPI = "/admin/freezeUser";

  /// Block user - POST /friends/blockUser
  /// Body: { "userId": int }
  static const String blockUserAPI = "/friends/blockUser";

  /// Unblock user - POST /friends/unblockUser
  /// Body: { "userId": int }
  static const String unblockUserAPI = "/friends/unblockUser";

  /// Get blocked users - GET /friends/blockedUsers
  /// Query params: page, limit
  static const String blockedUsersAPI = "/friends/blockedUsers";

  /// Get all block relationship IDs - GET /friends/blockByIds
  /// Returns list of user IDs involved in blocking with current user (both directions)
  static const String blockByIdsAPI = "/friends/blockByIds";

  // Device Token APIs
  /// Register device token for push notifications - POST /device-tokens
  static const String registerDeviceTokenAPI = "/device-tokens";

  // Notification APIs
  /// Get notifications list - GET /notifications
  /// Query params: page, limit
  static const String notificationsAPI = "/notifications";

  /// Mark notification as read - POST /notifications/{id}/read
  /// Usage: ApiConsts.markNotificationReadAPI(notificationId)
  static String markNotificationReadAPI(int notificationId) =>
      "/notifications/$notificationId/read";

  // Community Reorder API
  /// Reorder community - POST /communities/reorder
  /// Body: { "communityId": 1, "newIndex": 0 }
  static const String reorderCommunityAPI = "/communities/reorder";

  // Saved Posts APIs
  /// Get saved posts list - GET /posts/saved/list
  /// Query params: page, limit, topicId, sortBy, includeDeleted
  static const String getSavedPostsAPI = "/posts/saved/list";

  /// Save post - POST /posts/{id}/save
  /// Usage: ApiConsts.savePostAPI(postId)
  static String savePostAPI(String postId) => "/posts/$postId/save";

  /// Share post - POST /posts/{id}/share
  /// Usage: ApiConsts.sharePostAPI(postId)
  static String sharePostAPI(String postId) => "/posts/$postId/share";

  /// Report post - POST /posts/{id}/report
  /// Usage: ApiConsts.reportPostAPI(postId)
  /// Body: { "category": "Spam", "description": "optional description" }
  static String reportPostAPI(String postId) => "/posts/$postId/report";

  // Admin Panel APIs

  /// Post approval - POST /posts/approval
  /// Body: { "postIds": [1, 2, 3], "action": "ACCEPTED" | "DECLINED" | "FROZEN" }
  static const String postApprovalAPI = "/posts/approval";

  /// Get pending community invites - GET /community-invites/community/{id}/pending
  /// Query params: page, limit
  /// Usage: ApiConsts.getPendingInvitesAPI(communityId)
  static String getPendingInvitesAPI(int communityId) =>
      "/community-invites/community/$communityId/pending";

  /// Accept/Reject community invite - POST /community-invites/{id}/respond
  /// Body: { "accept": true | false }
  /// Usage: ApiConsts.respondToInviteAPI(inviteId)
  static String respondToInviteAPI(int inviteId) =>
      "/community-invites/$inviteId/respond";

  /// Get reported posts for community - GET /posts/community/{id}/reports
  /// Query params: page, limit
  /// Usage: ApiConsts.getReportedPostsAPI(communityId)
  static String getReportedPostsAPI(int communityId) =>
      "/posts/community/$communityId/reports";

  /// Bulk action on reported posts - POST /posts/reports/bulk-action
  /// Body: { "reportIds": [1, 2, 3], "action": "BLOCK_POST" | "IGNORE" }
  static const String reportedPostsBulkActionAPI = "/posts/reports/bulk-action";

  /// Bulk action on reported clubs - POST /communities/reports/bulk-action
  /// Body: { "reportIds": [1, 2, 3], "action": "BAN_COMMUNITY" | "IGNORE_REPORT" }
  static const String reportedClubsBulkActionAPI =
      "/communities/reports/bulk-action";

  /// Update reported club status - PATCH /communities/reported/{id}/status
  /// Body: { "status": "ACCEPTED" | "IGNORED" }
  static String updateReportedClubStatusAPI(String reportId) =>
      "/communities/reported/$reportId/status";

  /// Get reported clubs list - GET /communities/reported/list
  /// Query params: page, limit
  static const String getReportedClubsListAPI = "/communities/reported/list";

  /// Get community event invitations - GET /event-invitations/communities/{communityId}/invitations
  /// Returns list of events that have invited this community
  static String getCommunityEventInvitationsAPI(int communityId) =>
      "/event-invitations/communities/$communityId/events";

  /// Accept event invitation - PATCH /event-invitations/events/{eventId}/{communityId}/accept
  static String acceptEventInvitationAPI(int eventId, int communityId) =>
      "/event-invitations/events/$eventId/$communityId/accept";

  /// Reject event invitation - PATCH /event-invitations/events/{eventId}/{communityId}/reject
  static String rejectEventInvitationAPI(int eventId, int communityId) =>
      "/event-invitations/events/$eventId/$communityId/reject";

  /// Join community - POST /community-invites
  /// Body: { "communityId": int, "invitedUserId": int }
  static const String joinCommunityAPI = "/community-invites";

  /// Get pending approval communities - GET /communities?approvalStatus=submitted_for_approval
  /// Query params: approvalStatus, page, limit
  static const String getPendingApprovalCommunitiesAPI = "/communities";
  static const String getCommunitiesWithDataAPI = "/communities/with-data";

  /// Approve community - PATCH /communities/{id}/approve
  /// Usage: ApiConsts.approveCommunityAPI(communityId)
  static String approveCommunityAPI(int communityId) =>
      "/communities/$communityId/status";

  /// Reject community - PATCH /communities/{id}/reject
  /// Usage: ApiConsts.rejectCommunityAPI(communityId)
  static String rejectCommunityAPI(int communityId) =>
      "/communities/$communityId/status";

  /// Toggle community favourite status - POST /communities/{id}/favourite
  /// Usage: ApiConsts.toggleCommunityFavouriteAPI(communityId)
  static String toggleCommunityFavouriteAPI(int communityId) =>
      "/communities/$communityId/favourite";
}

class ApiClient {
  static ApiClient? _instance;
  static late Dio dio;
  static bool _isRefreshing = false;

  static ApiClient instance() {
    if (_instance == null) {
      _instance = ApiClient();
      dio = Dio(
        BaseOptions(
          baseUrl: ApiConsts.baseUrl,
          connectTimeout: const Duration(seconds: ApiConsts.connectionTimeout),
        ),
      );
      setInterceptor();
    }
    return _instance!;
  }

  static setInterceptor() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _requestInterceptor,
        onResponse: _responseInterceptor,
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          log("------------------------------------------------------------>");
          log(
            error.response?.requestOptions.path.split("v1").last ?? "Unknown",
            name: "Endpoint",
          );
          log(
            error.response?.statusCode.toString() ?? "Unknown",
            name: "Error Code",
          );
          log(
            error.response?.statusMessage.toString() ?? "Unknown",
            name: "Error Message",
          );
          if (error.response?.data != null) {
            try {
              final errorData = jsonEncode(error.response!.data);
              debugPrint("Error Response Data: $errorData");
            } catch (e) {
              debugPrint("Error Response Data: [Error encoding: $e]");
            }
          }
          log("------------------------------------------------------------>");

          if (error.response?.statusCode == 403) {
            _handleUnauthorisedAccess();
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            // Skip refresh for the refresh token API itself to avoid infinite loop
            if (error.requestOptions.path == ApiConsts.refreshTokenAPI) {
              _handleSessionExpired();
              return handler.next(error);
            }

            // Try to refresh the token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request with new token
              try {
                final newToken = SharedPrefUtil.getString(
                  SharedPrefEnum.USER_TOKEN,
                );
                error.requestOptions.headers["Authorization"] =
                    "Bearer $newToken";
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (retryError) {
                _handleSessionExpired();
                return handler.next(error);
              }
            } else {
              _handleSessionExpired();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Attempt to refresh the token
  /// Returns true if successful, false otherwise
  static Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final token = SharedPrefUtil.getString(SharedPrefEnum.USER_TOKEN);
      final refreshToken = SharedPrefUtil.getString(
        SharedPrefEnum.REFRESH_TOKEN,
      );
      final tokenExpiresStr = SharedPrefUtil.getString(
        SharedPrefEnum.TOKEN_EXPIRES,
      );

      if (token == null || refreshToken == null) {
        _isRefreshing = false;
        return false;
      }

      final tokenExpires = int.tryParse(tokenExpiresStr ?? "0") ?? 0;

      // Create a separate Dio instance for refresh to avoid interceptor loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConsts.baseUrl,
          connectTimeout: const Duration(seconds: ApiConsts.connectionTimeout),
        ),
      );

      final requestBody = {
        'token': token,
        'refreshToken': refreshToken,
        'tokenExpires': tokenExpires,
      };

      log("------------------------------------------------------------>");
      log("Attempting token refresh", name: "TOKEN_REFRESH");
      log(jsonEncode(requestBody), name: "Refresh Request Body");
      log("------------------------------------------------------------>");

      final response = await refreshDio.post(
        ApiConsts.refreshTokenAPI,
        data: requestBody,
        options: Options(headers: {"Authorization": "Bearer $refreshToken"}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final refreshResponse = TokenRefreshResponse.fromJson(response.data);

        // Update stored tokens
        await SharedPrefUtil.save(
          SharedPrefEnum.USER_TOKEN,
          refreshResponse.token,
        );
        await SharedPrefUtil.save(
          SharedPrefEnum.REFRESH_TOKEN,
          refreshResponse.refreshToken,
        );
        await SharedPrefUtil.save(
          SharedPrefEnum.TOKEN_EXPIRES,
          refreshResponse.tokenExpires.toString(),
        );

        log("------------------------------------------------------------>");
        log("Token refresh successful", name: "TOKEN_REFRESH");
        log("------------------------------------------------------------>");

        _isRefreshing = false;
        return true;
      }

      _isRefreshing = false;
      return false;
    } catch (e) {
      log("------------------------------------------------------------>");
      log("Token refresh failed: $e", name: "TOKEN_REFRESH");
      log("------------------------------------------------------------>");
      _isRefreshing = false;
      return false;
    }
  }

  static _responseInterceptor(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    log("------------------------------------------------------------>");
    log(response.requestOptions.path.split("v1").last, name: "Endpoint");
    log(response.statusCode.toString(), name: "Response Code");
    log(response.statusMessage.toString(), name: "Response Message");

    // Use debugPrint for response data to handle large responses
    try {
      final responseData = jsonEncode(response.data);
      debugPrint("Response Data: $responseData");
    } catch (e) {
      debugPrint("Response Data: [Error encoding: $e]");
    }

    log("------------------------------------------------------------>");
    return handler.next(response);
  }

  static _requestInterceptor(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    String? authToken = SharedPrefUtil.getString(SharedPrefEnum.USER_TOKEN);
    if (authToken != null && authToken.isNotEmpty) {
      options.headers = {"Authorization": "Bearer ${authToken ?? ""}"};
    }

    log("|___________________________________________________________|");
    log("|___________________________________________________________|");
    log(options.path, name: options.method);
    log(jsonEncode(options.headers), name: "HEADER");
    if (options.data != null) {
      log(jsonEncode(options.data), name: "DATA");
    }
    if (options.queryParameters.isNotEmpty) {
      log(jsonEncode(options.queryParameters), name: "PARAMS");
    }
    log("------------------------------------------------------------>");
    return handler.next(options);
  }

  Future<BaseResponse<T>?> get<T>(
    String api, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? mapper,
    T Function(List<dynamic>)? listMapper,
  }) async {
    try {
      Response response = await dio.get(
        api,
        queryParameters: queryParams,
        data: data,
      );
      if (mapper == null && listMapper == null) return null;
      return BaseResponse.fromDioResponse(
        response,
        mapper: mapper,
        listMapper: listMapper,
      );
    } on DioException catch (error) {
      // Always extract error message directly without attempting to map error responses
      final errorData = error.response?.data;
      return BaseResponse(
        statusCode: error.response?.statusCode ?? 500,
        message: (errorData is Map<String, dynamic>)
            ? errorData["message"] ?? "Request failed"
            : "Request failed",
        errors: (errorData is Map<String, dynamic>)
            ? (errorData["errors"] as Map<String, dynamic>?)
            : null,
      );
    }
  }

  Future<BaseResponse<T>?> post<T>(
    String api,
    Map<String, dynamic> body, {
    T Function(Map<String, dynamic>)? mapper,
    T Function(List<dynamic>)? listMapper,
  }) async {
    try {
      Response response = await dio.post(api, data: body);
      if (mapper == null && listMapper == null) {
        return BaseResponse(
          statusCode: response.statusCode ?? 500,
          message: (response.data is Map<String, dynamic>)
              ? response.data["message"] ?? "Success"
              : "Success",
          data: response.data,
        );
      }
      return BaseResponse.fromDioResponse(
        response,
        mapper: mapper,
        listMapper: listMapper,
      );
    } on DioException catch (error) {
      // Always extract error message directly without attempting to map error responses
      final errorData = error.response?.data;
      return BaseResponse(
        statusCode: error.response?.statusCode ?? 500,
        message: (errorData is Map<String, dynamic>)
            ? errorData["message"] ?? "Request failed"
            : "Request failed",
        errors: (errorData is Map<String, dynamic>)
            ? (errorData["errors"] as Map<String, dynamic>?)
            : null,
      );
    }
  }

  Future<BaseResponse<T>?> put<T>(
    String api,
    Map<String, dynamic> body, {
    T Function(Map<String, dynamic>)? mapper,
    T Function(List<dynamic>)? listMapper,
  }) async {
    try {
      Response response = await dio.put(api, data: body);
      if (mapper == null && listMapper == null) {
        return BaseResponse(
          statusCode: response.statusCode ?? 500,
          message: (response.data is Map<String, dynamic>)
              ? response.data["message"] ?? "Success"
              : "Success",
          data: response.data,
        );
      }
      return BaseResponse.fromDioResponse(
        response,
        mapper: mapper,
        listMapper: listMapper,
      );
    } on DioException catch (error) {
      final errorData = error.response?.data;
      return BaseResponse(
        statusCode: error.response?.statusCode ?? 500,
        message: (errorData is Map<String, dynamic>)
            ? errorData["message"] ?? "Request failed"
            : "Request failed",
        errors: (errorData is Map<String, dynamic>)
            ? (errorData["errors"] as Map<String, dynamic>?)
            : null,
      );
    }
  }

  Future<BaseResponse<T>?> patch<T>(
    String api,
    Map<String, dynamic> body, {
    T Function(Map<String, dynamic>)? mapper,
    T Function(List<dynamic>)? listMapper,
  }) async {
    try {
      Response response = await dio.patch(api, data: body);
      if (mapper == null && listMapper == null) {
        return BaseResponse(
          statusCode: response.statusCode ?? 500,
          message: (response.data is Map<String, dynamic>)
              ? response.data["message"] ?? "Success"
              : "Success",
          data: response.data,
        );
      }
      return BaseResponse.fromDioResponse(
        response,
        mapper: mapper,
        listMapper: listMapper,
      );
    } on DioException catch (error) {
      final errorData = error.response?.data;
      return BaseResponse(
        statusCode: error.response?.statusCode ?? 500,
        message: (errorData is Map<String, dynamic>)
            ? errorData["message"] ?? "Request failed"
            : "Request failed",
        errors: (errorData is Map<String, dynamic>)
            ? (errorData["errors"] as Map<String, dynamic>?)
            : null,
      );
    }
  }

  Future<BaseResponse<T>?> delete<T>(
    String api, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? mapper,
    T Function(List<dynamic>)? listMapper,
  }) async {
    try {
      Response response = await dio.delete(api, data: body);
      if (mapper == null && listMapper == null) {
        return BaseResponse(
          statusCode: response.statusCode ?? 500,
          message: (response.data is Map<String, dynamic>)
              ? response.data["message"] ?? "Success"
              : "Success",
          data: response.data,
        );
      }
      return BaseResponse.fromDioResponse(
        response,
        mapper: mapper,
        listMapper: listMapper,
      );
    } on DioException catch (error) {
      final errorData = error.response?.data;
      return BaseResponse(
        statusCode: error.response?.statusCode ?? 500,
        message: (errorData is Map<String, dynamic>)
            ? errorData["message"] ?? "Request failed"
            : "Request failed",
        errors: (errorData is Map<String, dynamic>)
            ? (errorData["errors"] as Map<String, dynamic>?)
            : null,
      );
    }
  }

  /// Handle frozen account (403 with accountFrozen error)
  /// Clears session and navigates to FrozenUserScreen
  static void _handleAccountFrozen() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Clear user session data
    await SharedPrefUtil.save(SharedPrefEnum.IS_LOGGED_IN, false);
    await SharedPrefUtil.remove(SharedPrefEnum.USER_TOKEN);
    await SharedPrefUtil.remove(SharedPrefEnum.REFRESH_TOKEN);
    await SharedPrefUtil.remove(SharedPrefEnum.USER_DATA);

    if (!context.mounted) return;

    FrozenUserScreen.show(context);
  }

  /// Handle unauthorised access (403 Forbidden)
  /// Clears session and navigates to welcome screen
  static void _handleUnauthorisedAccess() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Clear user session data
    await SharedPrefUtil.save(SharedPrefEnum.IS_LOGGED_IN, false);
    await SharedPrefUtil.remove(SharedPrefEnum.USER_TOKEN);
    await SharedPrefUtil.remove(SharedPrefEnum.REFRESH_TOKEN);
    await SharedPrefUtil.remove(SharedPrefEnum.USER_DATA);

    // Show unauthorised access dialog
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Unauthorised Access'),
          content: const Text(
            'You are not authorised to access this resource. You will be logged out for security purposes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Navigate to welcome screen and clear navigation stack
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/welcome',
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Handle session expired (401 Unauthorized)
  /// Called only when token refresh fails
  /// Shows dialog and navigates to welcome screen on confirmation
  static void _handleSessionExpired() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Clear user session data
    await SharedPrefUtil.save(SharedPrefEnum.IS_LOGGED_IN, false);
    await SharedPrefUtil.remove(SharedPrefEnum.USER_TOKEN);
    await SharedPrefUtil.remove(SharedPrefEnum.REFRESH_TOKEN);
    await SharedPrefUtil.remove(SharedPrefEnum.USER_DATA);

    // Show session expired dialog
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Your session has ended. Please login again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Navigate to welcome screen and clear navigation stack
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/welcome',
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /*
  /// Fire-and-forget API call to save subscription receipt
  /// Does not wait for response or handle errors to avoid disrupting user flow
  static void saveSubscriptionReceipt(String receipt) async {
    try {
      await dio.post(ApiConsts.saveSubscriptionAPI, data: {
        'receipt': receipt,
      });
    } catch (error) {
      // Silent failure - log for debugging but don't disrupt user experience
      print('Failed to save subscription receipt: $error');
    }
  }*/
}
