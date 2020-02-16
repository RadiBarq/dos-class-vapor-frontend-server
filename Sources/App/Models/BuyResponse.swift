import Vapor

/// A single entry of a Todo list.
final class BuyResponse {
    /// Success
    var success: Bool

    /// Create a new `Buy Response`.
    init(success: Bool) {
        self.success = success
    }
}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension BuyResponse: Content { }
