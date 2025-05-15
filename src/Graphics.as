
// Using a font simlar to in-game stuff
const int TEXT_FONT = nvg::LoadFont("assets/Montserrat-ExtraBold.ttf");
const int LIGHT_FONT = nvg::LoadFont("assets/Montserrat-Medium.ttf");

const vec4 TRANSPARENT_BLACK = vec4(0, 0, 0, 0.75);
const vec4 INGAME_BLUE = vec4(0, 0, 0.941, 0.95);
const vec4 INGAME_RED = vec4(0.941, 0, 0, 0.95);
const vec4 DEFINITELY_WHITE = vec4(1 ,1 , 1, 1);
const vec4 SORTOF_WHITE = vec4(1, 1, 1, 0.5);


/**
 * Draw colored rectangle
 */
void DrawRectangle(float x, float y, float w, float h, vec4 color) {
    nvg::BeginPath();
    nvg::FillColor(color);
    nvg::Rect(x, y, w, h);
    nvg::Fill();
    nvg::ClosePath();
}


/**
 * Draw rectangle with rounded corners in the bottom half
 */
void DrawHalfRoundedRectangle(float x, float y, float w, float h, float rbr, float rbl, vec4 color) {
    nvg::BeginPath();
    nvg::FillColor(color);
    nvg::RoundedRectVarying(x, y, w, h, 0, 0, rbr, rbl);
    nvg::Fill();
    nvg::ClosePath();
}


/**
 * Print text value
 */
void DrawTextBox(const string &in val, float x, float y, float w, float size, vec4 color, bool light = false, int align = nvg::Align::Center | nvg::Align::Top) {
    nvg::FontFace(light ? LIGHT_FONT : TEXT_FONT);
    nvg::FontSize(size);
    nvg::FontBlur(0.0);
    nvg::FillColor(color);
    nvg::TextAlign(align);
    nvg::TextBox(x, y, w, val);
}
