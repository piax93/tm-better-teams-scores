
// Using a font simlar to in-game stuff
const int TEXT_FONT = nvg::LoadFont("assets/Montserrat-ExtraBold.ttf");

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
void DrawTextBox(const string &in val, float x, float y, float w, float size, vec4 color) {
    nvg::FontFace(TEXT_FONT);
    nvg::FontSize(size);
    nvg::FontBlur(0.0);
    nvg::FillColor(color);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Top);
    nvg::TextBox(x, y, w, val);
}
