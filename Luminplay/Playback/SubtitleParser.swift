import Foundation
import LuminplayCore

enum SubtitleParser {
    static func parse(_ content: String, fileExtension: String? = nil) -> [SubtitleCue] {
        let ext = fileExtension?.lowercased() ?? ""
        switch ext {
        case "vtt", "webvtt":
            return parseWebVTT(content)
        case "ass", "ssa":
            return parseASS(content)
        default:
            return parseSRT(content)
        }
    }

    static func detectFormat(_ content: String) -> String? {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("WEBVTT") { return "vtt" }
        if trimmed.contains("[Script Info]") || trimmed.contains("[V4+ Styles]") { return "ass" }
        if trimmed.contains("-->") { return "srt" }
        return nil
    }

    // MARK: - SRT

    private static func parseSRT(_ content: String) -> [SubtitleCue] {
        var cues: [SubtitleCue] = []
        let normalized = content.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let blocks = normalized.components(separatedBy: "\n\n")

        for block in blocks {
            let lines = block.components(separatedBy: "\n").filter { !$0.isEmpty }
            guard lines.count >= 2 else { continue }

            let timingLine = lines.first { $0.contains("-->") } ?? lines[0]
            guard timingLine.contains("-->") else { continue }

            let times = parseSRTTiming(timingLine)
            guard times.start < times.end else { continue }

            let textLines = lines.drop(while: { !$0.contains("-->") }).dropFirst()
            let text = textLines.joined(separator: "\n")
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !text.isEmpty else { continue }
            cues.append(SubtitleCue(start: times.start, end: times.end, text: text))
        }
        return cues
    }

    private static func parseSRTTiming(_ line: String) -> (start: TimeInterval, end: TimeInterval) {
        let parts = line.components(separatedBy: "-->")
        guard parts.count >= 2 else { return (0, 0) }
        return (
            parseSRTTime(parts[0].trimmingCharacters(in: .whitespaces)),
            parseSRTTime(parts[1].trimmingCharacters(in: .whitespaces))
        )
    }

    private static func parseSRTTime(_ str: String) -> TimeInterval {
        let components = str.components(separatedBy: [":", ","])
        guard components.count >= 4 else { return 0 }
        let h = Double(components[0]) ?? 0
        let m = Double(components[1]) ?? 0
        let s = Double(components[2]) ?? 0
        let ms = Double(components[3]) ?? 0
        return h * 3600 + m * 60 + s + ms / 1000
    }

    // MARK: - WebVTT

    private static func parseWebVTT(_ content: String) -> [SubtitleCue] {
        var cues: [SubtitleCue] = []
        let normalized = content.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let lines = normalized.components(separatedBy: "\n")

        var i = 0
        while i < lines.count {
            let line = lines[i]

            if line.contains("-->") {
                let times = parseVTTTiming(line)
                var textLines: [String] = []
                i += 1
                while i < lines.count && !lines[i].contains("-->") && !lines[i].isEmpty {
                    textLines.append(lines[i])
                    i += 1
                }
                let text = textLines.joined(separator: "\n")
                    .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty, times.start < times.end {
                    cues.append(SubtitleCue(start: times.start, end: times.end, text: text))
                }
            } else {
                i += 1
            }
        }
        return cues
    }

    private static func parseVTTTiming(_ line: String) -> (start: TimeInterval, end: TimeInterval) {
        let parts = line.components(separatedBy: "-->")
        guard parts.count >= 2 else { return (0, 0) }
        return (
            parseVTTTime(parts[0].trimmingCharacters(in: .whitespaces)),
            parseVTTTime(parts[1].trimmingCharacters(in: .whitespaces))
        )
    }

    private static func parseVTTTime(_ str: String) -> TimeInterval {
        let cleaned = str.components(separatedBy: .whitespaces).first ?? str
        let components = cleaned.components(separatedBy: [":", "."])
        guard components.count >= 3 else { return 0 }
        let h = components.count >= 4 ? (Double(components[0]) ?? 0) : 0
        let offset = components.count >= 4 ? 1 : 0
        let m = Double(components[offset]) ?? 0
        let s = Double(components[offset + 1]) ?? 0
        let ms = Double(components[offset + 2]) ?? 0
        return h * 3600 + m * 60 + s + ms / 1000
    }

    // MARK: - ASS/SSA

    private static func parseASS(_ content: String) -> [SubtitleCue] {
        var cues: [SubtitleCue] = []
        let lines = content.components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("Dialogue:") else { continue }

            let parts = splitASSDialogue(trimmed)
            guard parts.count >= 10 else { continue }

            let start = parseASSTime(parts[1])
            let end = parseASSTime(parts[2])
            let text = parts[9...].joined(separator: ",")
                .replacingOccurrences(of: "\\N", with: "\n")
                .replacingOccurrences(of: "\\n", with: "\n")
                .replacingOccurrences(of: "{\\i1}", with: "")
                .replacingOccurrences(of: "{\\i0}", with: "")
                .replacingOccurrences(of: "{\\b1}", with: "")
                .replacingOccurrences(of: "{\\b0}", with: "")
                .replacingOccurrences(of: "{\\u1}", with: "")
                .replacingOccurrences(of: "{\\u0}", with: "")
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
                .trimmingCharacters(in: .whitespaces)

            guard start < end, !text.isEmpty else { continue }
            cues.append(SubtitleCue(start: start, end: end, text: text))
        }
        return cues
    }

    private static func splitASSDialogue(_ line: String) -> [String] {
        let content = line.replacingOccurrences(of: "Dialogue:", with: "")
        var parts: [String] = []
        var current = ""
        var depth = 0
        for char in content {
            if char == "{" { depth += 1 }
            else if char == "}" { depth -= 1 }
            else if char == "," && depth == 0 {
                parts.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
                continue
            }
            current.append(char)
        }
        parts.append(current.trimmingCharacters(in: .whitespaces))
        return parts
    }

    private static func parseASSTime(_ str: String) -> TimeInterval {
        let components = str.components(separatedBy: [":", "."])
        guard components.count >= 3 else { return 0 }
        let h = Double(components[0]) ?? 0
        let m = Double(components[1]) ?? 0
        let s = Double(components[2]) ?? 0
        let cs = components.count >= 4 ? (Double(components[3]) ?? 0) : 0
        return h * 3600 + m * 60 + s + cs / 100
    }
}
