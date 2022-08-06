public class Tokenizer {
    
    public enum TokenizerError: Error {
        
        case invalidCharacter
        case missingTagName
        
        public var description: String {
            
            switch self {
            case .missingTagName:
                return "Missing tag name."
                
            case .invalidCharacter:
                return "Invalid character."
            }
        }
    }
    
    public enum TokenizerState {
        
        case data
        case starttagopen
        case markup
        case tagname
        case selfclosing
        case endtagopen
        case beforeattributename
        case attributename
        case afterattributename
        case beforeattributevalue
        case attributevalue
        case afterattributevalue
        case comment
        case doctype
    }
    
    public var tokens: [HtmlToken]
    
    private var token: HtmlToken?
    
    private var attribute: HtmlAttribute?
    
    private var state: TokenizerState
    
    public init() {
        
        self.tokens = .init()
        self.state = .data
    }
    
    public init(state: TokenizerState) {
        
        self.tokens = .init()
        self.state = state
    }
    
    public func emit() throws {
        
        print(#function)
        
        if let token = self.token {
            self.tokens.append(token)
        }
        
        self.token = nil
    }
    
    public func emit(_ token: HtmlToken) throws {
        self.tokens.append(token)
    }
    
    public func consume(_ content: String) throws {
        
        print(#function)
        
        for character in content {
            
            switch self.state {
            case .starttagopen:
                self.state = try consumeStartTag(character)
                
            case .markup:
                self.state = try consumeMarkup(character)
                
            case .tagname:
                self.state = try consumeTagName(character)
                
            case .beforeattributename:
                self.state = try consumeBeforeAttributeName(character)
                
            case .attributename:
                self.state = try consumeAttributeName(character)
                
            case .beforeattributevalue:
                self.state = try consumeBeforeAttributeValue(character)
                
            case .attributevalue:
                self.state = try consumeAttributeValue(character)
                
            case .afterattributevalue:
                self.state = try consumeAfterAttributeValue(character)
                
            case .selfclosing:
                self.state = try consumeSelfClosingTag(character)
                
            case .endtagopen:
                self.state = try consumeEndTag(character)
                
            case .comment:
                self.state = try consumeComment(character)
                
            case .doctype:
                self.state = try consumeDoctype(character)
                
            default:
                self.state = try consumeData(character)
            }
        }
    }
    
    private func consumeData(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLessThanSign {
            return .starttagopen
        }
        
        if character.isLetter {
        
            try self.emit(CharacterToken(data: String(character)))
            
            return .data
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeStartTag(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isGreaterThanSign {
            throw TokenizerError.missingTagName
        }
        
        if character.isExclamationMark {
            return .markup
        }
        
        if character.isSolidus {
            return .endtagopen
        }
        
        if character.isLetter {
            
            self.token = TagToken(name: String(character), kind: .starttag)
            
            return .tagname
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeTagName(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isWhitespace || character.isNewline {
            return .beforeattributename
        }
        
        if character.isSolidus {
            return .selfclosing
        }
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
        
        if character.isLetter {
            
            if let token = self.token as? TagToken {
                
                token.name.append(character)
                
                self.token = token
            }
            
            return .tagname
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeEndTag(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isGreaterThanSign {
            throw TokenizerError.missingTagName
        }
        
        if character.isLetter {
            
            self.token = TagToken(name: String(character), kind: .endtag)
            
            return .tagname
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeSelfClosingTag(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isGreaterThanSign {
            return .data
        }
        
        return .selfclosing
    }
    
    private func consumeBeforeAttributeName(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            
            self.attribute = HtmlAttribute(name: String(character), value: "")
            
            return .attributename
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeAttributeName(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            
            if let attribute = self.attribute {
                
                attribute.name.append(character)
                
                self.attribute = attribute
            }
            
            return .attributename
        }
        
        if character.isEqualSign {
            return .beforeattributevalue
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeBeforeAttributeValue(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isApostrophe || character.isDoubleQuote {
            return .attributevalue
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeAttributeValue(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            
            if let attribute = self.attribute {
                
                attribute.value.append(character)
                
                self.attribute = attribute
            }
            
            return .attributevalue
        }
        
        if character.isApostrophe || character.isDoubleQuote {
            
            if let token = self.token as? TagToken {
                
                if let attribute = self.attribute {
                    
                    token.upsert(attribute)
                    
                    self.attribute = nil
                }
                
                self.token = token
            }
            
            return .afterattributevalue
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeAfterAttributeValue(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isSolidus {
            return .selfclosing
        }
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeMarkup(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            return .doctype
        }
        
        if character.isMinus {
            return .comment
        }
        
        throw TokenizerError.invalidCharacter
    }
    
    private func consumeComment(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        return .comment
    }
    
    private func consumeDoctype(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        return .doctype
    }
}
