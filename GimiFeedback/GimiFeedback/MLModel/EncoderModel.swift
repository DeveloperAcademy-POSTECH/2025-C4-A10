//
//  ContentView.swift
//  MyModelTest
//
//  Created by seonjong on 7/22/25.
//

import CoreML
import Foundation

public class SequenceClassifier {
    private let model: MLModel
    private let tokenizer: EncoderTokenizer

    public init?(modelNameOrPath: String) async throws {
        do {
            // MARK: 토크나이저 초기화
            guard let tokenizer = try await EncoderTokenizer() else {
                throw NSError(
                    domain: "TokenizerInitError",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to initialize tokenizer"]
                )
            }
            self.tokenizer = tokenizer
            print("✅ Successfully initialized tokenizer")

            // MARK: 모델 초기화 from .mlmodelc bundle
            guard let bundleModelURL = Bundle.main.url(
                forResource: modelNameOrPath, withExtension: "mlmodelc")
            else {
                throw NSError(
                    domain: "ModelNotFoundError",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Model not found in mlmodelc bundle"]
                )
            }
            self.model = try MLModel(contentsOf: bundleModelURL)
            print("✅ Successfully initialized model")
            print("Model inputs: \(model.modelDescription.inputDescriptionsByName)")
            print("Model outputs: \(model.modelDescription.outputDescriptionsByName)")
        } catch {
            throw NSError(
                domain: "ModelInitError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Error initialization: \(error)"]
            )
        }
    }

    // MARK: 실제 모델을 추론하는 함수
    public func predict(text: String) -> MLFeatureProvider? {
        do {
            // MARK: 1. text를 token id로 변경
            let inputFeatures: [String: MLFeatureValue] = try self.tokenizer.encode_plus(text: text)

            // MARK: 2. input features에서 feature provider를 생성
            let provider: MLDictionaryFeatureProvider = try MLDictionaryFeatureProvider(
                dictionary: inputFeatures)
            // MARK: 3. =========== model 추론 ==============
            let prediction: MLFeatureProvider = try model.prediction(from: provider)
            
            return prediction
        } catch {
            print("❌ Prediction error: \(error)")
            return nil
        }
    }
}
