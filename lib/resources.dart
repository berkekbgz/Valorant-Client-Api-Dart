// ignore_for_file: non_constant_identifier_names, constant_identifier_names

class ValorantResources {
  static ValorantResources instance = ValorantResources._init();
  ValorantResources._init();

  _Endpoints get endpoints => _Endpoints();

  ///Add shard parameter for pd
  ///
  ///Add port parameter for local
  ///
  ///Add region parameter and shard for glz
  ///
  ///Add region parameter for shared
  String getbaseUrlbyType(String endpointType, {String? shard, String? region, String? port}) {
    final String _baseEndpoint = "https://pd.$shard.a.pvp.net";
    final String _baseEndpointLocal = "https://127.0.0.1:$port";
    final String _baseEndpointGlz = "https://glz-$region-1.$shard.a.pvp.net";
    final String _baseEndpointShared = "https://shared.$region.a.pvp.net";
    const String _baseEndpointApse = "https://apse.pp.riotgames.com/";

    switch (endpointType) {
      case "pd":
        return _baseEndpoint;
      case "glz":
        return _baseEndpointGlz;
      case "shared":
        return _baseEndpointShared;
      case "local":
        return _baseEndpointLocal;
      case "apse":
        return _baseEndpointApse;
      default:
        throw Exception("Unknown endpoint type");
    }
  }

  bool queueIsValid(Queues queue) {
    return Queues.values.contains(queue);
  }

  final List<String> regions = ["na", "eu", "latam", "br", "ap", "kr", "pbe", "tr"];
  final Map<String, String> regionShardOverrides = {"latam": "na", "br": "na", "tr": "eu"};
  final Map<String, String> shardRegionOverrides = {"pbe": "na"};

  //final List<String> queues = ["competitive", "custom", "deathmatch", "ggteam", "snowball", "spikerush", "unrated", "onefa", ""];
}

enum Queues { competitive, custom, deathmatch, ggteam, snowball, spikerush, unrated, onefa, empty }

extension QueuesExtension on Queues {
  String get name => toString().split('.').last;
}

enum CustomGameTeams { TeamTwo, TeamOne, TeamSpectate, TeamOneCoaches, TeamTwoCoaches }

class _Endpoints {
  String AccountXP_GetPlayer({required String puuid}) => "/account-xp/v1/players/$puuid";
  String AccountXp_BaseUrlType() => "pd";

  String Config_FetchConfig({required String region}) => "/v1/config/$region";
  String Config_BaseUrlType() => "pd";

  String Content_FetchContent() => "/content-service/v2/content";
  String Content_BaseUrlType() => "pd";

  String Contracts_Fetch({required String puuid}) => "/contracts/v1/contracts/$puuid";
  String Contracts_Activate({required String puuid, required String contractId}) => "/v1/contracts/$puuid/special/$contractId";
  String Contracts_UnlockItemProgressV2({required String puuid, required String definitionId}) => "/v2/item-upgrades/$definitionId/$puuid";
  String Contracts_UnlockContractProgression({required String puuid, required String contractId}) => "/v1/contracts/$puuid/contracts/$contractId/unlock";
  String Contracts_UnlockItemSidegrade({required String puuid, required String definitionId, required String sidegradeId, required String optionId}) => "/v1/item-upgrades/$definitionId/sidegrades/$sidegradeId/options/$optionId/$puuid";
  String Contracts_UpgradeContract({required String puuid, required String contractId}) => "/v1/contracts/$puuid/contracts/$contractId/upgrade";
  String Contracts_BaseUrlType() => "pd";

  String ContractDefinitions_FetchActiveStory() => "/contract-definitions/v2/definitions/story";
  String ContractDefinitions_Fetch() => "/contract-definitions/v2/definitions";
  String ConrtactDefinitions_BaseUrlType() => "pd";

