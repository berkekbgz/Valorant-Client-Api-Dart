import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'auth.dart';
import 'models/endpoint_model.dart';
import 'resources.dart';

class Client {
  final resources = ValorantResources.instance;
  String puuid = "";
  Map<dynamic, dynamic> lockfile = {};
  Map<String, String> headers = {"content-type": "application/json"};
  Map<String, String> localHeaders = {};
  String? lockfilepath;
  String? region;
  String? shard;
  Auth? auth;

  Client({required String region, auth}) {
    if (auth == null) {
      lockfilepath = Platform.environment['LOCALAPPDATA']! + r"\Riot Games\Riot Client\Config\lockfile";
    } else {
      this.auth = Auth(auth['username'], auth['password']);
    }

    if (resources.regions.contains(region)) {
      this.region = region;
      shard = region;
    } else {
      throw Exception("Invadlid region, valid regions are: ${ValorantResources.instance.regions}");
    }

    if (resources.regionShardOverrides.keys.contains(this.region)) shard = resources.regionShardOverrides[this.region]!;
    if (resources.shardRegionOverrides.keys.contains(shard)) this.region = resources.shardRegionOverrides[shard]!;
  }

  List<String> get regions => resources.regions;

  Future<void> activate() async {
    try {
      if (auth == null) {
        lockfile = await _getLockfile();
        localHeaders = _getLocalHeaders();
        headers.addAll(await _getHeaders(lockfile['port'], localHeaders));
        puuid = await _getPuuid(lockfile['port'], localHeaders);
      } else {
        var authenticated = await auth!.authenticate();
        puuid = authenticated['userId'];
        headers.addAll(authenticated['headers']);
        localHeaders = {};
      }
    } catch (e) {
      throw Exception("Unable to activate; is VALORANT running? + $e");
    }
  }

  Future<Map<String, dynamic>> fetch({required Endpoint endpoint}) async {
    Map<String, dynamic>? data;
    var response = await http.get(Uri.parse(endpoint.baseUrlType.uri(this) + endpoint.url), headers: endpoint.useLocalHeaders ? localHeaders : headers);
    data = json.decode(response.body);
    if (data != null) {
      if (data['httpStatus'] == 400) {
        //If headers expired
        if (auth == null) {
          localHeaders = _getLocalHeaders();
          (headers = await _getHeaders(lockfile['port'], localHeaders)).addAll({"content-type": "application/json"});
          puuid = await _getPuuid(lockfile['port'], localHeaders);
        } else {
          var authenticate = await auth!.authenticate();
          puuid = authenticate['userId'];
          headers.addAll(authenticate['headers']);
          localHeaders = {};
        }
        return fetch(endpoint: endpoint);
      } else {
        return data;
      }
    } else {
      throw Exception("Fetch request returned null. Endpoint: $endpoint");
    }
  }

