import Foundation

actor Serializer {
    func encode<T: Encodable>(_ entity: T) async throws -> Data {
        try JSONEncoder().encode(entity)
    }

    func decode<T: Decodable>(_ data: Data) async throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }
}
