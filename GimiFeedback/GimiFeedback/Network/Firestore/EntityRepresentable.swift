//
//  EntityRepresentable.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/9/25.
//

/// entityName: 데이터 이름이 무엇인지 설정
/// documentID: 해당 데이터의 고유 ID(UUID 등) -> get을 위함, 식별자 용도
/// asDictionary: 데이터를 받아오거나 보내줄때 딕셔너리로 변경해서 보내줘야함
protocol EntityRepresentable {
    var entityName: CollectionType { get }
    var documentID: String { get }
    var asDictionary: [String: Any]? { get }
}
