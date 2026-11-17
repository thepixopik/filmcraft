//! The AllCraft wordmark painted directly via egui primitives (crisp at any DPI, no embedded trademark PNGs).

use egui::{Align2, Color32, Rect, pos2, vec2};

use crate::theme::Tokens;

/// Retained for API compatibility; painting uses vector primitives in [`paint_wordmark`].
pub fn wordmark(_ctx: &egui::Context, _dark: bool) -> Option<egui::TextureHandle> {
    None
}

/// Draw the "The AllCraft" badge and wordmark `height` points tall with its left edge at `left_center`.
pub fn paint_wordmark(ui: &egui::Ui, left_center: egui::Pos2, height: f32, dark: bool) -> Option<egui::Rect> {
    let p = ui.painter();
    let badge_sz = height.max(14.0);
    let badge = Rect::from_min_size(pos2(left_center.x, left_center.y - badge_sz / 2.0), vec2(badge_sz, badge_sz));
    p.rect_filled(badge, badge_sz * 0.24, Color32::from_rgb(155, 93, 229));
    p.text(badge.center(), Align2::CENTER_CENTER, "A", Tokens::semibold(badge_sz * 0.68), Color32::WHITE);

    let fg = if dark { Color32::from_rgb(242, 242, 245) } else { Color32::from_rgb(24, 24, 28) };
    let text_pos = pos2(badge.max.x + 6.0, left_center.y);
    let text_rect = p.text(text_pos, Align2::LEFT_CENTER, "The AllCraft", Tokens::semibold(height.max(13.0)), fg);
    Some(badge.union(text_rect))
}
