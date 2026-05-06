//
//  GlassSupport.swift
//  Luminplay
//
//  Created by Codex on 2026/4/26.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func luminplayGlassCard(
        tint: Color? = nil,
        cornerRadius: CGFloat = 24,
        interactive: Bool = false
    ) -> some View {
        glassCardBody(tint: tint, cornerRadius: cornerRadius, interactive: interactive)
    }

    @ViewBuilder
    private func glassCardBody(
        tint: Color?,
        cornerRadius: CGFloat,
        interactive: Bool
    ) -> some View {
#if os(visionOS) || os(tvOS) || os(watchOS)
        fallbackGlassCard(cornerRadius: cornerRadius)
#else
        if #available(iOS 26, macOS 26, *) {
            glassEffect(
                interactive ? .regular.tint(tint).interactive() : .regular.tint(tint),
                in: .rect(cornerRadius: cornerRadius)
            )
        } else {
            fallbackGlassCard(cornerRadius: cornerRadius)
        }
#endif
    }

    private func fallbackGlassCard(cornerRadius: CGFloat) -> some View {
        background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
            }
    }
}

public struct LuminplayBackdrop: View {
    public let accent: ColorToken

    public init(accent: ColorToken) {
        self.accent = accent
    }

    public var body: some View {
        ZStack {
            Color.black

            Rectangle()
                .fill(accent.gradient)
                .blur(radius: 100)
                .scaleEffect(1.2)
                .opacity(0.95)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.55),
                    Color.black.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}
