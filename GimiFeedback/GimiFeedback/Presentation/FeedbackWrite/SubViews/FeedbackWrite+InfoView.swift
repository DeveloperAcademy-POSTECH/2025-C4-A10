//
//  FeedbackWrite+InfoView.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/28/25.
//

import SwiftUI

extension FeedbackWriteView {
    struct InfoView: View {
        @State private var selectedTab: InfoEums = .one
        let action: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    ForEach(InfoEums.allCases) { item in
                        item.image
                            .resizable()
                            .scaledToFit()
                            .tag(item)
                    }
                    .frame(maxHeight: 600)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))  
            }
        }
    }
}

enum InfoEums: Int, CaseIterable, Identifiable {
    case one, two
    
    var id: Int { rawValue }
    
    var image: Image {
        switch self {
        case .one:
            Image(.guideImage1)
        case .two:
            Image(.guideImage2)
        }
    }
}

#Preview {
    FeedbackWriteView.InfoView {
        print("Test")
    }
    .background(Color.gray)
}
