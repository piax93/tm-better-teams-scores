/**
 * Class implementing UI tracking teams scores
 */

const vec4 TRANSPARENT_BLACK = vec4(0, 0, 0, 0.75);
const vec4 INGAME_BLUE = vec4(0, 0, 0.941, 0.95);
const vec4 INGAME_RED = vec4(0.941, 0, 0, 0.95);
const vec4 DEFINITELY_WHITE = vec4(1 ,1 , 1, 1);
const vec4 SORTOF_WHITE = vec4(1, 1, 1, 0.5);

const float PADDING = 6;
const float RECT_ROUNDING = 8;
const float X_SIZE = 380;
const float Y_SIZE = 120;
const uint MAX_NAME_LEN = 11;


enum TeamColor {
    BLUE = 0,
    RED = 1,
    NONE = 2,
}


class TeamScoreboard {

    private array<uint> scores;
    private array<string> names;
    private TeamColor winning;

    TeamScoreboard(const string &in blueName, const string &in redName) {
        this.names.Resize(2);
        this.scores.Resize(2);
        this.winning = TeamColor::NONE;
        this.setName(TeamColor::BLUE, blueName);
        this.setName(TeamColor::RED, redName);
        this.reset();
    }

    TeamScoreboard() {
        TeamScoreboard("", "");
    }

    void reset() {
        this.scores[TeamColor::BLUE] = 0;
        this.scores[TeamColor::RED] = 0;
    }

    void setWinning(const TeamColor color) {
        this.winning = color;
    }

    void setName(const TeamColor color, const string &in name) {
        this.names[color] = name.ToUpper().SubStr(0, MAX_NAME_LEN);
    }

    void setScore(const TeamColor color, uint score) {
        this.scores[color] = score;
    }

    void draw() {
        // we scale stuff targetting X_SIZExY_SIZE on 1080p window
        int wWidth = Draw::GetWidth();
        float scaling = uiScaling * Draw::GetHeight() / 1080.0;
        vec2 size = vec2(X_SIZE * scaling, Y_SIZE * scaling);
        vec2 colorSize = vec2(size.x / 2 - PADDING, size.y - PADDING);
        float xpos = (wWidth - size.x) / 2;
        nvg::Reset();
        // background
        DrawHalfRoundedRectangle(xpos, 0, size.x, size.y, RECT_ROUNDING, RECT_ROUNDING, TRANSPARENT_BLACK);
        // winning indicator
        if (this.winning != TeamColor::NONE) {
            DrawHalfRoundedRectangle(
                this.winning == TeamColor::BLUE ? xpos : wWidth / 2,
                0,
                size.x / 2,
                size.y,
                this.winning == TeamColor::BLUE ? 0 : RECT_ROUNDING,
                this.winning == TeamColor::BLUE ? RECT_ROUNDING : 0,
                SORTOF_WHITE
            );
        }
        // blue side
        float blueXpos = xpos + PADDING;
        DrawHalfRoundedRectangle(blueXpos, 0, colorSize.x, colorSize.y, 0, RECT_ROUNDING, INGAME_BLUE);
        // red side
        float redXpos = wWidth / 2;
        DrawHalfRoundedRectangle(redXpos, 0, colorSize.x, colorSize.y, RECT_ROUNDING, 0, INGAME_RED);
        // write scores
        float scoreTextSize = 78 * scaling;
        DrawTextBox(Text::Format("%d", this.scores[TeamColor::BLUE]), blueXpos, 35 * scaling, colorSize.x, scoreTextSize, DEFINITELY_WHITE);
        DrawTextBox(Text::Format("%d", this.scores[TeamColor::RED]), redXpos, 35 * scaling, colorSize.x, scoreTextSize, DEFINITELY_WHITE);
        // write team name if set
        float teamTextSize = 20 * scaling;
        if (this.names[TeamColor::BLUE] != "") {
            DrawTextBox(this.names[TeamColor::BLUE], blueXpos, 5, colorSize.x, teamTextSize, DEFINITELY_WHITE);
        }
        if (this.names[TeamColor::RED] != "") {
            DrawTextBox(this.names[TeamColor::RED], redXpos, 5, colorSize.x, teamTextSize, DEFINITELY_WHITE);
        }
    }

}
