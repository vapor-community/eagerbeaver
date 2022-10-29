import Foundation

/// A html document
public class HtmlDocument {
    
    /// The document definiton of the document
    public var definition: HtmlDefinition?
    
    /// The root element of the document
    public var root: HtmlElement?
    
    /// Creates a document
    public init(content: String) throws {
        
        let tokens = try Tokenizer().consume(content)
        
        let nodes = try Parser().process(tokens)
        
        for node in nodes {
            
            if let definition = node as? DefinitionNode {
                self.definition = HtmlDefinition(node: definition)
            }
            
            if let element = node as? ElementNode {
                self.add(child: HtmlElement(node: element))
            }
        }
    }
    
    /// Adds a element to the document
    public func add(child: HtmlElement) {
        
        if let root = self.root {
            root.add(child: child)
            
        } else {
            self.root = child
        }
    }
}
