//
//  FeedbackWriteViewModel.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/16/25.
//

import SwiftUI
import Foundation
import CoreML

final class FeedbackWriteViewModel: ViewModelable {
    enum Action {
        case feedbackWrite
        case clearError
    }
    
    enum FeedbackWriteState {
        case writing
        case loading
        case success
    }

    @Published var status: FeedbackWriteState = .writing
    @Published private(set) var errorMessage: String?
    
    @Published var continues: [String] = [""]
    @Published var stops: [String] = [""]
    
    let minimumFeedbackLength: Int = 10
    var sequenceClassifier: SequenceClassifier?
    let modelNameOrPath: String = "KcELECTRA-base-v2022"
    
    let feedbackChannel: FeedbackChannel
    let nickName: String
    private(set) var createdFeedback: Feedback?
    
    var canCreate: Bool {
        let isValidContinue = continues.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= minimumFeedbackLength
        }
        let isValidStop = stops.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= minimumFeedbackLength
        }
        return isValidContinue || isValidStop
    }
    
    init(feedbackChannel: FeedbackChannel, nickName: String) {
        self.feedbackChannel = feedbackChannel
        self.nickName = nickName
        do {
            self.sequenceClassifier = try SequenceClassifier(modelNameOrPath: modelNameOrPath)
        } catch {
            print("Failed to initialize SequenceClassifier: \(error)")
            self.sequenceClassifier = nil
        }
    }
    
    func send(_ action: Action) {
        switch action {
        case .feedbackWrite:
            Task {
                status = .loading
                
                let feedbackContents = createContent()
                
                print("생성된 피드백 콘텐츠:", feedbackContents)
                
                let createdFeedback = Feedback(
                    feedbackChannelID: feedbackChannel.id,
                    readPerson: feedbackChannel.userID,
                    writePerson: nickName,
                    content: feedbackContents
                )
                
                await saveFeedbackToFirestore(to: createdFeedback)
                
                FCMManager.shared.sendNotification(
                    to: feedbackChannel.userID,
                    from: nickName,
                    title: feedbackChannel.channelTitle,
                    feedbackId: createdFeedback.id.uuidString
                )
                
                status = .success
            }
        case .clearError:
            status = .writing
        }
    }
    
    private func createContent() -> [FeedbackContent] {
        var result: [FeedbackContent] = []
        
        let continueFeedbackTexts = continues
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let continueSpicyLevels = getSpicyLevel(feedbackTexts: continueFeedbackTexts)
        result += continueFeedbackTexts.enumerated().map { index, text in
            FeedbackContent(content: text, spicy: continueSpicyLevels[index], type: .typeContinue)
        }
        
        let stopFeedbackTexts = stops
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let stopSpicyLevels = getSpicyLevel(feedbackTexts: stopFeedbackTexts)
        result += stopFeedbackTexts.enumerated().map { index, text in
            FeedbackContent(content: text, spicy: stopSpicyLevels[index], type: .typeStop)
        }
        
        return result
    }

    private func getSpicyLevel(feedbackTexts: [String]) -> [Int] {
        var spicyLevels: [Int] = []
        
        for feedbackText in feedbackTexts {
            // 문장 단위로 분리
            let sentences = splitParagraphIntoSentences(feedbackText)
            
            // 문장별로 AI 모델로 spicy level 추출
            var maxSpicyLevel = -1
            for sentence in sentences {
                let spicyLevel = predict(inputText: sentence)
                maxSpicyLevel = max(maxSpicyLevel, spicyLevel)
            }
            spicyLevels.append(maxSpicyLevel)
        }
        
        return spicyLevels
    }
    
    private func saveFeedbackToFirestore(to feedback: Feedback) async {
        do {
            let saveFeedback = try await FirestoreManager.shared.create(feedback)
            
            createdFeedback = saveFeedback
        } catch {
            print("생성을 실패했습니다 \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - 모델 추론
    /// 1. 텍스트 전처리(preprocess)
    /// 2. 실제 모델 추론(predict)
    /// 2. 모델 결과물 후처리(postprocess)
    private func predict(inputText: String) -> Int {
        let preprocessedText = preprocess(text: inputText)
        let prediction: MLFeatureProvider? = sequenceClassifier?.predict(text: preprocessedText)
        let postprocessedResult: Int = postprocess(prediction: prediction)

        return postprocessedResult
    }

    private func preprocess(text: String) -> String {
        let preprocessedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return preprocessedText
    }

    private func postprocess(prediction: MLFeatureProvider?) -> Int {
        guard let int64Value = prediction?.featureValue(for: "classLabel")?.int64Value else {
            print("❌ classLabel 값을 가져올 수 없습니다")
            errorMessage = "classLabel 값을 가져올 수 없습니다"
            return -1
        }
        
        let classLabelValue = Int(int64Value)

        return classLabelValue
    }
    
    // MARK: - 문단을 문장 단위로 정확히 분리하고 문장부호까지 복원하는 유틸리티
    /// 입력된 문단 문자열을 '.', '!', '?' 등 문장부호 기준으로 분리
    /// 각 문장의 문장부호를 원문에서 복원하여 완전한 문장 리스트를 반환
    private func splitParagraphIntoSentences(_ paragraph: String) -> [String] {
        var sentences: [String] = []
        let splitSentences = splitParagraphWithSeparator(paragraph)

        var currentPos = 0
        for sentence in splitSentences {
            let (restored, nextPos) = restoreSeparator(in: paragraph, from: currentPos, sentence: sentence)
            sentences.append(restored)
            currentPos = nextPos
        }
        return sentences
    }

    private func splitParagraphWithSeparator(_ paragraph: String) -> [String] {
        // 문장 끝 부호 정의
        let sentenceEndingPunctuation: Set<Character> = [".", "!", "?"]

        // 문장과 문장부호를 분리하여 추출
        var splitSentences: [String] = []
        var currentSentence = ""
        for char in paragraph {
            if sentenceEndingPunctuation.contains(char) {
                let trimmedSentence = currentSentence.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedSentence.isEmpty {
                    splitSentences.append(trimmedSentence)
                    currentSentence = ""
                }
            } else {
                currentSentence.append(char)
            }
        }
        
        // 마지막 문장 처리 (문장부호가 없는 경우)
        let finalSentence = currentSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        if !finalSentence.isEmpty {
            splitSentences.append(finalSentence)
        }
        
        guard !splitSentences.isEmpty else { return [] }
        
        return splitSentences
    }

    private func restoreSeparator(in paragraph: String, from position: Int, sentence: String) -> (String, Int) {
        // 문장 끝 문장부호 정의
        let sentenceEndingPunctuation: Set<Character> = [".", "!", "?"]
        
        // 각 문장 뒤의 정확한 문장부호 패턴을 분석하여 복원
        guard let range = paragraph.range(
            of: sentence,
            range: paragraph.index(paragraph.startIndex, offsetBy: position)..<paragraph.endIndex
        ) else {
            return (sentence + ".", position)
        }

        let sentenceEnd = paragraph.distance(from: paragraph.startIndex, to: range.upperBound)
        var punctuationPattern = ""
        var checkPos = sentenceEnd

        // 문장 뒤의 연속된 문장부호들을 수집
        while checkPos < paragraph.count {
            let char = paragraph[paragraph.index(paragraph.startIndex, offsetBy: checkPos)]
            if sentenceEndingPunctuation.contains(char) {
                punctuationPattern.append(char)
                checkPos += 1
            } else if char.isWhitespace {
                checkPos += 1
            } else {
                break
            }
        }

        // 문장부호가 없으면 기본값으로 마침표 추가
        if punctuationPattern.isEmpty {
            punctuationPattern = "."
        }

        let sentenceWithPunctuation = sentence + punctuationPattern
        return (sentenceWithPunctuation, checkPos)
    }
}
