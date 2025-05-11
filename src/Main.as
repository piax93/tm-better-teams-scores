// Just for ease of access
const string pluginName = Meta::ExecutingPlugin().Name;

// Settings
[Setting name="Blue Team Name" description="How the blue team is called" category="General"]
string blueTeamName = "";
[Setting name="Red Team Name" description="How the red team is called" category="General"]
string redTeamName = "";
[Setting name="Custom Point Repartition" description="Comma-separated list of points for each player position" category="General"]
string customPointRepartition = "";
[Setting name="UI Scale" description="Adjust size of the scoreboard" category="General" min=0.1 max=3.0]
float uiScaling = 1.0;
[Setting name="Show Round Points" description="Shows sum of current round points" category="General"]
bool showRoundPoints = false;
[Setting name="Polling Rate Milliseconds" description="How often the plugin checks for players positions" category="General" min=500]
int dataPollingRateMs = 1000;

// Global stuff
string currentMap = "";
array<uint> pointRepartition;
TeamScoreboard@ scoreboard;
bool justFinished = true;


void Render() {
    if (scoreboard is null) return;
    auto app = cast<CTrackMania>(GetApp());
    if (!(UI::IsGameUIVisible() && IsInGame(app) && IsTeamsMode(app))) return;
    scoreboard.draw(showRoundPoints);
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
        return;
    }

    // Check if in warmup, we generally do no need to do anything here
    if (IsInWarmup(app)) {
        scoreboard.reset();
        return;
    }

    // No team is "winning" between rounds, and we update the scores
    if (IsEndRound(app)) {
        loadScores();
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
    for (uint i = 0; i < mlf.SortedPlayers_Race.Length; i++) {
        uint score = 0;
        auto player = cast<MLFeed::PlayerCpInfo_V4>(mlf.SortedPlayers_Race[i]);
        if (!player.PlayerIsRacing) continue;
        uint position = player.RaceRank - 1;
        if (pointRepartition.Length > 0) {
            score = position < pointRepartition.Length ? pointRepartition[position] : 0;
        } else {
            score = mlf.SortedPlayers_Race.Length - position;
        }
        points[player.TeamNum - 1] += score;
    }
    scoreboard.setPoints(points[TeamColor::BLUE], points[TeamColor::RED]);
}


void OnSettingsChanged() {
    uiScaling = Math::Round(uiScaling, 1);
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
    @scoreboard = TeamScoreboard(blueTeamName, redTeamName);
    loadScores();
    while (true) {
        monitorMatch();
        sleep(dataPollingRateMs);
    }
}