  Future<Map<String, dynamic>> post({required Endpoint endpoint, Object? jsonData}) async {
    var response = await http.post(Uri.parse(endpoint.baseUrlType.uri(this) + endpoint.url), headers: endpoint.useLocalHeaders ? localHeaders : headers, body: json.encode(jsonData ?? {}));
    var data = json.decode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> put({required Endpoint endpoint, Object? jsonData}) async {
    var response = await http.put(Uri.parse(endpoint.baseUrlType.uri(this) + endpoint.url), headers: endpoint.useLocalHeaders ? localHeaders : headers, body: json.encode(jsonData ?? {}));
    var data = json.decode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> delete({required Endpoint endpoint, Object? jsonData}) async {
    var response = await http.delete(Uri.parse(endpoint.baseUrlType.uri(this) + endpoint.url), headers: endpoint.useLocalHeaders ? localHeaders : headers, body: json.encode(jsonData ?? {}));
    var data = json.decode(response.body);
    return data;
  }

  // --------------------------------------------------------------------
  //PVP ENDPOINTS

  /// ### Content_FetchContent
  ///
  ///Get names and ids for game content such as agents, maps, guns, etc.
  Future<Map<String, dynamic>> fetchContent() async {
    var data = await fetch(endpoint: resources.endpoints.Content_FetchContent());
    return data;
  }

  /// ### AccountXP_GetPlayer
  ///
  ///Get the account level, XP, and XP history for the active player
  Future<Map<String, dynamic>> fetchAccountXP() async {
    var data = await fetch(endpoint: resources.endpoints.AccountXP_GetPlayer(puuid: puuid));
    return data;
  }

  /// ### playerLoadoutUpdate
  ///
  ///Get the player's current loadout
  Future<Map<String, dynamic>> fetchPlayerLoadout() async {
    var data = await fetch(endpoint: resources.endpoints.playerFetchLoadoutUpdate(puuid: puuid));
    return data;
  }

  /// ### playerLoadoutUpdate
  ///
  /// Use the values from client.fetch_player_loadout() excluding properties like subject and version. Loadout changes take effect when starting a new game
  Future<Map<String, dynamic>> putPlayerLoadout(Map<String, dynamic> loadout) async {
    var data = await put(endpoint: resources.endpoints.playerSaveLoadoutUpdate(puuid: puuid), jsonData: loadout);
    return data;
  }

  /// ### MMR_FetchPlayer
  ///
  /// Get the match making rating for a player
  Future<Map<String, dynamic>> fetchMMR({String? puuid}) async {
    var data = await fetch(endpoint: resources.endpoints.MMR_FetchPlayer(puuid: puuid ?? this.puuid));
    return data;
  }

  /// ### MatchHistory_FetchMatchHistory
  ///
  /// Get recent matches for a player
  ///
  /// There are 3 optional query parameters: start_index, end_index, and queue_id. queue can be one of null, competitive, custom, deathmatch, ggteam, newmap, onefa, snowball, spikerush, or unrated.
  Future<Map<String, dynamic>> fetchMatchHistory({String? puuid, int startIndex = 0, int endIndex = 15, Queues queue = Queues.empty}) async {
    if (resources.queueIsValid(queue)) {
      var data = await fetch(endpoint: resources.endpoints.MatchHistory_FetchMatchHistory(puuid: puuid ?? this.puuid, startIndex: startIndex, endIndex: endIndex, queue: queue));
      return data;
    }
    throw Exception("Queue Name is not valid");
  }

  /// Get the full info for a match
  ///
  /// Includes everything that the in-game match details screen shows including damage and kill positions, same as the official API w/ a production key
  Future<Map<String, dynamic>> fetchMatchDetails({required String matchId}) async {
    var data = await fetch(endpoint: resources.endpoints.MatchDetails_FetchMatchDetails(matchId: matchId));
    return data;
  }

  /// ###MMR_FetchCompetitiveUpdates
  ///
  /// Get recent games and how they changed ranking
  ///
  /// There are 3 optional query parameters: start_index, end_index, and queue_id. queue can be one of null, competitive, custom, deathmatch, ggteam, newmap, onefa, snowball, spikerush, or unrated.
  Future<Map<String, dynamic>> fetchCompetitiveUpdates({String? puuid, int startIndex = 0, int endIndex = 15, Queues queue = Queues.competitive}) async {
    var data = await fetch(endpoint: resources.endpoints.MMR_FetchCompetitiveUpdates(puuid: puuid ?? this.puuid, startIndex: startIndex, endIndex: endIndex));
    return data;
  }

  /// ### MMR_FetchLeaderboard
  ///
  /// Get the competitive leaderboard for a given season
  ///
  /// The query parameter query can be added to search for a username.
  Future<Map<String, dynamic>> fetchLeaderboard({Map<String, dynamic>? season, int startIndex = 0, int size = 25}) async {
    season = season ?? await _getCurrentSeason();
    var data = await fetch(endpoint: resources.endpoints.MMR_FetchLeaderboard(region: shard!, seasonId: season['ID'], startIndex: startIndex, size: size));
    return data;
  }

  /// ### Restrictions_FetchPlayerRestrictionsV2
  ///
  /// Checks for any gameplay penalties on the account
  Future<Map<String, dynamic>> fetchPlayerRestrictions() async {
    var data = await fetch(endpoint: resources.endpoints.Restrictions_FetchPlayerRestrictionsV2());
    return data;
  }

  /// ###  ItemProgressionDefinitionsV2_Fetch
  ///
  /// Get details for item upgrades
  Future<Map<String, dynamic>> fetchItemProgressionDefinitions() async {
    var data = await fetch(endpoint: resources.endpoints.ItemProgressionDefinitionsV2_Fetch());
    return data;
  }

  /// ### Config_FetchConfig
  ///
  /// Get various internal game configuration settings set by Riot
  Future<Map<String, dynamic>> fetchConfig() async {
    var data = await fetch(endpoint: resources.endpoints.Config_FetchConfig(region: shard!));
    return data;
  }

  /// ### DisplayNameService_FetchPlayers_BySubjects
  ///
  /// Get players displayname, GameName, TagLine and subject
  Future<List<Map<String, dynamic>>> fetchNameByPuuidList({List<String>? puuids}) async {
    var data = await http.put(
      Uri.parse(resources.endpoints.DisplayNameService_FetchPlayers_BySubjects().baseUrlType.uri(this) + resources.endpoints.DisplayNameService_FetchPlayers_BySubjects().url),
      body: json.encode(puuids ?? [puuid]),
    );

    return (json.decode(data.body) as List).map((data) => data = data as Map<String, dynamic>).toList();
  }

  /// ### PlayerPreferences_GetSettings
  ///
  /// Get players ingame settings
  Future<Map<String, dynamic>> fetchPlayerSettings() async {
    var response = await fetch(endpoint: resources.endpoints.PlayerPreferences_GetSettings());
    var encryptedSettings = base64.decode(response['data'].toString());
    var settings = ZLibCodec(raw: true).decode(encryptedSettings);
    return json.decode(utf8.decode(settings));
  }

  //Store endpoints

  /// ### Store_GetOffers
  ///
  /// Get prices for all store items
  Future<Map<String, dynamic>> storeFetchOffers() async {
    var data = await fetch(endpoint: resources.endpoints.Store_GetOffers());
    return data;
  }

  /// ### Store_GetStorefrontV2
  ///
  /// Get the currently available items in the store
  Future<Map<String, dynamic>> storeFetchStoreFront() async {
    var data = await fetch(endpoint: resources.endpoints.Store_GetStorefrontV2(puuid: puuid));
    return data;
  }

  /// ### Store_GetWallet
  ///
  /// Get amount of Valorant points and Radianite the player has
  ///
  ///Valorant points have the id 85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741 and Radianite points have the id e59aa87c-4cbf-517a-5983-6e81511be9b7
  Future<Map<String, dynamic>> storeFetchWallet() async {
    var data = await fetch(endpoint: resources.endpoints.Store_GetWallet(puuid: puuid));
    return data;
  }

  /// ### Store_GetOrder
  ///
  ///* [orderID]: The ID of the order. Can be obtained when creating an order.
  Future<Map<String, dynamic>> storeFetchOrder({required String orderId}) async {
    var data = await fetch(endpoint: resources.endpoints.Store_GetOrder(orderId: orderId));
    return data;
  }

  /// ### Store_GetEntitlements
  ///
  ///List what the player owns (agents, skins, buddies, ect.)
  ///
  ///Correlate with the UUIDs in client.fetch_content() to know what items are owned
  ///
  ///NOTE: uuid to item id
  ///```
  ///"e7c63390-eda7-46e0-bb7a-a6abdacd2433" //skin_level,
  ///"3ad1b2b2-acdb-4524-852f-954a76ddae0a" //skin_chroma,
  ///"01bb38e1-da47-4e6a-9b3d-945fe4655707" //agent,
  ///"f85cb6f7-33e5-4dc8-b609-ec7212301948" //contract_definition,
  ///"dd3bf334-87f3-40bd-b043-682a57a8dc3a" //buddy,
  ///"d5f120f8-ff8c-4aac-92ea-f2b5acbe9475" //spray,
  ///"3f296c07-64c3-494c-923b-fe692a4fa1bd" //player_card,
  ///"de7caa6b-adf7-4588-bbd1-143831e786c6" //player_title,
  ///```
  Future<Map<String, dynamic>> storeFetchEntitlements({String? puuid, required String itemTypeID}) async {
    var data = await fetch(endpoint: resources.endpoints.Store_GetEntitlements(puuid: puuid ?? this.puuid, itemTypeId: itemTypeID));
    return data;
  }

  //Party endpoints

  /// ### Party_FetchPlayer
  ///
  /// Get the Party ID that a given player belongs to
  Future<Map<String, dynamic>> partyFetchPlayer() async {
    var data = await fetch(endpoint: resources.endpoints.Party_FetchPlayer(puuid: puuid));
    return data;
  }

  /// ### Party_RemovePlayer
  ///
  /// Removes a player from the current party
  Future<Map<String, dynamic>> partyRemovePlayer({String? puuid}) async {
    var data = await delete(endpoint: resources.endpoints.Party_RemovePlayer(puuid: puuid ?? this.puuid));
    return data;
  }

  /// ### Party_FetchParty
  ///
  /// Get details about a given party id
  Future<Map<String, dynamic>> fetchParty() async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = await fetch(endpoint: resources.endpoints.Party_FetchParty(partyId: partyId));
    return data;
  }

  /// ### Party_SetMemberReady
  ///
  /// Sets whether a party member is ready for queueing or not
  Future<Map<String, dynamic>> partySetMemberReady({required bool isReady}) async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = await post(endpoint: resources.endpoints.Party_SetMemberReady(puuid: puuid, partyId: partyId));
    return data;
  }

