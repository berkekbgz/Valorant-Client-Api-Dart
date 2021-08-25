// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'models/endpoint_model.dart';

class ValorantResources {
  static ValorantResources instance = ValorantResources._init();
  ValorantResources._init();

  _Endpoints get endpoints => _Endpoints();
}

enum ApiRuntimeType { LOCAL, NORMAL, NONE }

enum Region { NA, EU, LATAM, BR, AP, KR, PBE, TUR }

extension RegionsExtension on Region {
  String get name {
    return toString().split('.').last;
  }

  String get codeName {
    switch (this) {
      case Region.LATAM:
        return "na";
      case Region.BR:
        return "na";
      case Region.TUR:
        return "eu";
      default:
        return toString().split('.').last.toLowerCase();
    }
  }

  String get shard {
    switch (this) {
      case Region.PBE:
        return "na";
      case Region.TUR:
        return "eu";
      default:
        return toString().split('.').last.toLowerCase();
    }
  }
}

Region getRegionFromString(String region) {
  return Region.values.firstWhere((element) {
    return element.name.toLowerCase() == region.toLowerCase();
  });
}

enum Queues { competitive, custom, deathmatch, ggteam, snowball, spikerush, unrated, onefa, all }

extension QueuesExtension on Queues {
  String get codeName => toString().split('.').last;

  // Name overrides
  String get name {
    switch (this) {
      case Queues.ggteam:
        return "escalation";
      case Queues.onefa:
        return "replication";
      default:
        return codeName;
    }
  }

  List<String> get names => Queues.values.map((e) => e.name).toList();
}

Queues getQueueFromString(String queue) {
  return Queues.values.firstWhere((element) => element.name == queue || element.codeName == queue);
}

enum CustomGameTeams { TeamTwo, TeamOne, TeamSpectate, TeamOneCoaches, TeamTwoCoaches }

extension CustomGameTeamsExtension on CustomGameTeams {
  String get name => toString().split('.').last;
}

