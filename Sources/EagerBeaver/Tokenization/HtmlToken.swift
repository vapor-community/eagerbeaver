public class HtmlToken {
    
    public enum TokenKind {
        
        case starttag
        case endtag
        case character
        case document
        case comment
    }
    
    public var kind: TokenKind
    
    public init(kind: TokenKind) {
        
        self.kind = kind
    }
}
