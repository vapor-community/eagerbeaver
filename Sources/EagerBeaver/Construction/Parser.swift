/// The parser for the tree construction
internal class Parser {
    
    /// A enumeration of possible errors
    internal enum ParserError: Error {
        
        case missingBodyTag
        case missingHeadTag
        case missingHtmlTag
        case missingDoctypeTag
        case invalidToken
        case invalidTag
    
        internal var description: String {
            
            switch self {
            case .missingBodyTag:
                return "Missing body tag."
                
            case .missingHeadTag:
                return "Missing head tag."
                
            case .missingHtmlTag:
                return "Missing html tag."
                
            case .missingDoctypeTag:
                return "Missing doctype tag."
                
            case .invalidToken:
                return "Invalid token."
                
            case .invalidTag:
                return "Invalid tag."
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
    
    /// A enumeration of different level of the logging
    ///
    /// None is the initial state.
    internal enum LogLevel {
        
        case none
        case information
        case debug
    }
    
    /// The tree with nodes
    private var tree: [HtmlNode]
    
    /// The collection of nodes
    private var nodes: [ElementNode]
    
    /// The  state of the tokenizer
    private var mode: InsertionMode
    
    /// The level of logging
    private var level: LogLevel
    
    /// Creates a parser
    internal init(mode: InsertionMode = .initial, log level: LogLevel = .none) {
        
        self.tree = []
        self.nodes = []
        self.mode = mode
        self.level = level
    }
    
    /// Logs the steps of the tokenizer depending on the log level
    private func log(_ message: Any...) {
        
        switch self.level {
        case .information:
            print("Message:", message)
            
        default:
            break
        }
    }
    
    /// Inserts the node into the tree
    private func insert(node: HtmlNode) {
        
        self.log(#function)
        
        self.tree.append(node)
    }
    
    /// Pops the last node
    private func pop() {
    
        self.log(#function)
        
        let last = self.nodes.removeLast()
        
        if let penultimate = self.nodes.last {
            penultimate.add(child: last)
            
        } else {
            self.insert(node: last)
        }
    }
    
    /// Processes the content by the mode the parser is currently in
    internal func process(_ tokens: [HtmlToken]) throws -> [HtmlNode] {
        
        self.log(#function)
        
        for token in tokens {
            
            switch self.mode {
            case .beforehtml:
                self.mode = try processBeforeHtml(token)
                
            case .beforehead:
                self.mode = try processBeforeHead(token)
                
            case .inhead:
                self.mode = try processInHead(token)
                
            case .afterhead:
                self.mode = try processAfterHead(token)
                
            case .inbody:
                self.mode = try processInBody(token)
                
            case .text:
                self.mode = try processText(token)
                
            case .afterbody:
                self.mode = try processAfterBody(token)
                
            default:
                self.mode = try processInitial(token)
            }
        }
        
        return self.tree
    }
    
    /// Processes the token
    private func processInitial(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function)
        
        if let document = token as? DocumentToken {
            
            self.insert(node: DefinitionNode(token: document))
            
            return .beforehtml
        }
        
        throw ParserError.invalidToken
    }
    
    /// Processes the token
    private func processBeforeHtml(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function)
        
        if let tag = token as? TagToken {

            if tag.name == "html" {
                
                switch tag.kind {
                case .starttag:
                    self.nodes.append(ElementNode(token: tag))
                    
                case .endtag:
                    throw ParserError.invalidTag
                }
                
            } else {
                throw ParserError.missingHtmlTag
            }
            
            return .beforehead
        }
        
        throw ParserError.invalidToken
    }
    
    /// Processes the token
    private func processBeforeHead(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function)
        
        if let tag = token as? TagToken {
        
            if tag.name == "head" {
                
                switch tag.kind {
                case .starttag:
                    self.nodes.append(ElementNode(token: tag))
                    
                case .endtag:
                    throw ParserError.invalidTag
                }
                
            } else {
               throw ParserError.missingHeadTag
            }
            
            return .inhead
        }
        
        if let attribute = token as? AttributeToken {
            
            if let last = self.nodes.last {
                last.add(attribute: AttributeNode(token: attribute))
            }
            
            return .beforehead
        }
        
        throw ParserError.invalidToken
    }
    
    /// Processes the token
    private func processInHead(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function)
        
        if let comment = token as? CommentToken {
            
            if let last = self.nodes.last {
                last.add(child: CommentNode(token: comment))
            }
            
            return .inhead
        }
        
        if let tag = token as? TagToken {
            
            switch tag.kind {
            case .starttag:
                
                self.nodes.append(ElementNode(token: tag))
                
                if tag.name == "meta" || tag.name == "base" || tag.name == "link" {
                    self.pop()
                }
                
            case .endtag:

                self.pop()
                
                if tag.name == "head" {
                    return .afterhead
                }
            }
            
            return .inhead
        }
        
        if let text = token as? TextToken {
            
            if let last = self.nodes.last {
                last.add(child: TextNode(token: text))
            }
            
            return .inhead
        }
        
        if let attribute = token as? AttributeToken {
            
            if let last = self.nodes.last {
                last.add(attribute: AttributeNode(token: attribute))
            }
            
            return .inhead
        }
        
        throw ParserError.invalidToken
    }
    
    /// Processes the token
    private func processAfterHead(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function)
        
        if let comment = token as? CommentToken {
            
            if let last = self.nodes.last {
                last.add(child: CommentNode(token: comment))
            }
            
            return .afterhead
        }
        
        if let text = token as? TextToken {
            
            if let last = self.nodes.last {
                last.add(child: TextNode(token: text))
            }
            
            return .afterhead
        }
        
        if let tag = token as? TagToken {
            
            if tag.name == "body" {
                
                switch tag.kind {
                case .starttag:
                    self.nodes.append(ElementNode(token: tag))
                    
                case .endtag:
                    throw ParserError.invalidTag
                }
                
            } else {
               throw ParserError.missingBodyTag
            }
            
            return .inbody
        }
        
        if let attribute = token as? AttributeToken {
            
            if let last = self.nodes.last {
                last.add(attribute: AttributeNode(token: attribute))
            }
            
            return .afterhead
        }
        
        throw ParserError.invalidToken
    }
    
