// Just for ease of access
const string pluginName = Meta::ExecutingPlugin().Name;

// Settings
[Setting name="Blue Team Name" description="How the blue team is called" category="Scoreboard"]
string blueTeamName = "";
[Setting name="Red Team Name" description="How the red team is called" category="Scoreboard"]
string redTeamName = "";
[Setting name="Custom Point Repartition" description="Comma-separated list of points for each player position (1 point diff each position by default)" category="Scoreboard"]
string customPointRepartition = "";
[Setting name="Scoreboard Scale" description="Adjust size of the scoreboard" category="Scoreboard" min=0.1 max=3.0]
float scoreboardScaling = 1.0;
[Setting name="Show Round Points" description="Shows sum of current round points" category="Scoreboard"]
bool showRoundPoints = false;

[Setting name="Show Player Leaderboard" description="Shows live player leaderboard on the left (kind of experimental)" category="Leaderboard"]
bool showPlayerLeaderboard = false;
[Setting name="Leaderboard Position" description="Adjust the leaderboard position" category="Leaderboard" min=0 max=100]
float leaderboardYPositionPerc = 12;
[Setting name="Leaderboard Scale" description="Adjust size of the leaderboard" category="Leaderboard" min=0.1 max=3.0]
float leaderboardScaling = 1.0;

[Setting name="Polling Rate Milliseconds" description="How often the plugin checks for players positions" category="Misc" min=500]
int dataPollingRateMs = 1000;

// Global stuff
string currentMap = "";
array<uint> pointRepartition;
Scoreboard::TeamScoreboard@ scoreboard;
Leaderboard::PlayerLeaderboard@ leaderboard;
bool justFinished = true;
uint activePlayers = 0;
float leaderboardYPosition = leaderboardYPositionPerc * 1080 / 100.0;


void Render() {
    if (scoreboard is null) return;
    auto app = cast<CTrackMania>(GetApp());
    if (!(UI::IsGameUIVisible() && IsInGame(app) && IsTeamsMode(app))) return;
    scoreboard.draw(showRoundPoints);
    if (showPlayerLeaderboard) leaderboard.draw();
}


void loadScores() {
    auto mmdata = MLFeed::GetTeamsMMData_V1();
    if (mmdata is null || mmdata.ClanScores.Length < 3) return;
    scoreboard.setScores(mmdata.ClanScores[1], mmdata.ClanScores[2]);
}


void monitorMatch() {
    // Check we are gaming, and in the right mode
    auto app = cast<CTrackMania>(GetApp());
    if (
        app.CurrentPlayground is null
        || (app.CurrentPlayground.UIConfigs.Length < 1)
        || !IsTeamsMode(app)
    ) {
        scoreboard.reset();
        currentMap = "";
        activePlayers = 0;
        return;
    };

    // If we changed track, we reset some stuff
    auto mapName = Text::StripFormatCodes(app.RootMap.MapName);
    if (currentMap != mapName) {
        if (currentMap != "") {
            scoreboard.reset();
        } else {
            loadScores();
        }
        currentMap = mapName;
        activePlayers = 0;
        return;
    }

    // Check if in warmup, we generally do no need to do anything here
    if (IsInWarmup(app)) {
        scoreboard.reset();
        activePlayers = 0;
        return;
    }

    // No team is "winning" between rounds, and we update the scores
    if (IsEndRound(app)) {
        loadScores();
        activePlayers = 0;
        leaderboard.setSize(0);
        if (!justFinished) {
            scoreboard.setPoints(0, 0);
            return;
        }
        justFinished = false;
    } else {
        justFinished = true;
    }

    // Grab player positions and show who is currently winning the round
    array<uint> points = {0, 0};
    auto mlf = MLFeed::GetRaceData_V4();
    if (activePlayers == 0) {
        // SortedPlayers_Race includes spectators as well, so we need to calculate
        // the count of players actually in the race manually
        for (uint i = 0; i < mlf.SortedPlayers_Race.Length; i++) {
            if (mlf.SortedPlayers_Race[i].PlayerIsRacing) activePlayers++;
        }
    }
    leaderboard.setSize(activePlayers);
    for (uint i = 0; i < mlf.SortedPlayers_Race.Length; i++) {
        uint score = 0;
        auto player = cast<MLFeed::PlayerCpInfo_V4>(mlf.SortedPlayers_Race[i]);
        int color = player.TeamNum - 1;
        if ((!player.PlayerIsRacing && !player.IsFinished) || color < 0 || color > 1) continue;
        uint position = player.RaceRespawnRank - 1;
        if (pointRepartition.Length > 0) {
            score = position < pointRepartition.Length ? pointRepartition[position] : 0;
        } else {
            score = Math::Max(activePlayers - position, 0);
        }
        points[color] += score;
        if (showPlayerLeaderboard) {
            leaderboard.setPosition(position, player.Name, TeamColor(color), player.LastCpTime);
        }
    }
    scoreboard.setPoints(points[TeamColor::BLUE], points[TeamColor::RED]);
}


void OnSettingsChanged() {
    scoreboardScaling = Math::Round(scoreboardScaling, 1);
    leaderboardScaling = Math::Round(leaderboardScaling, 1);
    leaderboardYPositionPerc = Math::Round(leaderboardYPositionPerc, 1);
    leaderboardYPosition = leaderboardYPositionPerc * 1080 / 100.0;
    scoreboard.setName(TeamColor::BLUE, blueTeamName);
    scoreboard.setName(TeamColor::RED, redTeamName);
    if (customPointRepartition == "") {
        pointRepartition.Resize(0);
    } else {
        auto points = customPointRepartition.Split(",");
        pointRepartition.Resize(points.Length);
        for (uint i = 0; i < points.Length; i++) {
            pointRepartition[i] = Text::ParseUInt(points[i]);
        }
    }
}


void Main() {
    DepCheck();
    @leaderboard = Leaderboard::PlayerLeaderboard();
    @scoreboard = Scoreboard::TeamScoreboard(blueTeamName, redTeamName);
    loadScores();
    while (true) {
        monitorMatch();
        sleep(dataPollingRateMs);
    }
}
