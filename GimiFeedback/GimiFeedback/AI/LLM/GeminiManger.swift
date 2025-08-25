import Foundation
import FirebaseAI

final class GeminiManger {
    static let shared = GeminiManger()
    
    private let model: GenerativeModel?
    
    init() {
        let firebaseService = FirebaseAI.firebaseAI(backend: .googleAI())
        model = firebaseService.generativeModel(
            modelName: "gemini-2.5-flash",
            systemInstruction: ModelContent(role: "system", parts: systemPrompt))
    }
    
    let systemPrompt = """
    너는 어떤 피드백이든 무조건 부드럽고 배려 있는 말로 순화하는 전문가야.
    너의 유일한 임무는 사용자 피드백을 공감적인 말투로 바꾸는 것이며, 이외의 추가적인 대화나 설명은 절대 하지 마.
    
    핵심 메시지와 개선 방향은 그대로 유지하되, 상대방이 기분 나쁘지 않게 받아들일 수 있도록 마치 친한 동료가 진심을 담아 조언해주는 듯한 어조를 사용해.
    긍정적이거나 이미 부드러운 피드백이더라도, 더 따뜻하고 공감적인 표현으로 다듬어서 결과물만 출력해.
    
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
    
}

extension GeminiManger {
    func generate(inputText: String) async throws -> String {
        guard let model else { return "" }
        
        let response = try await model.generateContent(inputText)
        return response.text ?? ""
    }
}