  String CoreGame_FetchPlayer({required String puuid}) => "/core-game/v1/players/$puuid";
  String CoreGame_FetchMatch({required String matchId}) => "/core-game/v1/matches/$matchId";
  String CoreGame_FetchMatchLoadouts({required String matchId}) => "/core-game/v1/matches/$matchId/loadouts";
  String CoreGame_FixPlayerSession() => "";
  String CoreGame_FetchInstallStats() => "";
  String CoreGame_DisassociatePlayer({required String puuid, required String matchId}) => "/core-game/v1/players/$puuid/disassociate/$matchId";
  String CoreGame_FetchAllChatMUCToken({required String matchId}) => "/core-game/v1/matches/$matchId/allchatmuctoken";
  String CoreGame_FetchTeamChatMUCToken({required String matchId}) => "/core-game/v1/matches/$matchId/teamchatmuctoken";
  String CoreGame_FetchVoiceToken({required String matchId}) => "/core-game/v1/matches/$matchId/teamvoicetoken";
  String CoreGame_BaseUrlType() => "glz";

  String DisplayNameService_FetchPlayers_BySubjects() => "/name-service/v2/players";
  String DisplayNameService_UpdatePlayer() => "/name-service/v2/players";
  String DisplayNameService_BaseUrlType() => "pd";

  String ItemProgressionDefinitionsV2_Fetch() => "/contract-definitions/v3/item-upgrades";
  String ItemProgressionDefinitionsV2_BaseUrlType() => "pd";

  String Latency_Stats() => "/latency/v1/ingestMulti";
  String Latency_Stat() => "/latency/v1/ingest";
  String Latency_BaseUrlType() => "shared";

  String LoginQueue_FetchToken({required String region}) => "/login-queue/v2/login/products/valorant/regions/$region";
  String LoginQueue_BaseUrlType() => "apse";

  String MatchDetails_FetchMatchDetails({required String matchId}) => "/match-details/v1/matches/$matchId";
  String MatchDetails_BaseUrlType() => "pd";

  String MatchHistory_FetchMatchHistory({required String puuid, required int startIndex, required int endIndex, required Queues queue}) => "/match-history/v1/history/$puuid??startIndex=$startIndex&endIndex=$endIndex${queue == Queues.empty ? "" : "&queue=" + queue.name}";
  String MatchHistory_BaseUrlType() => "pd";

  String MassRewards_ReconcilePlayer({required String puuid}) => "/mass-rewards/v1/players/$puuid/reconcile";
  String MassRewards_BaseUrlType() => "pd";

  String MMR_FetchPlayer({required String puuid}) => "/mmr/v1/players/$puuid";
  String MMR_AnonymizeLeaderboardPlayer() => "";
  String MMR_HideActRankBadge({required String puuid}) => "/mmr/v1/players/$puuid/hideactrankbadge";
  String MMR_FetchLeaderboard({required String region, required String seasonId, required int startIndex, required int size, String? username}) => "/mmr/v1/leaderboards/affinity/$region/queue/competitive/season/$seasonId?startIndex=$startIndex&size=$size&query=$username";
  String MMR_FetchCompetitiveUpdates({required String puuid, required int startIndex, required int endIndex}) => "/mmr/v1/players/$puuid/competitiveupdates?startIndex=$startIndex&endIndex=$endIndex&queue=competitive";
  String MMR_BaseUrlType() => "pd";

  String playerLoadoutUpdate({required String puuid}) => "/personalization/v2/players/$puuid/playerloadout";
  String playerLoadoutUpdate_BaseUrlType() => "pd";

  String Matchmaking_FetchQueueData() => "/matchmaking/v1/queues/configs";
  String Matchmaking_BaseUrlType() => "glz";

