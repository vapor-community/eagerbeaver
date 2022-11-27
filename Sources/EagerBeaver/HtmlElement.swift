/// A html element
public class HtmlElement {
    
    /// The different kind of elements
    public enum ElementKind {
        
        case text
        case comment
        case element
    }
    
    /// The name of the element
    public var name: String?
    
    /// The name of the element
    public var value: String?
    
    /// The element attributes
    public var attributes: [HtmlAttribute]?
    
    /// The kind of the element
    public var kind: ElementKind
    
    /// The content of the element
    public var children: [HtmlElement]?
    
    /// Creates a element
    public init(kind: ElementKind) {
        self.kind = kind
    }
    
    /// Maps a element node
    internal convenience init(node: ElementNode) {
        
        self.init(kind: .element)
        self.name = node.name
        
        if let children = node.children {
            
            for child in children {
                
                if let comment = child as? CommentNode {
                    self.add(child: HtmlElement(node: comment))
                }
                
                if let element = child as? ElementNode {
                    self.add(child: HtmlElement(node: element))
                }
                
                if let text = child as? TextNode {
                    self.add(child: HtmlElement(node: text))
                }
            }
        }
        
        if let attributes = node.attributes {
            
            for attribute in attributes {
                self.add(attribute: HtmlAttribute(node: attribute))
            }
        }
    }
    
    /// Maps a comment node
    internal convenience init(node: CommentNode) {
        
        self.init(kind: .comment)
        self.value = node.data
    }
    
    /// Maps a text node
    internal convenience init(node: TextNode) {
        
        self.init(kind: .text)
        self.value = node.data
    }
    
    /// Adds content to the element
    internal func add(child: HtmlElement) {
        
        if var children = children {
            
            children.append(child)
            
            self.children = children
            
        } else {
            self.children = [child]
        }
    }
    
    /// Adds content to the element
    internal func add(attribute: HtmlAttribute) {
        
        if var attributes = attributes {
            
            attributes.append(attribute)
            
            self.attributes = attributes
            
        } else {
            self.attributes = [attribute]
        }
    }
    
    internal func render() -> String {
        
        var output = ""
        
        switch kind {
        case .comment:
            output += "<!--\(value ?? "")-->"
            
        case .element:
            
            output += "<\(name ?? "")"
            
            if let attributes = attributes {
                
                for attribute in attributes {
                    output += attribute.render()
                }
            }
            
            output += ">"
            
            if let children = children {
                
                for child in children {
                    output += child.render()
                }
            }
            
            output += "</\(name ?? "")>"
            
        case .text:
            output += "\(value ?? "")"
        }
        
        return output
    }
}
