/// A instance for an attribute
public class HtmlAttribute {
    
    /// The name of the attribute
    public var name: String
    
    /// The value of the attribute
    public var value: String?
    
    /// Creates a attribute
    public init(name: String) {
        
        self.name = name
    }
    
    /// Maps a attribute node
    internal convenience init(node: AttributeNode) {
        
        self.init(name: node.name)
        self.value = value
    }
}