  String Party_FetchPlayer({required String puuid}) =>
      "/parties/v1/players/$puuid?aresriot.aws-rclusterprod-ape1-1.ap-gp-hongkong-1=186&aresriot.aws-rclusterprod-ape1-1.ap-gp-hongkong-awsedge-1=122&aresriot.aws-rclusterprod-apne1-1.ap-gp-tokyo-1=147&aresriot.aws-rclusterprod-apne1-1.ap-gp-tokyo-awsedge-1=151&aresriot.aws-rclusterprod-aps1-1.ap-gp-mumbai-awsedge-1=22&aresriot.aws-rclusterprod-apse1-1.ap-gp-singapore-1=77&aresriot.aws-rclusterprod-apse1-1.ap-gp-singapore-awsedge-1=79&aresriot.aws-rclusterprod-apse2-1.ap-gp-sydney-1=258&aresriot.aws-rclusterprod-apse2-1.ap-gp-sydney-awsedge-1=170&preferredgamepods=aresriot.aws-rclusterprod-aps1-1.ap-gp-mumbai-awsedge-1";
  String Party_RemovePlayer({required String puuid}) => "/parties/v1/players/$puuid";
  String Party_ReconcilePlayer({required String puuid}) => "/parties/v1/players/$puuid/reconcile";
  String Party_PlayerJoin({required String puuid, required String partyId}) => "/parties/v1/players/$puuid/joinparty/$partyId";
  String Party_PlayerLeave({required String puuid, required String partyId}) => "/parties/v1/players/$puuid/leaveparty/$partyId";
  String Party_SetMemberReady({required String puuid, required String partyId}) => "/parties/v1/parties/$partyId/members/$puuid/setReady";
  String Party_RefreshCompetitiveTier({required String puuid, required String partyId}) => "/parties/v1/parties/$partyId/members/$puuid/refreshCompetitiveTier";
  String Party_RefreshPlayerIdentity({required String puuid, required String partyId}) => "/parties/v1/parties/$partyId/members/$puuid/refreshPlayerIdentity";
  String Party_RefreshPings({required String puuid, required String partyId}) =>
      "/parties/v1/parties/$partyId/members/$puuid/refreshPings?aresriot.aws-rclusterprod-ape1-1.ap-gp-hongkong-1=186&aresriot.aws-rclusterprod-ape1-1.ap-gp-hongkong-awsedge-1=122&aresriot.aws-rclusterprod-apne1-1.ap-gp-tokyo-1=149&aresriot.aws-rclusterprod-apne1-1.ap-gp-tokyo-awsedge-1=151&aresriot.aws-rclusterprod-aps1-1.ap-gp-mumbai-awsedge-1=21&aresriot.aws-rclusterprod-apse1-1.ap-gp-singapore-1=74&aresriot.aws-rclusterprod-apse1-1.ap-gp-singapore-awsedge-1=80&aresriot.aws-rclusterprod-apse2-1.ap-gp-sydney-1=261&aresriot.aws-rclusterprod-apse2-1.ap-gp-sydney-awsedge-1=171";
  String Party_FetchParty({required String partyId}) => "/parties/v1/parties/$partyId";
  String Party_LeaveFromParty({required String puuid, required String partyId}) => "/parties/v1/parties/$partyId/members/$puuid";
  String Party_FetchMUCToken({required String partyId}) => "/parties/v1/parties/$partyId/muctoken";
  String Party_FetchVoiceToken({required String partyId}) => "/parties/v1/parties/$partyId/voicetoken";
  String Party_MakePartyIntoCustomGame({required String partyId}) => "/parties/v1/parties/$partyId/makecustomgame";
  String Party_ChangeQueue({required String partyId}) => "/parties/v1/parties/$partyId/queue";
  String Party_MakeDefault({required String partyId}) => "/parties/v1/parties/$partyId/makedefault?queueID=competitive";
  String Party_StartCustomGame({required String partyId}) => "/parties/v1/parties/$partyId/startcustomgame";
  String Party_StartSoloExperience({required String puuid}) => "/parties/v1/players/$puuid/startsoloexperience";
  String Party_SetCustomGameSettings({required String partyId}) => "/parties/v1/parties/$partyId/customgamesettings";
  String Party_Setplayermoderatorstatus({required String partyId}) => "/parties/v1/parties/$partyId/setplayermoderatorstatus";
  String Party_Setplayerbroadcasthudstatus({required String partyId}) => "/parties/v1/parties/$partyId/setplayerbroadcasthudstatus";
  String Party_ChangeTeamInCustomGame({required String partyId, required CustomGameTeams team}) => "/parties/v1/parties/$partyId/customgamemembership/$team";
  String Party_EnterMatchmakingQueue({required String partyId}) => "/parties/v1/parties/$partyId/matchmaking/join";
  String Party_LeaveMatchmakingQueue({required String partyId}) => "/parties/v1/parties/$partyId/matchmaking/leave";
  String Party_SetAccessibility({required String partyId}) => "/parties/v1/parties/$partyId/accessibility";
  String Party_SetLookingForMore() => "";
  String Party_SetName() => "";
  String Party_SetPreferredGamePods({required String partyId}) => "/parties/v1/parties/$partyId/preferredgamepods";
  String Party_InviteToParty({required String partyId}) => "/parties/v1/parties/$partyId/invites";
  String Party_InviteToPartyByDisplayName({required String partyId, required String playerName, required String playerTag}) => "/v1/parties/$partyId/invites/name/$playerName/tag/$playerTag";
  String Party_DeclineInvite({required String partyId}) => "/parties/v1/parties/$partyId/invites/decline";
  String Party_RequestToJoinParty({required String partyId}) => "/parties/v1/parties/$partyId/request";
  String Party_DeclineRequest({required String partyId, required String requestId}) => "/parties/v1/parties/$partyId/request/$requestId/decline";
  String Party_Balance() => "";
  String Party_SetCheats() => "";
  String Party_FetchCustomGameConfigs() => "/parties/v1/parties/customgameconfigs";
  String Party_BaseUrlType() => "glz";

