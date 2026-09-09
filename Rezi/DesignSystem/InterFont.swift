import CoreText
import SwiftUI
import UIKit

/// Inter, when it has been bundled — the system font otherwise.
///
/// The design is set in Inter, which iOS does not ship. Rather than requiring
/// the font files to be present for the app to build, everything asks for Inter
/// through here and falls back to SF Pro at the same size and weight. Drop
/// static Inter `.ttf`s into `assets/raw/fonts/`, run `scripts/import-assets.sh`,
/// and the whole screen switches over with no code change.
enum InterFont {

    /// Registers every font bundled with the app. Called once at launch, before
    /// any view body runs, so `installedFaces` sees the fonts.
    static func registerBundledFonts() {
        for ext in ["ttf", "otf"] {
            let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? []
            for url in urls {
                _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }

    /// PostScript names of every installed Inter face.
    ///
    /// Resolved once, lazily — which is after `registerBundledFonts()` has run.
    private static let installedFaces: [String] = {
        UIFont.familyNames
            .filter { family in
                let name = family.lowercased()
                return name == "inter" || name.hasPrefix("inter ") || name.hasPrefix("inter-")
            }
            .flatMap { UIFont.fontNames(forFamilyName: $0) }
    }()

    static var isAvailable: Bool { !installedFaces.isEmpty }

    /// A font in Inter if it is installed, otherwise the system equivalent.
    static func font(size: CGFloat, weight: Font.Weight) -> Font {
        guard let face = faceName(for: weight) else {
            return .system(size: size, weight: weight)
        }
        return .custom(face, fixedSize: size)
    }

    /// Picks the closest installed face, preferring an exact weight match and
    /// walking towards regular when the requested one was not shipped.
    private static func faceName(for weight: Font.Weight) -> String? {
        guard !installedFaces.isEmpty else { return nil }

        for suffix in suffixes(for: weight) {
            let match = installedFaces.first { face in
                face.lowercased().hasSuffix("-" + suffix) || face.lowercased().hasSuffix(suffix)
            }
            if let match { return match }
        }
        return installedFaces.first
    }

    /// Candidate name endings in preference order. Inter ships static faces as
    /// `Inter-Medium`, and its size-specific cuts as `Inter_18pt-Medium`, so
    /// matching on the ending covers both.
    private static func suffixes(for weight: Font.Weight) -> [String] {
        switch weight {
        case .black, .heavy: return ["black", "extrabold", "bold", "semibold", "medium", "regular"]
        case .bold: return ["bold", "semibold", "extrabold", "medium", "regular"]
        case .semibold: return ["semibold", "bold", "medium", "regular"]
        case .medium: return ["medium", "semibold", "regular"]
        case .light, .thin, .ultraLight: return ["light", "regular", "medium"]
        default: return ["regular", "medium"]
        }
    }
}