  /// ### Party_RefreshCompetitiveTier
  ///
  /// Refreshes the competitive tier for a player
  Future<Map<String, dynamic>> partyRefreshCompetitiveTier() async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = await post(endpoint: resources.endpoints.Party_RefreshCompetitiveTier(puuid: puuid, partyId: partyId));
    return data;
  }

  /// ### Party_RefreshPlayerIdentity
  ///
  /// Refreshes the identity for a player
  Future<Map<String, dynamic>> partyRefreshPlayerIdentity() async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = await post(endpoint: resources.endpoints.Party_RefreshPlayerIdentity(puuid: puuid, partyId: partyId));
    return data;
  }

  /// ### Party_RefreshPings
  ///
  /// Refreshes the pings for a player
  Future<Map<String, dynamic>> partyRefreshPings() async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = await post(endpoint: resources.endpoints.Party_RefreshPings(puuid: puuid, partyId: partyId));
    return data;
  }

  /// ### Party_ChangeQueue
  ///
  /// Sets the matchmaking queue for the party
  Future<Map<String, dynamic>> partyChangeQueue({required String queueId}) async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = await post(endpoint: resources.endpoints.Party_ChangeQueue(partyId: partyId));
    return data;
  }

  /// ### Party_StartCustomGame
  ///
  /// Starts a custom game
  Future<Map<String, dynamic>> partyStartCustomGame() async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = post(endpoint: resources.endpoints.Party_StartCustomGame(partyId: partyId));
    return data;
  }

  /// ### Party_EnterMatchmakingQueue
  ///
  /// Enters the matchmaking queue
  Future<Map<String, dynamic>> partyEnterMatchmakingQueue() async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = post(endpoint: resources.endpoints.Party_EnterMatchmakingQueue(partyId: partyId));
    return data;
  }

  /// ### Party_LeaveMatchmakingQueue
  ///
  /// Leaves the matchmaking queue
  Future<Map<String, dynamic>> partyLeaveMatchmakingQueue() async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = post(endpoint: resources.endpoints.Party_LeaveFromParty(puuid: puuid, partyId: partyId));
    return data;
  }

  /// ### Party_SetAccessibility
  ///
  /// Changes the party accessibility to be open or closed
  Future<Map<String, dynamic>> setPartyAccessibility({required bool isOpen}) async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = post(endpoint: resources.endpoints.Party_SetAccessibility(partyId: partyId), jsonData: {"accessibility": isOpen ? "OPEN" : "CLOSED"});
    return data;
  }

  /// ### Party_SetCustomGameSettings
  ///
  /// Changes the settings for a custom game
  ///
  /// settings:
  ///```json
  /// {
  ///     "Map": "/Game/Maps/Triad/Triad", // map url
  ///     "Mode": "/Game/GameModes/Bomb/BombGameMode.BombGameMode_C", // url to gamemode
  ///     "UseBots": true, // this isn't used anymore :(
  ///     "GamePod": "aresriot.aws-rclusterprod-use1-1.na-gp-ashburn-awsedge-1", // server
  ///     "GameRules": null // idk what this is for
  /// }
  ///```
  Future<Map<String, dynamic>> partySetCustomGameSettings({required Map<String, dynamic> settings}) async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = post(endpoint: resources.endpoints.Party_SetCustomGameSettings(partyId: partyId), jsonData: settings);
    return data;
  }

  /// ### Party_InviteToPartyByDisplayName
  ///
  /// Invites a player to the party with their display name
  ///
  /// omit the "#" in tag
  Future<Map<String, dynamic>> partyInviteByDisplayName({required String name, required String tag}) async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = post(endpoint: resources.endpoints.Party_InviteToPartyByDisplayName(partyId: partyId, playerName: name, playerTag: tag));
    return data;
  }

  /// ### Party_RequestToJoinParty
  ///
  /// Requests to join a party
  Future<Map<String, dynamic>> partyRequestToJoin({required String partyId, required String otherPuuid}) async {
    var data = post(endpoint: resources.endpoints.Party_RequestToJoinParty(partyId: partyId), jsonData: {
      "Subjects": [otherPuuid]
    });
    return data;
  }

  /// ### Party_DeclineRequest
  ///
  /// Declines a party request
  ///
  ///* [requestId] : The ID of the party request. Can be found from the Requests array on the Party_FetchParty endpoint.
  Future<Map<String, dynamic>> partyDeclineRequest({required String requestId}) async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = post(endpoint: resources.endpoints.Party_DeclineRequest(partyId: partyId, requestId: requestId));
    return data;
  }

  /// ### Party_PlayerJoin
  ///
  /// Join a party
  Future<Map<String, dynamic>> partyJoin({required String partyId}) async {
    var data = post(endpoint: resources.endpoints.Party_PlayerJoin(puuid: puuid, partyId: partyId));
    return data;
  }

  /// ### Party_PlayerLeave
  ///
  /// Leave a party
  Future<Map<String, dynamic>> partyLeave({required String partyId}) async {
    var data = post(endpoint: resources.endpoints.Party_PlayerLeave(puuid: puuid, partyId: partyId));
    return data;
  }

  /// ### Party_FetchCustomGameConfigs
  ///
  /// Get information about the available gamemodes
  Future<Map<String, dynamic>> partyFetchCustomGameConfigs() async {
    var data = post(endpoint: resources.endpoints.Party_FetchCustomGameConfigs());
    return data;
  }

  /// ### Party_FetchMUCToken
  ///
  /// Get a token for party chat
  Future<Map<String, dynamic>> partyFetchMucToken() async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = post(endpoint: resources.endpoints.Party_FetchMUCToken(partyId: partyId));
    return data;
  }

  /// ### Party_FetchVoiceToken
  ///
  /// Get a token for party voice
  Future<Map<String, dynamic>> partyFetchVoiceToken() async {
    String partyId = (await partyFetchPlayer())['CurrentPartyID'];
    var data = post(endpoint: resources.endpoints.Party_FetchVoiceToken(partyId: partyId));
    return data;
  }

  //Pregame endpoints

  /// ### Pregame_GetPlayer
  ///
  /// Get the ID of a game in the pre-game stage
  Future<Map<String, dynamic>> pregameFetchPlayer() async {
    var data = await fetch(endpoint: resources.endpoints.Pregame_GetPlayer(puuid: puuid));
    return data;
  }

  /// ### Pregame_GetMatch
  ///
  /// Get info for a game in the pre-game stage
  Future<Map<String, dynamic>> pregameFetchMatch({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await fetch(endpoint: resources.endpoints.Pregame_GetMatch(matchId: matchId!));
    return data;
  }

  /// ### Pregame_GetMatchLoadouts
  ///
  /// Get player skins and sprays for a game in the pre-game stage
  Future<Map<String, dynamic>> pregameFetchMatchLoadouts({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await fetch(endpoint: resources.endpoints.Pregame_GetMatchLoadouts(matchId: matchId!));
    return data;
  }

  /// ### Pregame_FetchChatToken
  ///
  /// Get a chat token
  Future<Map<String, dynamic>> pregameFetchChatToken({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await fetch(endpoint: resources.endpoints.Pregame_FetchChatToken(matchId: matchId!));
    return data;
  }

  /// ### Pregame_FetchVoiceToken
  ///
  /// Get a voice token
  Future<Map<String, dynamic>> pregameFetchVoiceToken({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await fetch(endpoint: resources.endpoints.Pregame_FetchVoiceToken(matchId: matchId!));
    return data;
  }

  /// ### Pregame_SelectCharacter
  ///
  /// Select an agent
  ///
  /// don't use this for instalocking :)
  Future<Map<String, dynamic>> pregameSelectCharacter({required String agentId, String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await post(endpoint: resources.endpoints.Pregame_SelectCharacter(matchId: matchId!, characterId: agentId));
    return data;
  }

  /// ### Pregame_LockCharacter
  ///
  /// Lock in an agent
  ///
  /// don't use this for instalocking :)
  Future<Map<String, dynamic>> pregameLockCharacter({required String agentId, String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await post(endpoint: resources.endpoints.Pregame_LockCharacter(matchId: matchId!, characterId: agentId));
    return data;
  }

  /// ### Pregame_QuitMatch
  ///
  /// Quit a match in the pre-game stage
  Future<Map<String, dynamic>> pregameQuitMatch({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await post(endpoint: resources.endpoints.Pregame_QuitMatch(matchId: matchId!));
    return data;
  }

  //Coregame endpoints

  /// ### CoreGame_FetchPlayer
  ///
  /// Get the game ID for an ongoing game the player is in
  Future<Map<String, dynamic>> coregameFetchPlayer() async {
    var data = await fetch(endpoint: resources.endpoints.CoreGame_FetchPlayer(puuid: puuid));
    return data;
  }

  /// ### CoreGame_FetchMatch
  ///
  /// Get information about an ongoing game
  Future<Map<String, dynamic>> coregameFetchMatch({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await fetch(endpoint: resources.endpoints.CoreGame_FetchMatch(matchId: matchId!));
    return data;
  }

  /// ### CoreGame_FetchMatchLoadouts
  ///
  /// Get player skins and sprays for an ongoing game
  Future<Map<String, dynamic>> coregameFetchMatchLoadouts({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await fetch(endpoint: resources.endpoints.CoreGame_FetchMatchLoadouts(matchId: matchId!));
    return data;
  }

  /// ### CoreGame_FetchTeamChatMUCToken
  ///
  /// Get a token for team chat
  Future<Map<String, dynamic>> coregameFetchTeamChatMucToken({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await fetch(endpoint: resources.endpoints.CoreGame_FetchTeamChatMUCToken(matchId: matchId!));
    return data;
  }

  /// ### CoreGame_FetchAllChatMUCToken
  ///
  /// Get a token for all chat
  Future<Map<String, dynamic>> coregameFetchAllChatMucToken({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await fetch(endpoint: resources.endpoints.CoreGame_FetchAllChatMUCToken(matchId: matchId!));
    return data;
  }

  /// ### CoreGame_DisassociatePlayer
  ///
  /// Leave an in-progress game
  Future<Map<String, dynamic>> coregameDisasociatePlayer({String? matchId}) async {
    matchId = matchId ?? (await pregameFetchPlayer())['MatchID'];
    var data = await fetch(endpoint: resources.endpoints.CoreGame_DisassociatePlayer(puuid: puuid, matchId: matchId!));
    return data;
  }

  // Contract endpoints

  /// ### ContractDefinitions_Fetch
  ///
  /// Get names and descriptions for contracts
  Future<Map<String, dynamic>> contractsFetchDefinitions() async {
    var data = await fetch(endpoint: resources.endpoints.ContractDefinitions_Fetch());
    return data;
  }

  /// ### Contracts_Fetch
  ///
  ///Get a list of contracts and completion status including match history
  Future<Map<String, dynamic>> contractsFetch() async {
    var data = await fetch(endpoint: resources.endpoints.Contracts_Fetch(puuid: puuid));
    return data;
  }

  /// ### Contracts_Activate
  ///
  ///  Activate a particular contract
  ///
  ///* [contract id]: The ID of the contract to activate. Can be found from the ContractDefinitions_Fetch endpoint.
  Future<Map<String, dynamic>> contractsActivate({required String contractId}) async {
    var data = await fetch(endpoint: resources.endpoints.Contracts_Activate(puuid: puuid, contractId: contractId));
    return data;
  }

  /// ### ContractDefinitions_FetchActiveStory
  ///
  /// Get the battlepass contracts
  Future<Map<String, dynamic>> contractsFetchActiveStory() async {
    var data = await fetch(endpoint: resources.endpoints.ContractDefinitions_FetchActiveStory());
    return data;
  }

  // Session endpoints

  /// ### Session_Get
  ///
  /// Get information about the current game session
  Future<Map<String, dynamic>> sessionFetch() async {
    var data = await fetch(endpoint: resources.endpoints.Session_Get(puuid: puuid));
    return data;
  }

  /// ### Session_ReConnect
  Future<Map<String, dynamic>> sessionReconnect() async {
    var data = await fetch(endpoint: resources.endpoints.Session_ReConnect(puuid: puuid));
    return data;
  }

  //Local riotclient endpoints

  /// ### PRESENCE_RNet_GET
  ///
  /// NOTE: Only works on self or active user's friends
  Future<Map<String, dynamic>> localRiotClientFetchPresence({String? puuid}) async {
    var data = await fetch(endpoint: resources.endpoints.LocalRiotClient_GetAllPresences());
    for (var presence in data['presences']) {
      if (presence['puuid'] == (puuid ?? this.puuid)) {
        return json.decode(String.fromCharCodes(base64.decode(presence['private'])));
      }
    }
    throw Exception("Error while fetching presences");
  }

  /// ### PRESENCE_RNet_GET_ALL
  ///
  /// Get a list of online friends and their activity
  ///
  /// private is a base64-encoded JSON string that contains useful information such as party and in-progress game score.
  Future<Map<String, dynamic>> localRiotClientFetchAllPresence() async {
    var data = await fetch(endpoint: resources.endpoints.LocalRiotClient_GetAllPresences());
    return data;
  }

  /// ### RiotClientSession_FetchSessions
  ///
  /// Gets info about the running Valorant process including start arguments
  Future<Map<String, dynamic>> localRiotClientFetchSession() async {
    var data = await fetch(endpoint: resources.endpoints.LocalRiotClient_GetSession());
    return data;
  }

  /// ### PlayerAlias_RNet_GetActiveAlias
  ///
  /// Gets the player username and tagline
  Future<Map<String, dynamic>> localRiotClientFetchActiveAlias() async {
    var data = await fetch(endpoint: resources.endpoints.LocalRiotClient_GetActiveAlias());
    return data;
  }

  /// ### RSO_RNet_GetEntitlementsToken
  ///
  /// Gets both the token and entitlement for API usage
  ///
  /// accessToken is used as the token and token is used as the entitlement.
  ///
  /// PBE access can be checked through here
  Future<Map<String, dynamic>> localRiotClientFetchEntitlementsToken() async {
    var data = await fetch(endpoint: resources.endpoints.LocalRiotClient_GetEntitlementsToken());
    return data;
  }

  /// ### TEXT_CHAT_RNet_FetchSession
  ///
  /// Get the current session including player name and PUUID
  Future<Map<String, dynamic>> localRiotClientFetchChatSession() async {
    var data = await fetch(endpoint: resources.endpoints.LocalRiotClient_GetChatSession());
    return data;
  }

  /// ### CHATFRIENDS_RNet_GET_ALL
  ///
  /// Get a list of friends
  Future<Map<String, dynamic>> localRiotClientFetchAllFriends() async {
    var data = await fetch(endpoint: resources.endpoints.LocalRiotClient_GetAllFriends());
    return data;
  }

  /// ### RiotKV_RNet_GetSettings
  ///
  /// Get client settings
  Future<Map<String, dynamic>> localRiotClientFetchSettings() async {
    var data = await fetch(endpoint: resources.endpoints.LocalRiotClient_GetSettings());
    return data;
  }

  /// ### FRIENDS_RNet_FetchFriendRequests
  ///
  /// Get pending friend requests
  Future<Map<String, dynamic>> localRiotClientFetchFriendRequests() async {
    var data = await fetch(endpoint: resources.endpoints.LocalRiotClient_GetFriendRequests());
    return data;
  }

  // Local utility functions

  Map<String, String> _getLocalHeaders() {
    try {
      if (auth == null) {
        Map<String, String> localHeaders = {};
        localHeaders['Authorization'] = 'Basic ' + base64.encode(utf8.encode(('riot:' + lockfile['password'])));
        return (localHeaders);
      } else {
        throw Exception("Localhost not found");
      }
    } catch (e) {
      throw Exception("Local headers cant fetch");
    }
  }

  Future<Map<String, String>> _getHeaders(String port, Map<String, String> localHeaders) async {
    var response = await http.get(Uri.parse("https://127.0.0.1:$port/entitlements/v1/token"), headers: localHeaders);
    var entitlements = json.decode(response.body);
    headers = {
      'Authorization': "Bearer ${entitlements['accessToken']}",
      'X-Riot-Entitlements-JWT': entitlements['token'],
      'X-Riot-ClientPlatform': "ew0KCSJwbGF0Zm9ybVR5cGUiOiAiUEMiLA0KCSJwbGF0Zm9ybU9TIjogIldpbmRvd3MiLA0KCSJwbGF0Zm9ybU9TVmVyc2lvbiI6ICIxMC4wLjE5MDQyLjEuMjU2LjY0Yml0IiwNCgkicGxhdGZvcm1DaGlwc2V0IjogIlVua25vd24iDQp9",
      'X-Riot-ClientVersion': await _getCurrentVersion(),
    };
    return headers;
  }

  Future<String> _getPuuid(String port, Map<String, String> localHeaders) async {
    var response = await http.get(Uri.parse("https://127.0.0.1:$port/entitlements/v1/token"), headers: localHeaders);
    var puuid = json.decode(response.body)['subject'];
    return puuid;
  }

  Future<Map<String, dynamic>> _getCurrentSeason() async {
    var response = await http.get(Uri.parse("https://shared.ap.a.pvp.net/content-service/v2/content"), headers: headers);
    var seasons = json.decode(response.body)['Seasons'];
    for (var season in seasons) {
      if (season['IsActive'] == true) {
        return season;
      }
    }
    return {};
  }

  Future<String> _getCurrentVersion() async {
    var response = await http.get(Uri.parse('https://valorant-api.com/v1/version'));
    var data = json.decode(response.body);
    String version = data['data']['riotClientVersion'];
    return version;
  }

  Future<Map<String, dynamic>> _getLockfile() async {
    if (File(lockfilepath!).existsSync()) {
      var data = (await File(lockfilepath!).openRead().map(utf8.decode).transform(const LineSplitter()).first).split(':');
      return {
        "name": data[0],
        "PID": data[1],
        "port": data[2],
        "password": data[3],
        "protocol": data[4],
      };
    } else {
      throw Exception();
    }
  }
}