  String Pregame_GetPlayer({required String puuid}) => "/pregame/v1/players/$puuid";
  String Pregame_FixPlayerSession() => "";
  String Pregame_GetMatch({required String matchId}) => "/pregame/v1/matches/$matchId";
  String Pregame_GetMatchLoadouts({required String matchId}) => "/pregame/v1/matches/$matchId/loadouts";
  String Pregame_SelectCharacter({required String matchId, required String characterId}) => "/pregame/v1/matches/$matchId/select/$characterId";
  String Pregame_LockCharacter({required String matchId, required String characterId}) => "/pregame/v1/matches/$matchId/lock/$characterId";
  String Pregame_FetchVoiceToken({required String matchId}) => "/pregame/v1/matches/$matchId/voicetoken";
  String Pregame_FetchChatToken({required String matchId}) => "/pregame/v1/matches/$matchId/chattoken";
  String Pregame_QuitMatch({required String matchId}) => "/pregame/v1/matches/$matchId/quit";
  String Pregame_BaseUrlType() => "glz";

  String Restrictions_PlayerReportToken({required String matchId, required String offenderUserId}) => "/restrictions/v1/playerReportToken/$matchId/$offenderUserId";
  String Restrictions_FetchPlayerRestrictionsV2() => "/restrictions/v2/penalties";
  String Restrictions_BaseUrlType() => "pd";

  String Session_Connect({required String puuid}) => "/session/v2/sessions/$puuid/connect";
  String Session_Heartbeat({required String puuid}) => "/session/v1/sessions/$puuid/heartbeat";
  String Session_Disconnect({required String puuid}) => "/session/v1/sessions/$puuid/disconnect";
  String Session_Get({required String puuid}) => "/session/v1/sessions/$puuid";
  String Session_ReConnect({required String puuid}) => "/session/v1/sessions/$puuid/reconnect";
  String Session_BaseUrlType() => "glz";

  String Store_GetWallet({required String puuid}) => "/store/v1/wallet/$puuid";
  String Store_CreateOrder() => "/store/v1/order/";
  String Store_CreateBundleOrder({required String bundleId}) => "/store/v1/bundles/$bundleId/order";
  String Store_GetOrder({required String orderId}) => "/store/v1/order/$orderId";
  String Store_GetStorefrontV2({required String puuid}) => "/store/v2/storefront/$puuid";
  String Store_GetOffers() => "/store/v1/offers/";
  String Store_GetEntitlements({required String puuid, required String itemTypeId}) => "/store/v1/entitlements/$puuid/$itemTypeId";
  String Store_RevealNightMarketOffers({required String puuid}) => "/store/v2/storefront/$puuid/nightmarket/offers";
  String Store_BaseUrlType() => "pd";

  String LocalRiotClient_GetAllPresences() => "/chat/v4/presences";
  String LocalRiotClient_GetSession() => "/product-session/v1/external-sessions";
  String LocalRiotClient_GetActiveAlias() => "/player-account/aliases/v1/active";
  String LocalRiotClient_GetEntitlementsToken() => "/player-account/aliases/v1/active";
  String LocalRiotClient_GetChatSession() => "/chat/v1/session";
  String LocalRiotClient_GetAllFriends() => "/chat/v4/friends";
  String LocalRiotClient_GetSettings() => "/player-preferences/v1/data-json/Ares.PlayerSettings";
  String LocalRiotClient_GetFriendRequests() => "/chat/v4/friendrequests";
  String LocalRiotClient_BaseUrlType() => "local";
}