class _Endpoints {
  Endpoint AccountXP_GetPlayer({required String puuid}) => Endpoint(url: "/account-xp/v1/players/$puuid", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint Config_FetchConfig({required String region}) => Endpoint(url: "/v1/config/$region", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint Content_FetchContent() => Endpoint(url: "/content-service/v2/content", baseUrlType: BaseUrlType.shared, methodType: MethodType.GET);

  Endpoint Contracts_Fetch({required String puuid}) => Endpoint(url: "/contracts/v1/contracts/$puuid", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Contracts_Activate({required String puuid, required String contractId}) => Endpoint(url: "/v1/contracts/$puuid/special/$contractId", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Contracts_UnlockItemProgressV2({required String puuid, required String definitionId}) => Endpoint(url: "/v2/item-upgrades/$definitionId/$puuid", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Contracts_UnlockContractProgression({required String puuid, required String contractId}) => Endpoint(url: "/v1/contracts/$puuid/contracts/$contractId/unlock", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Contracts_UnlockItemSidegrade({required String puuid, required String definitionId, required String sidegradeId, required String optionId}) => Endpoint(url: "/v1/item-upgrades/$definitionId/sidegrades/$sidegradeId/options/$optionId/$puuid", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Contracts_UpgradeContract({required String puuid, required String contractId}) => Endpoint(url: "/v1/contracts/$puuid/contracts/$contractId/upgrade", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint ContractDefinitions_FetchActiveStory() => Endpoint(url: "/contract-definitions/v2/definitions/story", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint ContractDefinitions_Fetch() => Endpoint(url: "/contract-definitions/v2/definitions", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint CoreGame_FetchPlayer({required String puuid}) => Endpoint(url: "/core-game/v1/players/$puuid", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint CoreGame_FetchMatch({required String matchId}) => Endpoint(url: "/core-game/v1/matches/$matchId", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint CoreGame_FetchMatchLoadouts({required String matchId}) => Endpoint(url: "/core-game/v1/matches/$matchId/loadouts", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint CoreGame_FixPlayerSession() => Endpoint.empty();
  Endpoint CoreGame_FetchInstallStats() => Endpoint.empty();
  Endpoint CoreGame_DisassociatePlayer({required String puuid, required String matchId}) => Endpoint(url: "/core-game/v1/players/$puuid/disassociate/$matchId", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint CoreGame_FetchAllChatMUCToken({required String matchId}) => Endpoint(url: "/core-game/v1/matches/$matchId/allchatmuctoken", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint CoreGame_FetchTeamChatMUCToken({required String matchId}) => Endpoint(url: "/core-game/v1/matches/$matchId/teamchatmuctoken", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint CoreGame_FetchVoiceToken({required String matchId}) => Endpoint(url: "/core-game/v1/matches/$matchId/teamvoicetoken", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);

  Endpoint DisplayNameService_FetchPlayers_BySubjects() => Endpoint(url: "/name-service/v2/players", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint DisplayNameService_UpdatePlayer() => Endpoint(url: "/name-service/v2/players", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint ItemProgressionDefinitionsV2_Fetch() => Endpoint(url: "/contract-definitions/v3/item-upgrades", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint Latency_Stats() => Endpoint(url: "/latency/v1/ingestMulti", baseUrlType: BaseUrlType.shared, methodType: MethodType.GET);
  Endpoint Latency_Stat() => Endpoint(url: "/latency/v1/ingest", baseUrlType: BaseUrlType.shared, methodType: MethodType.GET);

  Endpoint LoginQueue_FetchToken({required String region}) => Endpoint(url: "/login-queue/v2/login/products/valorant/regions/$region", baseUrlType: BaseUrlType.apse, methodType: MethodType.GET);

  Endpoint MatchDetails_FetchMatchDetails({required String matchId}) => Endpoint(url: "/match-details/v1/matches/$matchId", baseUrlType: BaseUrlType.pd, methodType: MethodType.PUT);

  Endpoint MatchHistory_FetchMatchHistory({required String puuid, int? startIndex, int? endIndex, Queues queue = Queues.all}) => Endpoint(url: "/match-history/v1/history/$puuid?${startIndex != null ? "startIndex=$startIndex" : null}${endIndex != null ? "&endIndex=$endIndex" : null}${queue == Queues.all ? "" : "&queue=" + queue.codeName}", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint MassRewards_ReconcilePlayer({required String puuid}) => Endpoint(url: "/mass-rewards/v1/players/$puuid/reconcile", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint MMR_FetchPlayer({required String puuid}) => Endpoint(url: "/mmr/v1/players/$puuid", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint MMR_AnonymizeLeaderboardPlayer() => Endpoint.empty();
  Endpoint MMR_HideActRankBadge({required String puuid}) => Endpoint(url: "/mmr/v1/players/$puuid/hideactrankbadge", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint MMR_FetchLeaderboard({required String region, required String seasonId, required int startIndex, required int size, String? username}) => Endpoint(url: "/mmr/v1/leaderboards/affinity/$region/queue/competitive/season/$seasonId?startIndex=$startIndex&size=$size&query=$username", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint MMR_FetchCompetitiveUpdates({required String puuid, required int startIndex, required int endIndex}) => Endpoint(url: "/mmr/v1/players/$puuid/competitiveupdates?startIndex=$startIndex&endIndex=$endIndex&queue=competitive", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint playerFetchLoadoutUpdate({required String puuid}) => Endpoint(url: "/personalization/v2/players/$puuid/playerloadout", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint playerSaveLoadoutUpdate({required String puuid}) => Endpoint(url: "/personalization/v2/players/$puuid/playerloadout", baseUrlType: BaseUrlType.pd, methodType: MethodType.PUT);

  Endpoint Matchmaking_FetchQueueData() => Endpoint(url: "/matchmaking/v1/queues/configs", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint Party_FetchPlayer({required String puuid}) => Endpoint(
      url:
          "/parties/v1/players/$puuid?aresriot.aws-rclusterprod-ape1-1.ap-gp-hongkong-1=186&aresriot.aws-rclusterprod-ape1-1.ap-gp-hongkong-awsedge-1=122&aresriot.aws-rclusterprod-apne1-1.ap-gp-tokyo-1=147&aresriot.aws-rclusterprod-apne1-1.ap-gp-tokyo-awsedge-1=151&aresriot.aws-rclusterprod-aps1-1.ap-gp-mumbai-awsedge-1=22&aresriot.aws-rclusterprod-apse1-1.ap-gp-singapore-1=77&aresriot.aws-rclusterprod-apse1-1.ap-gp-singapore-awsedge-1=79&aresriot.aws-rclusterprod-apse2-1.ap-gp-sydney-1=258&aresriot.aws-rclusterprod-apse2-1.ap-gp-sydney-awsedge-1=170&preferredgamepods=aresriot.aws-rclusterprod-aps1-1.ap-gp-mumbai-awsedge-1",
      baseUrlType: BaseUrlType.glz,
      methodType: MethodType.GET);
  Endpoint Party_RemovePlayer({required String puuid}) => Endpoint(url: "/parties/v1/players/$puuid", baseUrlType: BaseUrlType.glz, methodType: MethodType.DELETE);
  Endpoint Party_ReconcilePlayer({required String puuid}) => Endpoint(url: "/parties/v1/players/$puuid/reconcile", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_PlayerJoin({required String puuid, required String partyId}) => Endpoint(url: "/parties/v1/players/$puuid/joinparty/$partyId", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_PlayerLeave({required String puuid, required String partyId}) => Endpoint(url: "/parties/v1/players/$puuid/leaveparty/$partyId", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_SetMemberReady({required String puuid, required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/members/$puuid/setReady", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_RefreshCompetitiveTier({required String puuid, required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/members/$puuid/refreshCompetitiveTier", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_RefreshPlayerIdentity({required String puuid, required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/members/$puuid/refreshPlayerIdentity", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_RefreshPings({required String puuid, required String partyId}) => Endpoint(
      url:
          "/parties/v1/parties/$partyId/members/$puuid/refreshPings?aresriot.aws-rclusterprod-ape1-1.ap-gp-hongkong-1=186&aresriot.aws-rclusterprod-ape1-1.ap-gp-hongkong-awsedge-1=122&aresriot.aws-rclusterprod-apne1-1.ap-gp-tokyo-1=149&aresriot.aws-rclusterprod-apne1-1.ap-gp-tokyo-awsedge-1=151&aresriot.aws-rclusterprod-aps1-1.ap-gp-mumbai-awsedge-1=21&aresriot.aws-rclusterprod-apse1-1.ap-gp-singapore-1=74&aresriot.aws-rclusterprod-apse1-1.ap-gp-singapore-awsedge-1=80&aresriot.aws-rclusterprod-apse2-1.ap-gp-sydney-1=261&aresriot.aws-rclusterprod-apse2-1.ap-gp-sydney-awsedge-1=171",
      baseUrlType: BaseUrlType.glz,
      methodType: MethodType.POST);
  Endpoint Party_FetchParty({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_LeaveFromParty({required String puuid, required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/members/$puuid", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_FetchMUCToken({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/muctoken", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_FetchVoiceToken({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/voicetoken", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_MakePartyIntoCustomGame({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/makecustomgame", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_ChangeQueue({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/queue", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_MakeDefault({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/makedefault?queueID=competitive", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_StartCustomGame({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/startcustomgame", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_StartSoloExperience({required String puuid}) => Endpoint(url: "/parties/v1/players/$puuid/startsoloexperience", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_SetCustomGameSettings({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/customgamesettings", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_Setplayermoderatorstatus({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/setplayermoderatorstatus", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_Setplayerbroadcasthudstatus({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/setplayerbroadcasthudstatus", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_ChangeTeamInCustomGame({required String partyId, required CustomGameTeams team}) => Endpoint(url: "/parties/v1/parties/$partyId/customgamemembership/${team.name}", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_EnterMatchmakingQueue({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/matchmaking/join", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_LeaveMatchmakingQueue({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/matchmaking/leave", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_SetAccessibility({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/accessibility", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_SetLookingForMore() => Endpoint.empty();
  Endpoint Party_SetName() => Endpoint.empty();
  Endpoint Party_SetPreferredGamePods({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/preferredgamepods", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_InviteToParty({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/invites", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_InviteToPartyByDisplayName({required String partyId, required String playerName, required String playerTag}) => Endpoint(url: "/v1/parties/$partyId/invites/name/$playerName/tag/$playerTag", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_DeclineInvite({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/invites/decline", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Party_RequestToJoinParty({required String partyId}) => Endpoint(url: "/parties/v1/parties/$partyId/request", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_DeclineRequest({required String partyId, required String requestId}) => Endpoint(url: "/parties/v1/parties/$partyId/request/$requestId/decline", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Party_Balance() => Endpoint.empty();
  Endpoint Party_SetCheats() => Endpoint.empty();
  Endpoint Party_FetchCustomGameConfigs() => Endpoint(url: "/parties/v1/parties/customgameconfigs", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);

  Endpoint Pregame_GetPlayer({required String puuid}) => Endpoint(url: "/pregame/v1/players/$puuid", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Pregame_FixPlayerSession() => Endpoint.empty();
  Endpoint Pregame_GetMatch({required String matchId}) => Endpoint(url: "/pregame/v1/matches/$matchId", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Pregame_GetMatchLoadouts({required String matchId}) => Endpoint(url: "/pregame/v1/matches/$matchId/loadouts", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Pregame_SelectCharacter({required String matchId, required String characterId}) => Endpoint(url: "/pregame/v1/matches/$matchId/select/$characterId", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Pregame_LockCharacter({required String matchId, required String characterId}) => Endpoint(url: "/pregame/v1/matches/$matchId/lock/$characterId", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);
  Endpoint Pregame_FetchVoiceToken({required String matchId}) => Endpoint(url: "/pregame/v1/matches/$matchId/voicetoken", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Pregame_FetchChatToken({required String matchId}) => Endpoint(url: "/pregame/v1/matches/$matchId/chattoken", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Pregame_QuitMatch({required String matchId}) => Endpoint(url: "/pregame/v1/matches/$matchId/quit", baseUrlType: BaseUrlType.glz, methodType: MethodType.POST);

  Endpoint Restrictions_PlayerReportToken({required String matchId, required String offenderUserId}) => Endpoint(url: "/restrictions/v1/playerReportToken/$matchId/$offenderUserId", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Restrictions_FetchPlayerRestrictionsV2() => Endpoint(url: "/restrictions/v2/penalties", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint Session_Connect({required String puuid}) => Endpoint(url: "/session/v2/sessions/$puuid/connect", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Session_Heartbeat({required String puuid}) => Endpoint(url: "/session/v1/sessions/$puuid/heartbeat", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Session_Disconnect({required String puuid}) => Endpoint(url: "/session/v1/sessions/$puuid/disconnect", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Session_Get({required String puuid}) => Endpoint(url: "/session/v1/sessions/$puuid", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);
  Endpoint Session_ReConnect({required String puuid}) => Endpoint(url: "/session/v1/sessions/$puuid/reconnect", baseUrlType: BaseUrlType.glz, methodType: MethodType.GET);

  Endpoint Store_GetWallet({required String puuid}) => Endpoint(url: "/store/v1/wallet/$puuid", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Store_CreateOrder() => Endpoint(url: "/store/v1/order/", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Store_CreateBundleOrder({required String bundleId}) => Endpoint(url: "/store/v1/bundles/$bundleId/order", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Store_GetOrder({required String orderId}) => Endpoint(url: "/store/v1/order/$orderId", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Store_GetStorefrontV2({required String puuid}) => Endpoint(url: "/store/v2/storefront/$puuid", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Store_GetOffers() => Endpoint(url: "/store/v1/offers/", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Store_GetEntitlements({required String puuid, required String itemTypeId}) => Endpoint(url: "/store/v1/entitlements/$puuid/$itemTypeId", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
  Endpoint Store_RevealNightMarketOffers({required String puuid}) => Endpoint(url: "/store/v2/storefront/$puuid/nightmarket/offers", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);

  Endpoint PlayerPreferences_GetSettings() => Endpoint(url: "/playerPref/v3/getPreference/Ares.PlayerSettings", baseUrlType: BaseUrlType.playerpreferences, methodType: MethodType.GET);
  Endpoint PlayerPreferences_SaveSettings() => Endpoint(url: "/playerPref/v3/savePreference/Ares.PlayerSettings", baseUrlType: BaseUrlType.playerpreferences, methodType: MethodType.PUT);

  Endpoint LocalRiotClient_GetAllPresences() => Endpoint(url: "/chat/v4/presences", baseUrlType: BaseUrlType.local, methodType: MethodType.GET, useLocalHeaders: true);
  Endpoint LocalRiotClient_GetSession() => Endpoint(url: "/product-session/v1/external-sessions", baseUrlType: BaseUrlType.local, methodType: MethodType.GET, useLocalHeaders: true);
  Endpoint LocalRiotClient_GetActiveAlias() => Endpoint(url: "/player-account/aliases/v1/active", baseUrlType: BaseUrlType.local, methodType: MethodType.GET, useLocalHeaders: true);
  Endpoint LocalRiotClient_GetEntitlementsToken() => Endpoint(url: "/player-account/aliases/v1/active", baseUrlType: BaseUrlType.local, methodType: MethodType.GET, useLocalHeaders: true);
  Endpoint LocalRiotClient_GetChatSession() => Endpoint(url: "/chat/v1/session", baseUrlType: BaseUrlType.local, methodType: MethodType.GET, useLocalHeaders: true);
  Endpoint LocalRiotClient_GetAllFriends() => Endpoint(url: "/chat/v4/friends", baseUrlType: BaseUrlType.local, methodType: MethodType.GET, useLocalHeaders: true);
  Endpoint LocalRiotClient_GetSettings() => Endpoint(url: "/player-preferences/v1/data-json/Ares.PlayerSettings", baseUrlType: BaseUrlType.local, methodType: MethodType.GET, useLocalHeaders: true);
  Endpoint LocalRiotClient_GetFriendRequests() => Endpoint(url: "/chat/v4/friendrequests", baseUrlType: BaseUrlType.local, methodType: MethodType.GET, useLocalHeaders: true);
}
