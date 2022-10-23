/// A instance for the document type
internal class DocumentToken: HtmlToken {
    
    /// The name of the tag
    internal var name: String?
    
    /// The public identifier
    internal var publicId: String?
    
    /// The system identifier
    internal var systemId: String?
    
    /// Creates a document token
    internal init() {
        super.init(kind: .document)
    }
}

/// A instance for the start and end tag
internal class TagToken: HtmlToken {
    
    /// The name of the tag
    internal var name: String
    
    /// The attributes of the tag
    internal var attributes: [HtmlAttribute]?
    
    /// Creates a tag token
    internal init(name: String, kind: TokenKind) {
        
        self.name = name
        super.init(kind: kind)
    }
    
    /// Upserts the attribute to the attributes collection
    internal func upsert(_ attribute: HtmlAttribute) {
        
        if var attributes = self.attributes {
            
            attributes.append(attribute)
            
            self.attributes = attributes
            
        } else {
            
            self.attributes = [attribute]
        }
    }
}

/// A instance for the comment
internal class CommentToken: HtmlToken {
    
    /// The content of the token
    internal var data: String
    
    /// Creates a comment token
    internal init(data: String) {
        
        self.data = data
        super.init(kind: .comment)
    }
}

/// A instance for any other content
internal class CharacterToken: HtmlToken {
    
    /// The content of the token
    internal var data: String
    
    /// Creates a character token
    internal init(data: String) {
        
        self.data = data
        super.init(kind: .character)
    }
}