    /// Processes the token
    private func processInBody(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function)
        
        if let comment = token as? CommentToken {
            
            if let last = self.nodes.last {
                last.add(child: CommentNode(token: comment))
            }
            
            return .inbody
        }
        
        if let text = token as? TextToken {
            
            if let last = self.nodes.last {
                last.add(child: TextNode(token: text))
            }
            
            return .inbody
        }
        
        if let tag = token as? TagToken {
            
            switch tag.kind {
            case .starttag:
                
                self.nodes.append(ElementNode(token: tag))
                
                if tag.name == "input" || tag.name == "img" || tag.name == "area" || tag.name == "embed" || tag.name == "hr" || tag.name == "wbr" || tag.name == "br"  {
                    self.pop()
                }
                
            case .endtag:

                self.pop()
                
                if tag.name == "body" {
                    return .afterbody
                }
            }
            
            return .inbody
        }
        
        if let attribute = token as? AttributeToken {
            
            if let last = self.nodes.last {
                last.add(attribute: AttributeNode(token: attribute))
            }
            
            return .inbody
        }
        
        throw ParserError.invalidToken
    }
    
    /// Processes the token
    private func processText(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function)
        
        return .text
    }
    
    /// Processes the token
    private func processAfterBody(_ token: HtmlToken) throws -> InsertionMode {
        
        self.log(#function)
        
        if let comment = token as? CommentToken {
            
            if let last = self.nodes.last {
                last.add(child: CommentNode(token: comment))
            }
            
            return .afterbody
        }
        
        if let tag = token as? TagToken {
            
            if tag.name == "html" {
                
                switch tag.kind {
                case .starttag:
                    throw ParserError.invalidTag
                    
                case .endtag:
                    self.pop()
                }
                
            } else {
                throw ParserError.missingHtmlTag
            }
            
            return .afterbody
        }
        
        throw ParserError.invalidToken
    }
}
