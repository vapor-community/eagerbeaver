/// A instance for a token
internal class HtmlToken {}

/// A instance for the document type
internal class DocumentToken: HtmlToken {
    
    /// The public identifier
    internal var publicId: String?
    
    /// The system identifier
    internal var systemId: String?
}

/// A instance for the start and end tag
internal class TagToken: HtmlToken {
    
    /// The different kinds of a tag
    internal enum TagKind {
        
        case starttag
        case endtag
    }
    
    /// The name of the tag
    internal var name: String
    
    /// The kind of the tag
    internal var kind: TagKind
    
    /// Creates a tag token
    internal init(name: String, kind: TagKind) {
        
        self.name = name
        self.kind = kind
    }
}

/// A instance for the comment
internal class CommentToken: HtmlToken {
    
    /// The content of the token
    internal var data: String
    
    /// Creates a comment token
    internal init(data: String) {
        
        self.data = data
    }
}

/// A instance for any other content
internal class TextToken: HtmlToken {
    
    /// The content of the token
    internal var data: String
    
    /// Creates a character token
    internal init(data: String) {
        
        self.data = data
    }
}

/// A instance for any other content
internal class AttributeToken: HtmlToken {
    
    /// The key of the token
    internal var name: String
    
    /// The value of the token
    internal var value: String
    
    /// Creates a character token
    internal init(name: String, value: String) {
        
        self.name = name
        self.value = value
    }
}




