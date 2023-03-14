//
//  FeaturePoster.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import SwiftUI

struct FeaturePoster {
    let image: Image
    let title: String
    let description: String
}

/// Inspired by https://developer.apple.com/tutorials/swiftui/interfacing-with-uikit
struct FeatureCard: View {
    var poster: FeaturePoster

    var body: some View {
        poster.image
            .resizable()
            .aspectRatio(3 / 2, contentMode: .fit)
            .overlay {
                TextOverlay(title: poster.title, description: poster.description)
            }
    }
}

struct TextOverlay: View {
    var title: String
    var description: String

    var gradient: LinearGradient {
        .linearGradient(
            Gradient(colors: [.black.opacity(0.6), .black.opacity(0)]),
            startPoint: .bottom,
            endPoint: .center)
    }


    var body: some View {
        ZStack(alignment: .bottomLeading) {
            gradient
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title)
                    .bold()
                Text(description)
            }
            .padding()
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    FeatureCard(poster: .init(
        image: Image("Pool"),
        title: "Pool",
        description: "Needs some rennovation"))
}
