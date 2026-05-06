import Foundation
import SwiftUI

public struct MediaItem: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public let title: String
    public let subtitle: String
    public let overview: String
    public let durationText: String
    public let progress: Double
    public let year: String
    public let genres: [String]
    public let accent: ColorToken
    public let artworkSymbol: String
    public let resolution: String
    public let audio: String
    public let heroBadge: String
    public let contentType: String
    public let rating: String
    public let heroChromeStyle: HeroChromeStyle
    public let heroArtworkStyle: HeroArtworkStyle

    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        overview: String,
        durationText: String,
        progress: Double,
        year: String,
        genres: [String],
        accent: ColorToken,
        artworkSymbol: String,
        resolution: String,
        audio: String,
        heroBadge: String,
        contentType: String,
        rating: String,
        heroChromeStyle: HeroChromeStyle,
        heroArtworkStyle: HeroArtworkStyle
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.overview = overview
        self.durationText = durationText
        self.progress = progress
        self.year = year
        self.genres = genres
        self.accent = accent
        self.artworkSymbol = artworkSymbol
        self.resolution = resolution
        self.audio = audio
        self.heroBadge = heroBadge
        self.contentType = contentType
        self.rating = rating
        self.heroChromeStyle = heroChromeStyle
        self.heroArtworkStyle = heroArtworkStyle
    }
}

public enum ColorToken: String, CaseIterable, Hashable, Sendable, Codable {
    case ember
    case cobalt
    case emerald
    case rose
    case amber

    public var gradient: LinearGradient {
        switch self {
        case .ember:
            LinearGradient(colors: [Color(red: 0.96, green: 0.42, blue: 0.22), Color(red: 0.34, green: 0.09, blue: 0.07)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cobalt:
            LinearGradient(colors: [Color(red: 0.22, green: 0.63, blue: 0.96), Color(red: 0.04, green: 0.14, blue: 0.34)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .emerald:
            LinearGradient(colors: [Color(red: 0.22, green: 0.84, blue: 0.64), Color(red: 0.02, green: 0.24, blue: 0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rose:
            LinearGradient(colors: [Color(red: 0.91, green: 0.36, blue: 0.51), Color(red: 0.25, green: 0.06, blue: 0.17)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .amber:
            LinearGradient(colors: [Color(red: 0.97, green: 0.71, blue: 0.29), Color(red: 0.27, green: 0.16, blue: 0.03)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    public var tint: Color {
        switch self {
        case .ember: Color(red: 0.98, green: 0.52, blue: 0.30)
        case .cobalt: Color(red: 0.38, green: 0.71, blue: 0.99)
        case .emerald: Color(red: 0.34, green: 0.88, blue: 0.68)
        case .rose: Color(red: 0.96, green: 0.52, blue: 0.66)
        case .amber: Color(red: 0.99, green: 0.77, blue: 0.38)
        }
    }
}
