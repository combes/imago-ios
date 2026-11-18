//
//  ScaledProgressView.swift
//  Imago
//
//  Created by Christopher Combes on 11/18/26.
//

import SwiftUI

struct ScaledProgressView: View {
    var body: some View {
        ProgressView()
            .scaleEffect(2)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
    }
}

#Preview {
    ScaledProgressView()
}
