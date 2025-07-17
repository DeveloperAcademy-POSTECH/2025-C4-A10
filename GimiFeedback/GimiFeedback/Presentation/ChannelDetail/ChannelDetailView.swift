import SwiftUI

struct ChannelDetailView: View {
    
    @StateObject var viewModel: ChannelDetailViewModel
    @EnvironmentObject var router: MainNavigationRouter
    @State private var isShowDeleteAlert: Bool = false
    
    init(channelItem: FeedbackChannel) {
        _viewModel = StateObject(wrappedValue: ChannelDetailViewModel(channelItem: channelItem))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("내가 작성한 설명")
                    
                    Text(viewModel.channelItem.content)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 20))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "pencil")
                        .padding()
                }
                .padding(.horizontal)
                
                Divider()
                
                if viewModel.feedbackList.isEmpty {
                    Text("등록된 피드백이 없습니다.")
                    
                    Button(action: { }) {
                        Text("채널 공유하기")
                    }
                    .buttonStyle(.borderedProminent)
                    
                } else {
                    ForEach(viewModel.feedbackList.sorted(by: { $0.date > $1.date })) { item in
                        LazyVStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading) {
                                Text(item.date.formattedDate)
                                
                                Text("\(item.writePerson)의 피드백")
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 20))
                            .padding(.horizontal)
                        }
                        
                    }
                    
                }
                
            }
            .padding(.top, 32)
        }
        .navigationTitle("\(viewModel.channelItem.channelTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: { }) {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Button(action: { isShowDeleteAlert = true }) {
                    Image(systemName: "trash")
                }
            }
            
        }
        .alert("채널 삭제하기", isPresented: $isShowDeleteAlert) {
            
            Button(action: {
                isShowDeleteAlert = true
            }) {
                Text("취소")
            }
            
            Button(action: {
                viewModel.send(.deleteChannel)
                isShowDeleteAlert = false
                
            }) {
                Text("확인")
            }
            
        } message: {
            Text("정말 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.")
        }
        .onChange(of: viewModel.isDelete) { new in
            if new == true {
                router.pop()
            }
        }
        .onAppear {
            viewModel.send(.fetchFeedbackList)
        }
        
    }
}
