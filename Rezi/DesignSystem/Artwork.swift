import SwiftUI
import UIKit

/// Looks up artwork in the asset catalog and reports whether it is actually
/// there, so every image in this screen can fall back to a drawn version.
///
/// The imagesets are committed empty, so `scripts/import-assets.sh` has
/// somewhere to put files as they arrive. An empty imageset resolves to `nil`
/// here and the SwiftUI fallback is used instead.
///
/// Only ever touched from view bodies, so the lookup cache needs no locking.
enum Artwork {

    enum Name {
        static let background = "OnboardingBackground"
        static let clouds = "Clouds"
        static let phone = "PhoneMockup"
        static let appIcon = "ReziIcon"
        static let companyLogo = "CompanyLogo"

        /// `CompanyLogo1`, `CompanyLogo2`, … drop-in extras for the deck.
        static func companyLogo(_ index: Int) -> String { "CompanyLogo\(index)" }
    }

    private static var cache: [String: Bool] = [:]

    /// True when a real image is present under `name`.
    static func has(_ name: String) -> Bool {
        if let known = cache[name] { return known }
        let image = UIImage(named: name)
        let present = (image?.size.width ?? 0) > 0 && (image?.size.height ?? 0) > 0
        cache[name] = present
        return present
    }

    /// The first of `CompanyLogo1…N` that exists, cycling by index, falling
    /// back to `CompanyLogo` and then to the drawn mark.
    static func companyLogo(preferring index: Int) -> String? {
        let numbered = availableCompanyLogos
        if !numbered.isEmpty {
            return numbered[index % numbered.count]
        }
        return has(Name.companyLogo) ? Name.companyLogo : nil
    }

    private static var cachedCompanyLogos: [String]?

    private static var availableCompanyLogos: [String] {
        if let cached = cachedCompanyLogos { return cached }
        var found: [String] = []
        var i = 1
        while has(Name.companyLogo(i)), i <= 24 {
            found.append(Name.companyLogo(i))
            i += 1
        }
        cachedCompanyLogos = found
        return found
    }
}
