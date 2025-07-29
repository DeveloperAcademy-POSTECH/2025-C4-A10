//
//  GPTManger.swift
//  GimiFeedback
//
//  Created by 승찬 on 7/28/25.
//

import Foundation

final class GPTManger {
    static let shared = GPTManger()
    
    private init() {}
    
    let sytemPrompt = """
    너는 공감 능력이 뛰어난 피드백 조정 전문가야.
    
    사용자가 작성한 피드백이 너무 직설적이거나 감정적으로 상처를 줄 수 있는 경우,
    그 표현을 부드럽고 배려 있게 순화해줘. 
    핵심 메시지와 개선 방향은 그대로 유지하되, 
    상대방이 기분 나쁘지 않게 받아들일 수 있도록 공감적인 말투로 바꿔줘.  
    마치 친한 동료가 진심을 담아 조언해주는 듯한 어조를 사용해.
    
    아래는 예시야:
    
    <예시>
      <입력 예시>회의 시간에 집중 좀 해. 계속 딴짓해서 짜증나.</입력 예시>
      <출력 예시>회의에 더 집중해주면 좋겠어요. 가끔 딴짓하는 모습이 보여서 회의 흐름이 조금 끊기는 느낌이 있었어요.</출력 예시>
    </예시>
    
    <예시>
      <입력 예시>일을 너무 느리게 해. 같이 일하기 힘들어.</입력 예시>
      <출력 예시>업무 속도가 조금 더 빨라지면 협업이 훨씬 원활할 것 같아요. 지금도 충분히 잘하고 있지만, 약간만 더 신경 써주면 좋겠어요.</출력 예시>
    </예시>
    
    <예시>
      <입력 예시>말이 너무 많고 눈치가 없어서 분위기 망치고 있어.</입력 예시>
      <출력 예시>이야기를 적극적으로 해주는 건 좋지만, 상황에 맞게 조절해주면 더 좋은 분위기가 될 수 있을 것 같아요.</출력 예시>
    </예시>
    
    위와 같이, 표현은 순화하지만 피드백의 본질은 흐리지 않도록 해줘.
    """
    
    func sendChatCompletion(inputText: String) async throws -> String {
        /// API키와 URL 설정
        let apiKey = Bundle.gptApiKey
        
        guard let url =  URL(string: "https://api.openai.com/v1/chat/completions") else { return "" }
        
        var result = ""
        
        /// HTTP 요청 헤더 설정
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /// 메시지 구성
        /// system 메시지는 GPT의 말투나 성격 설정용
        /// user는 실제 질문
        let messages = [
            ChatMessage(role: "system", content: sytemPrompt),
            ChatMessage(
                role: "user", content: inputText),
        ]
        
        /// 요청 본문 인코딩
        /// ChatRequest 구조를 JSON으로 인코딩해서 HTTP Body에 넣어줌
        let body = ChatRequest(
            model: "gpt-4o",
            messages: messages,
            temperature: 0.0,
            top_p: 1.0
        )
        let encodedBody = try JSONEncoder().encode(body)
        request.httpBody = encodedBody
        
        /// 데이터를 요청하고 응답을 받음
        let (data, _) = try await URLSession.shared.data(for: request)
        
        /// 응답 디코딩
        /// 응답 받은 JSON을 디코딩해서, 첫 번째 choice의 메시지 출력
        let decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        if let response = decoded.choices.first?.message.content {
            print("💬 GPT-4o Response:\n\(response)")
            result = response
        }
        
        return result
        
    }
}

extension GPTManger {
    
    /// 요청용 메시지
    struct ChatMessage: Codable {
        let role: String // user, system
        let content: String
    }

    /// 요청 내용
    struct ChatRequest: Codable {
        let model: String // 사용할 모델 이름 (ex: gpt-4o)
        let messages: [ChatMessage] // 대화 내용 (role, content 배열)
        let temperature: Double
        let top_p: Double
    }

    /// 응답 메시지 (GPT가 생성한 메시지)
    struct ChatResponse: Codable {
        let role: String
        let content: String
    }

    /// 응답의 선택지 중 하나
    struct Choice: Codable {
        let message: ChatResponse
    }

    /// 전체 응답 구조
    struct ChatCompletionResponse: Codable {
        let choices: [Choice]
    }
}
