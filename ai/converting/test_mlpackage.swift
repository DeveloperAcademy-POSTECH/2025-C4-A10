import CoreML
import Foundation
import NaturalLanguage

@available(macOS 10.15, *)
class KlueRobertaInference {
    private let model: MLModel
    private let tokenizer: Tokenizer

    // Initialize with the path to the .mlpackage file
    init?(modelPath: String) {
        // Set up tokenizer for text processing
        self.tokenizer = Tokenizer()
        do {
            // Create a URL from the model path
            let modelURL = URL(fileURLWithPath: modelPath)

            // Load the model
            guard let compiledModelURL = try? MLModel.compileModel(at: modelURL) else {
                print("Error compiling model at \(modelPath)")
                return nil
            }

            self.model = try MLModel(contentsOf: compiledModelURL)
            print("Successfully loaded model from \(modelPath)")

            // Print model description
            print("Model inputs: \(model.modelDescription.inputDescriptionsByName)")
            print("Model outputs: \(model.modelDescription.outputDescriptionsByName)")

        } catch {
            print("Error loading model: \(error)")
            return nil
        }
    }

    // Perform inference on input text
    func predict(text: String) -> [String: MLMultiArray]? {
        do {
            let inputFeatures: [String: MLFeatureValue] = try tokenizer.encode(text)

            // Create a feature provider from our input features
            let provider: MLDictionaryFeatureProvider = try MLDictionaryFeatureProvider(
                dictionary: inputFeatures)

            // Perform prediction
            let prediction: any MLFeatureProvider = try model.prediction(from: provider)

            // Process and return the output
            // This assumes your model outputs a dictionary with MLMultiArray values
            var result: [String: MLMultiArray] = [String: MLMultiArray]()
            print("prediction : \(prediction)")

            // Get all output feature names from the model description
            for outputName in model.modelDescription.outputDescriptionsByName.keys {
                if let feature = prediction.featureValue(for: outputName),
                    let multiArray = feature.multiArrayValue
                {
                    result[outputName] = multiArray
                }
            }

            return result

        } catch {
            print("Error during prediction: \(error)")
            return nil
        }
    }

    // Helper method to print the output of the model
    func printPredictionResults(_ results: [String: MLMultiArray]) {
        for (key, value) in results {
            print("\nOutput key: \(key)")
            print("Shape: \(value.shape)")

            // Print the first few values
            print("First few values:")
            let count = min(10, value.count)
            for i in 0..<count {
                // For multi-dimensional arrays, we need to calculate the proper index
                // This is a simplification assuming we're just looking at the first few elements
                if i < value.shape[0].intValue {
                    print("\(i): \(value[[i] as [NSNumber]])")
                }
            }
        }
    }
}

class Tokenizer {
    private let tokenizer: NLTokenizer

    init() {
        self.tokenizer = NLTokenizer(unit: .word)
    }

    func encode(_ text: String) throws -> [String: MLFeatureValue] {
        // Tokenizer
        let inputIds: MLMultiArray = try tokenizeText(text)
        let attentionMask: MLMultiArray = try createAttentionMask(for: text)

        // Create token_type_ids (all zeros for single sentence input)
        let tokenTypeIds: MLMultiArray = try MLMultiArray(shape: [1, 512], dataType: .int32)
        for i in 0..<512 {
            tokenTypeIds[[0, i] as [NSNumber]] = 0
        }

        let inputFeatures: [String: MLFeatureValue] = [
            "input_ids": MLFeatureValue(multiArray: inputIds),
            "attention_mask": MLFeatureValue(multiArray: attentionMask),
            "token_type_ids": MLFeatureValue(multiArray: tokenTypeIds),
        ]

        return inputFeatures
    }
    // Helper method to tokenize text (simplified implementation)
    // Note: This is a placeholder. You should implement proper tokenization based on RoBERTa's requirements
    private func tokenizeText(_ text: String) throws -> MLMultiArray {
        // In a real implementation, you would use a proper RoBERTa tokenizer
        // This is just a placeholder that creates a fixed-size array with dummy values
        do {
            let inputArray = try MLMultiArray(shape: [1, 512], dataType: .int32)

            // Set all values to 0 (padding token)
            for i in 0..<512 {
                inputArray[[0, i] as [NSNumber]] = 0
            }

            // In a real implementation, you would tokenize the text and set the appropriate values
            // For now, we'll just set some dummy values
            inputArray[[0, 0] as [NSNumber]] = 101  // [CLS] token in BERT/RoBERTa

            // Set some dummy token IDs
            tokenizer.string = text
            var index = 1
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                if index < 511 {
                    // In a real implementation, you would convert the token to its ID
                    // For now, we'll just use the character's ASCII value as a dummy ID
                    let token = String(text[tokenRange])
                    let tokenId = NSNumber(value: Int32(token.first?.asciiValue ?? 0))
                    inputArray[[0, index] as [NSNumber]] = tokenId
                    index += 1
                }
                return true
            }

            // Add [SEP] token at the end
            if index < 512 {
                inputArray[[0, index] as [NSNumber]] = 102  // [SEP] token in BERT/RoBERTa
            }

            return inputArray

        } catch {
            print("Error creating input array: \(error)")
            fatalError("Failed to create input array")
        }
    }

    // Create attention mask (1 for tokens, 0 for padding)
    private func createAttentionMask(for text: String) throws -> MLMultiArray {
        do {
            let attentionMask = try MLMultiArray(shape: [1, 512], dataType: .int32)

            // Count tokens (simplified)
            tokenizer.string = text
            var tokenCount = 1  // Start with 1 for [CLS] token
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { _, _ in
                tokenCount += 1
                return true
            }
            tokenCount += 1  // Add 1 for [SEP] token

            // Set attention mask (1 for tokens, 0 for padding)
            let maxLength = min(tokenCount + 2, 512)  // +2 for [CLS] and [SEP]

            for i in 0..<maxLength {
                attentionMask[[0, i] as [NSNumber]] = 1
            }

            for i in maxLength..<512 {
                attentionMask[[0, i] as [NSNumber]] = 0
            }

            return attentionMask

        } catch {
            print("Error creating attention mask: \(error)")
            fatalError("Failed to create attention mask")
        }
    }

}

// Main execution
@available(macOS 10.15, *)
func main() {
    // Path to the model
    let modelPath =
        "/Users/seonjong/workspace/challenge_4/2025-C4-A10/ai/klue_roberta_base.mlpackage"

    // Initialize the inference class
    guard let inference = KlueRobertaInference(modelPath: modelPath) else {
        print("Failed to initialize inference")
        return
    }

    // Sample text for inference
    let sampleText = "이것은 한국어 문장입니다. KLUE RoBERTa 모델로 추론해보겠습니다."

    // Perform inference
    print("\nPerforming inference on text: \(sampleText)")
    if let results = inference.predict(text: sampleText) {
        inference.printPredictionResults(results)
    } else {
        print("Inference failed")
    }
}

// Run the main function if on macOS 10.15 or later
if #available(macOS 10.15, *) {
    main()
} else {
    print("This program requires macOS 10.15 or later")
}

// command : swift ai/converting/test_mlpackage.swift
