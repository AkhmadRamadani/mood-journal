import 'dart:convert';
import 'dart:developer';

import 'package:moodie/models/badge_model.dart';
import 'package:moodie/models/challenge_model.dart';
import 'package:moodie/models/gamification_profile_model.dart';
import 'package:moodie/models/leaderboard_user_model.dart';
import 'package:moodie/utils/services/api_service.dart';

class GamificationService {
  final ApiService _apiService = ApiService();

  Future<GamificationProfileModel> fetchProfile({
    void Function(GamificationProfileModel fresh)? onRefreshed,
  }) async {
    try {
      final result = await _apiService.getData<GamificationProfileModel>(
        uri: '/gamification/profile',
        dbKey: 'gamification_profile',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final data = jsonDecode(jsonStr);
          final profileData = (data is Map<String, dynamic> &&
                  data.containsKey('data') &&
                  data['data'] != null)
              ? data['data']
              : data;
          return GamificationProfileModel.fromJson(
              Map<String, dynamic>.from(profileData));
        },
      );
      if (result.isSuccess) {
        return result.data;
      }
      throw Exception(result.failure.message);
    } catch (e) {
      log('Error fetching gamification profile: $e');
      rethrow;
    }
  }

  Future<List<BadgeModel>> fetchBadges({
    void Function(List<BadgeModel> fresh)? onRefreshed,
  }) async {
    try {
      final result = await _apiService.getData<List<BadgeModel>>(
        uri: '/gamification/badges',
        dbKey: 'gamification_badges',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final data = jsonDecode(jsonStr);
          List rawList = [];
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            rawList = data['data'] is List ? data['data'] : [];
          } else if (data is List) {
            rawList = data;
          }
          return rawList
              .map((item) =>
                  BadgeModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        },
      );
      if (result.isSuccess) {
        return result.data;
      }
      return [];
    } catch (e) {
      log('Error fetching badges: $e');
      return [];
    }
  }

  Future<List<ChallengeModel>> fetchChallenges({
    void Function(List<ChallengeModel> fresh)? onRefreshed,
  }) async {
    try {
      final result = await _apiService.getData<List<ChallengeModel>>(
        uri: '/gamification/challenges',
        dbKey: 'gamification_challenges',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final data = jsonDecode(jsonStr);
          List rawList = [];
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            rawList = data['data'] is List ? data['data'] : [];
          } else if (data is List) {
            rawList = data;
          }
          return rawList
              .map((item) =>
                  ChallengeModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        },
      );
      if (result.isSuccess) {
        return result.data;
      }
      return [];
    } catch (e) {
      log('Error fetching challenges: $e');
      return [];
    }
  }

  Future<List<LeaderboardUserModel>> fetchLeaderboard({
    void Function(List<LeaderboardUserModel> fresh)? onRefreshed,
  }) async {
    try {
      final result = await _apiService.getData<List<LeaderboardUserModel>>(
        uri: '/gamification/leaderboard',
        dbKey: 'gamification_leaderboard',
        dataSource: DataSource.staleWhileRevalidate,
        onRefreshed: onRefreshed,
        fromJson: (jsonStr) {
          final data = jsonDecode(jsonStr);
          List rawList = [];
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            rawList = data['data'] is List ? data['data'] : [];
          } else if (data is List) {
            rawList = data;
          }
          return rawList
              .map((item) => LeaderboardUserModel.fromJson(
                  Map<String, dynamic>.from(item)))
              .toList();
        },
      );
      if (result.isSuccess) {
        return result.data;
      }
      return [];
    } catch (e) {
      log('Error fetching leaderboard: $e');
      return [];
    }
  }
}
