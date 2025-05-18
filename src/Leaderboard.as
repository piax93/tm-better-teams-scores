/**
 * Class implementing UI tracking player positions
 */

namespace Leaderboard {

const uint MAX_PLAYERS = 16;
const uint MAX_NAME_SIZE = 14;
const float Y_SIZE = 28;
const float X_SIZE = 270;
const float TEXT_SIZE = 18;
const float TEXT_PADDING = 6;

class PlayerLeaderboard {

    private uint size;
    private array<string> names;
    private array<TeamColor> colors;
    private array<int> times;

    PlayerLeaderboard() {
        this.size = 0;
        this.names.Resize(MAX_PLAYERS);
        this.colors.Resize(MAX_PLAYERS);
        this.times.Resize(MAX_PLAYERS);
    }

    void setSize(uint size) {
        this.size = size;
    }

    void setPosition(uint pos, const string &in name, TeamColor color, int time) {
        if (pos >= this.size || pos >= this.names.Length) return;
        this.names[pos] = name;
        this.colors[pos] = color;
        this.times[pos] = time;
    }

    void draw() {
        int wHeight = Draw::GetHeight();
        float scaling = leaderboardScaling * wHeight / 1080.0;
        float xSize = scaling * X_SIZE;
        float ySize = scaling * Y_SIZE;
        float yPos = scaling * leaderboardYPosition;
        float fontSize = scaling * TEXT_SIZE;
        float padding = scaling * TEXT_PADDING;
        nvg::Reset();
        for (uint i = 0; i < this.size; i++) {
            float gap = Math::Abs(this.times[i] - this.times[0]) / 1000.0;
            float currYPos = yPos + i * ySize;
            vec4 color = this.colors[i] == TeamColor::BLUE ? INGAME_BLUE : INGAME_RED;
            DrawRectangle(0, currYPos, xSize, ySize, color);
            DrawTextBox(
                this.names[i].SubStr(0, MAX_NAME_SIZE),
                padding,
                currYPos + padding,
                xSize,
                fontSize,
                DEFINITELY_WHITE,
                false,
                nvg::Align::Left | nvg::Align::Top
            );
            DrawTextBox(
                Text::Format("+%.3f", gap),
                0,
                currYPos + padding,
                xSize - padding,
                fontSize,
                DEFINITELY_WHITE,
                true,
                nvg::Align::Right | nvg::Align::Top
            );
        }
    }

}

}
