internal class HtmlNode {
    
    internal enum NodeKind {
        
        case text
        case element
        case comment
        case attribute
        case document
    }
    
    internal var name: String?
    
    internal var value: String?
    
    internal var kind: NodeKind
    
    internal var parent: HtmlNode?
    
    internal var children: [HtmlNode]?
    
    internal init(kind: NodeKind) {
        self.kind = kind
    }
}
