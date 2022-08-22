/// The parser for the tree construction
internal class Parser {
    
    /// A enumeration of possible errors
    internal enum ParserError: Error {
        
        case error
        
        internal var description: String {
            
            switch self {
            case .error:
                return "Error."
            }
        }
    }
   
    /// A enumeration of different states of the parser
    internal enum InsertionMode {
        
        case initial
        case beforehtml
        case beforehead
        case inhead
        case afterhead
        case inbody
        case text
        case afterbody
    }
    
    /// The type of the documents content
    private var type: DocumentNode?
    
    /// The collection of nodes
    private var nodes: [HtmlNode]
    
    /// The  state of the tokenizer
    private var mode: InsertionMode
    
    /// Creates a parser
    private init() {
        
        self.nodes = .init()
        self.mode = .initial
    }
    
    /// Access the parser
    internal static let shared = Parser()
    
    /// Inserts the node into the nodes collection
    private func insert(node: HtmlNode) {
        
        print(#function)
        
        self.nodes.append(node)
    }
    
    /// Normalizes the content before processing
    private func normalize(_ content: String) -> String {
        
        print(#function)
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Processes the content by the mode the parser is currently in
    ///
    /// - Parameter content: The html string
    /// - Throws:
    internal func process(_ content: String) throws {
        
        print(#function)
        
        let tokens = try Tokenizer().consume(normalize(content))
        
        if !tokens.isEmpty {
            
            for token in tokens {
                
                switch self.mode {
                case .beforehtml:
                    break
                    
                case .beforehead:
                    break
                    
                case .inhead:
                    break
                    
                case .afterhead:
                    break
                    
                case .inbody:
                    break
                    
                case .text:
                    break
                    
                case .afterbody:
                    break
                    
                default:
                    self.mode = try processInitial(token)
                }
            }
        }
    }
    
    
    /// Processes the token
    ///
    /// - Parameter token: The next token
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func processInitial(_ token: HtmlToken) throws -> InsertionMode {
        
        print(#function, token.kind)
        
        switch token.kind {
            
        case .character:
            return .initial
            
        case .comment:
            return .initial
            
        case .document:
            return .initial
            
        default:
            return .initial
        }
    }
}
