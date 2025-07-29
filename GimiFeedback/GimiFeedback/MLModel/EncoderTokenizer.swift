import CoreML
import Foundation
import Hub
import Tokenizers

class EncoderTokenizer {
    private let tokenizer: Tokenizer
    private var maxLength: Int
    private var padTokenId: Int
    
    init() throws {
        do {
            // MARK: Preview 모드 체크 - 토크나이저 파일이 없으면 nil 반환
            guard
                let tokenizerConfigURL = Bundle.main.url(
                    forResource: "tokenizer_config", withExtension: "json"),
                let tokenizerDataURL = Bundle.main.url(
                    forResource: "tokenizer", withExtension: "json")
            else {
                throw NSError(
                    domain: "TokenizerBundleError",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Tokenizer files not found"]
                )
            }
            
            // MARK: 2. 파일 데이터 로드
            let tokenizerConfigData = try Data(contentsOf: tokenizerConfigURL)
            let tokenizerDataData = try Data(contentsOf: tokenizerDataURL)
            
            // MARK: 3. JSON → Config 객체 디코딩
            let tokenizerConfig = try JSONDecoder().decode(Config.self, from: tokenizerConfigData)
            let tokenizerData = try JSONDecoder().decode(Config.self, from: tokenizerDataData)
            
            // MARK: 4. AutoTokenizer 생성
            self.tokenizer = try AutoTokenizer.from(
                tokenizerConfig: tokenizerConfig,
                tokenizerData: tokenizerData
            )
            
            // MARK: 5. 모델 입력에 [PAD] 토큰을 추가하기 위한 [PAD] 토큰 ID
            let data = try Self.findPadTokenId(from: tokenizerConfig) ?? 1
            self.padTokenId = 1
            
            // MARK: 6. maxLength 추출
            self.maxLength = tokenizerConfig["model_max_length"].integer(or: 512)
        } catch {
            throw NSError(
                domain: "TokenizerInitError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Error initialization: \(error)"]
            )
        }
    }
    
    // MARK: 토크나이저 함수
    func encodePlus(text: String) throws -> [String: MLFeatureValue] {
        do {
            // MARK: 1. text를 [0, 2324, 2, ...]의 token id로 변경
            let inputIds: [Int] = tokenizer.encode(text: text)
            
            // MARK: 2. MLMultiArray를 2D 형태로 생성 (max length로 패딩 진행)
            let inputArray: MLMultiArray = try textToTensor(inputIds: inputIds, maxLengthPadding: true)
            // MARK: 3. InputIds를 AttentionMask로 변환
            let attentionMaskArray: MLMultiArray = try getAttentionMask(inputArray: inputArray)
            // MARK: 4. InputIds를 TokenTypeIds로 변환
            let tokenTypeIdsArray: MLMultiArray = try getTokenTypeIds(inputArray: inputArray)
            
            // MARK: 5. MLFeatureValue로 감싸고 inputFeatures 구성
            let inputFeatures: [String: MLFeatureValue] = [
                "input_ids": MLFeatureValue(multiArray: inputArray),
                "attention_mask": MLFeatureValue(multiArray: attentionMaskArray),
                "token_type_ids": MLFeatureValue(multiArray: tokenTypeIdsArray),
            ]
            
            return inputFeatures
        } catch {
            throw NSError(
                domain: "TokenizingError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Error during tokenizing: \(error)"]
            )
        }
    }
    
    // MARK: Pad Token Id를 꺼내기 위한 함수
    private static func findPadTokenId(from tokenizerConfig: Config) throws -> Int? {
        guard let addedTokens = tokenizerConfig["added_tokens_decoder"].dictionary() else {
            throw NSError(
                domain: "DictionaryError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "added_tokens_decoder는 dictionary 형식이 아닙니다."]
            )
        }
        
        for (key, tokenConfig) in addedTokens {
            if tokenConfig["content"].string() == "[PAD]" {
                let keyString = key.string
                if let keyInt = Int(keyString) {
                    return keyInt
                } else {
                    throw NSError(
                        domain: "IntConversionError",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "'[PAD]' 키를 Int로 변환할 수 없습니다: \(keyString)"]
                    )
                }
            }
        }
        
        throw NSError(
            domain: "KeyNotFoundError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "'[PAD]'에 해당하는 content가 없습니다."]
        )
    }
    
    private func textToTensor(inputIds: [Int], maxLengthPadding: Bool = true) throws -> MLMultiArray {
        var inputArray: MLMultiArray
        if maxLengthPadding {
            inputArray = try MLMultiArray(
                shape: [NSNumber(value: 1), NSNumber(value: maxLength)], dataType: .int32)
        } else {
            inputArray = try MLMultiArray(
                shape: [NSNumber(value: 1), NSNumber(value: inputIds.count)], dataType: .int32)
        }
        
        if maxLengthPadding {
            for idx in 0..<maxLength {
                let indices = [NSNumber(value: 0), NSNumber(value: idx)]  // [batch_idx, seq_idx]
                if idx < inputIds.count {
                    inputArray[indices] = NSNumber(value: inputIds[idx])
                } else {
                    inputArray[indices] = NSNumber(value: padTokenId)  // 패딩 추가
                }
            }
        } else {
            for idx in 0..<inputIds.count {
                let indices = [NSNumber(value: 0), NSNumber(value: idx)]  // [batch_idx, seq_idx]
                inputArray[indices] = NSNumber(value: inputIds[idx])
            }
        }
        
        return inputArray
    }
    
    private func getAttentionMask(inputArray: MLMultiArray) throws -> MLMultiArray {
        let padTokenIdNumber = NSNumber(value: padTokenId)
        let attentionMask = try MLMultiArray(
            shape: [NSNumber(value: 1), NSNumber(value: inputArray.shape[1].intValue)], dataType: .int32)
        
        for idx in 0..<inputArray.shape[1].intValue {
            if inputArray[idx] == padTokenIdNumber {
                attentionMask[idx] = NSNumber(value: 0)  // 패딩
            } else {
                attentionMask[idx] = NSNumber(value: 1)  // 실제 토큰
            }
        }
        
        return attentionMask
    }
    
    private func getTokenTypeIds(inputArray: MLMultiArray) throws -> MLMultiArray {
        let tokenTypeIds = try MLMultiArray(
            shape: [NSNumber(value: 1), NSNumber(value: inputArray.shape[1].intValue)], dataType: .int32)
        
        for idx in 0..<inputArray.shape[1].intValue {
            tokenTypeIds[idx] = NSNumber(value: 0)  // 실제 토큰
        }
        
        return tokenTypeIds
    }
}
