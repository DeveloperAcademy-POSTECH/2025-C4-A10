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
//                HStack {
//                    Spacer()
//                    
//                    Button {
//                        action()
//                    } label: {
//                        Image(systemName: "xmark")
//                            .resizable()
//                            .frame(width: 21, height: 24)
//                            .foregroundStyle(.black)
//                            .padding(.top, 20)
//                            .padding(.trailing, 20)
//                    }
//                }
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
    case one, two, three
    
    var id: Int { rawValue }
    
    var image: Image {
        switch self {
        case .one:
            Image(.guideImage1)
        case .two:
            Image(.guideImage2)
        case .three:
            Image(.guideImage3)
        }
    }
}

#Preview {
    FeedbackWriteView.InfoView {
        print("Test")
    }
    .background(Color.gray)
}
