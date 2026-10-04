//
//  StatusView.swift
//  Imago
//
//  Created by Christopher Combes on 10/4/26.
//

import SwiftUI

struct StatusView: View {
    let image: String
    let color: Color
    let title: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            Image(systemName: image)
                .font(.system(size: 100))
                .foregroundStyle(color)
            Text(title)
                .font(.largeTitle)
                .padding(2)
                .foregroundStyle(color)
            Spacer()
        }
    }
}

#Preview {
    StatusView(image: "lightbulb.max", color: .yellow, title: "Idea")
}
