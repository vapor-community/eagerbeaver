internal class DocumentNode: HtmlNode {
    
    internal var publicId: String?
    
    internal var systemId: String?
    
    internal init() {
        super.init(kind: .document)
    }
    
    internal init(token: DocumentToken) {
    
        super.init(kind: .document)
        self.name = token.name
        self.publicId = token.publicId
        self.systemId = token.systemId
    }
}

internal class ElementNode: HtmlNode {
    
    internal init() {
        super.init(kind: .element)
    }
    
    internal init(token: TagToken) {
        
        super.init(kind: .element)
        self.name = token.name
    }
}

internal class CommentNode: HtmlNode {
    
    internal var data: String?
    
    internal init() {
        super.init(kind: .comment)
    }
    
    internal init(token: CommentToken) {
        
        super.init(kind: .comment)
        self.data = token.data
    }
    
}
