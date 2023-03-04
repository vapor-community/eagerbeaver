/// A document definition
public class HtmlDefinition {
    
    /// The public identifier of the document
    public var publicId: String?
    
    /// The system identifier of the document
    public var systemId: String?
    
    /// Creates a definition
    public init() {}
    
    /// Maps a definition node
    internal convenience init(node: DefinitionNode) {
        
        self.init()
        self.publicId = node.publicId
        self.systemId = node.systemId
    }
    
    internal func render() -> String {
        
        if let publicId = self.publicId, let systemId = self.systemId {
            return "<!DOCTYPE HTML PUBLIC \"\(publicId)\" \"\(systemId)\">"
        }
        
        return "<!DOCTYPE html>"
    }
}
