//
//  FeedbackListView.swift
//  A10
//
//  Created by 김민석 on 7/8/25.
//

import SwiftUI

struct FeedbackListView: View {
    @StateObject var viewModel: FeedbackListViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: FeedbackListViewModel())
    }
    
    var body: some View {
    }
}

#Preview {
    FeedbackListView()
}
