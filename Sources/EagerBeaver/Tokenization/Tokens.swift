public class DocumentToken: HtmlToken {
    
    public var name: String?
    
    public var publicId: String?
    
    public var systemId: String?
    
    public init() {
        super.init(kind: .document)
    }
}

public class TagToken: HtmlToken {
    
    public var name: String
    
    public var attributes: [HtmlAttribute]?
    
    public var selfClosing: Bool = false
    
    public init(name: String, kind: TokenKind) {
        
        self.name = name
        super.init(kind: kind)
    }
    
    public func upsert(_ attribute: HtmlAttribute) {
        
        if var attributes = self.attributes {
            
            attributes.append(attribute)
            
            self.attributes = attributes
            
        } else {
            
            self.attributes = [attribute]
        }
    }
}

public class CommentToken: HtmlToken {
    
    public var data: String
    
    public init(data: String) {
        
        self.data = data
        super.init(kind: .comment)
    }
}

public class CharacterToken: HtmlToken {
    
    public var data: String
    
    public init(data: String) {
        
        self.data = data
        super.init(kind: .character)
    }
}
