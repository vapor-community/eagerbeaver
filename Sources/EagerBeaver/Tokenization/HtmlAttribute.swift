/// A instance for an attribute
internal class HtmlAttribute {
    
    /// The name of the attribute
    internal var name: String
    
    /// The value of the attribute
    internal var value: String
    
    /// Creats a attribute
    internal init(name: String, value: String) {
        
        self.name = name
        self.value = value
    }
}
