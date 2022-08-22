/// A instance for a token
internal class HtmlToken {
    
    /// A enumeration of different kinds of tokens
    internal enum TokenKind {
        
        case starttag
        case endtag
        case character
        case document
        case comment
    }
    
    /// The kind of the token
    internal var kind: TokenKind
    
    /// Creates a token
    internal init(kind: TokenKind) {
        self.kind = kind
    }
}
