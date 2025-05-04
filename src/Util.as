/**
 * Log warning and show notification
 */
void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification(
        Meta::ExecutingPlugin().Name + ": Error",
        msg,
        vec4(.9, .6, .1, .5),
        15000
    );
}


/**
 * Check MLHook and MLFeed are installed, stall if they are not
 */
void DepCheck() {
    bool depMLHook = false;
    bool depMLFeed = false;
#if DEPENDENCY_MLHOOK
    depMLHook = true;
#endif
#if DEPENDENCY_MLFEEDRACEDATA
    depMLFeed = true;
#endif
    if (!(depMLFeed && depMLHook)) {
        if (!depMLHook) {
            NotifyError("Requires MLHook");
        }
        if (!depMLFeed) {
            NotifyError("Requires MLFeed: Race Data");
        }
        while (true) sleep(10000);
    }
}


/**
 * Check if online rooms is in warmup round
 */
bool IsInWarmup(CTrackMania@ app) {
    return !(
        app.Network is null
        || app.Network.ClientManiaAppPlayground is null
        || app.Network.ClientManiaAppPlayground.UI.UIStatus != CGamePlaygroundUIConfig::EUIStatus::Warning
    );
}


/**
 * Check if we are playing a mode with teams
 */
bool IsTeamsMode(CTrackMania@ app) {
    return !(
        app.Network is null
        || app.Network.ServerInfo is null
    ) && cast<CTrackManiaNetworkServerInfo>(app.Network.ServerInfo).IsTeamMode;
}


/**
 * Check if round has ended
 */
bool IsEndRound(CTrackMania@ app) {
    auto uiState = int(app.CurrentPlayground.GameTerminals[0].UISequence_Current);
    return (
        uiState == int(CGamePlaygroundUIConfig::EUISequence::EndRound)
        || uiState == int(CGamePlaygroundUIConfig::EUISequence::UIInteraction)
        || uiState == int(CGamePlaygroundUIConfig::EUISequence::Podium)
    );
}


/**
 * Check if we are currenly in-game (no loading screens or menu)
 */
bool IsInGame(CTrackMania@ app) {
    return !(
        app.CurrentPlayground is null
        || app.RootMap is null
    );
}
