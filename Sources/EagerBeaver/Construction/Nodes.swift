internal class HtmlNode {}

internal class DefinitionNode: HtmlNode {
    
    internal var publicId: String?
    
    internal var systemId: String?
    
    internal convenience init(token: DocumentToken) {
    
        self.init()
        self.publicId = token.publicId
        self.systemId = token.systemId
    }
}

internal class ElementNode: HtmlNode {
    
    internal var name: String
    
    internal var attributes: [AttributeNode]?
    
    internal var children: [HtmlNode]?
    
    internal init(name: String) {
        
        self.name = name
    }
    
    internal convenience init(token: TagToken) {
        
        self.init(name: token.name)
    }
    
    internal func add(child: HtmlNode) {
        
        if var children = self.children {
            
            children.append(child)
            
            self.children = children
            
        } else {
            self.children = [child]
        }
    }
    
    internal func add(attribute: AttributeNode) {
        
        if var attributes = attributes {
            
            attributes.append(attribute)
            
            self.attributes = attributes
            
        } else {
            self.attributes = [attribute]
        }
    }
}

internal class CommentNode: HtmlNode {
    
    internal var data: String?
    
    internal convenience init(token: CommentToken) {
        
        self.init()
        self.data = token.data
    }
}

internal class TextNode: HtmlNode {
    
    internal var data: String?
    
    internal convenience init(token: TextToken) {
    
        self.init()
        self.data = token.data
    }
    
}

internal class AttributeNode: HtmlNode {
    
    internal var name: String
    
    internal var value: String?
    
    internal init(name: String) {
        
        self.name = name
    }
    
    internal convenience init(token: AttributeToken) {
        
        self.init(name: token.name)
        self.value = token.value
    }
}
