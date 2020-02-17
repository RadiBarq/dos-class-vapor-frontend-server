import Vapor

/// Buy Response
final class BuyResponse {
    
    /// To indicate if buy operation succeeded or not.
    var success: Bool

    /// Create a new `Buy Response`.
    init(success: Bool) {
        self.success = success
    }
}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension BuyResponse: Content { }
