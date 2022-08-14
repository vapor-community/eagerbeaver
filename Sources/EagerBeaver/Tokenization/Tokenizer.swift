public class Tokenizer {
    
    /// The collection of  possible errors
    public enum TokenizerError: Error {
        
        case noRootDeclaration(String)
        case noKeyword(String)
        case noDoctype(String)
        case invalidCharacter(Character)
        case missingTagName
        case missingCommentDash
        case emptyComment
        
        public var description: String {
            
            switch self {
            case .emptyComment:
                return "Empty comment."
                
            case .missingCommentDash:
                return "Missing dash."
                
            case .noRootDeclaration(let string):
                return "No correct root declaration \(string)."
                
            case .noKeyword(let string):
                return "No correct keyword \(string)."
                
            case .noDoctype(let string):
                return "No correct doctype \(string)."
                
            case .missingTagName:
                return "Missing tag name."
                
            case .invalidCharacter(let character):
                return "Invalid character \(character)."
            }
        }
    }
    
    /// The collection of different states of the tokenizer
    ///
    /// Data is the initial state.
    public enum TokenizerState {
        
        case data
        case starttag
        case markup
        case tagname
        case selfclosing
        case endtag
        case beforeattributename
        case attributename
        case afterattributename
        case beforeattributevalue
        case attributevalue
        case afterattributevalue
        case commentstart
        case commentstartdash
        case comment
        case commentenddash
        case commentend
        case beforedoctype
        case doctype
        case afterdoctype
        case beforerootdeclaration
        case rootdeclaration
        case afterrootdeclaration
        case beforekeyword
        case keyword
        case afterkeyword
        case beforepublicidentifier
        case publicidentifier
        case afterpublicidentifier
        case beforeurireference
        case urireference
        case afterurireference
    }
    
    /// The collection of the emitted tokens
    public var tokens: [HtmlToken]
    
    /// The temporary token
    private var token: HtmlToken?
    
    /// The temporary attribute
    private var attribute: HtmlAttribute?
    
    /// The  state of the tokenizer
    private var state: TokenizerState
    
    private var rounds: Int = 0
    
    private var temp: String = ""
    
    /// Creates a tokenizer
    public init() {
        
        self.tokens = .init()
        self.state = .data
    }
    
    /// Creates a tokenizer with a specific state
    public init(state: TokenizerState) {
        
        self.tokens = .init()
        self.state = state
    }
    
    /// Emits the temporary token to the token collection
    public func emit() throws {
        
        print(#function)
        
        if let token = self.token {
            self.tokens.append(token)
        }
        
        self.token = nil
    }
    
    /// Emits a token to the token collection
    public func emit(_ token: HtmlToken) throws {
        
        print(#function)
        
        self.tokens.append(token)
    }
    
    /// Consumes the content by the state of the tokenizer
    ///
    ///
    public func consume(_ content: String) throws {
        
        print(#function)
        
        for character in content {
            
            switch self.state {
            case .starttag:
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
                
            case .endtag:
                self.state = try consumeEndTag(character)
                
            case .commentstart:
                self.state = try consumeCommentStart(character)
                
            case .commentstartdash:
                self.state = try consumeCommentStartDash(character)
                
            case .comment:
                self.state = try consumeComment(character)
                
            case .commentenddash:
                self.state = try consumeCommentEndDash(character)
                
            case .commentend:
                self.state = try consumeCommentEnd(character)
                
            case .doctype:
                
                if self.rounds > 0 {
                    self.state = try bufferDoctype(character)
                    
                } else {
                    self.state = try consumeDoctype(self.temp)
                }
                
            case .rootdeclaration:
                
                if self.rounds > 0 {
                    self.state = try bufferRootDeclaration(character)
                    
                } else {
                    self.state = try consumeRootDeclaration(self.temp)
                }
              
            case .keyword:
                
                if self.rounds > 0 {
                    self.state = try bufferKeyword(character)
                    
                } else {
                    self.state = try consumeKeyword(self.temp)
                }
                
            case .beforepublicidentifier:
                self.state = try consumeBeforePublicIdentifier(character)
                
            case .publicidentifier:
                self.state = try consumePublicIdentifier(character)
                
            case .afterpublicidentifier:
                self.state = try consumeAfterPublicIdentifier(character)
                
            case .beforeurireference:
                self.state = try consumeBeforeUriReference(character)
                
            case .urireference:
                self.state = try consumeUriReference(character)
                
            case .afterurireference:
                self.state = try consumeAfterUriReference(character)
                
            default:
                self.state = try consumeData(character)
            }
        }
    }
    
    /// Consumes the character
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeData(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLessThanSign {
            return .starttag
        }
        
        if character.isLetter {
        
            try self.emit(CharacterToken(data: String(character)))
            
            return .data
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the start tag
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeStartTag(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isGreaterThanSign {
            throw TokenizerError.missingTagName
        }
        
        if character.isExclamationMark {
            return .markup
        }
        
        if character.isSolidus {
            return .endtag
        }
        
        if character.isLetter {
            
            self.token = TagToken(name: String(character), kind: .starttag)
            
            return .tagname
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the tag name
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
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
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the end tag
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeEndTag(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isGreaterThanSign {
            throw TokenizerError.missingTagName
        }
        
        if character.isLetter {
            
            self.token = TagToken(name: String(character), kind: .endtag)
            
            return .tagname
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the self closing tag.
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeSelfClosingTag(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
        
        return .selfclosing
    }
    
    /// Consumes the character before the attribute name
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeBeforeAttributeName(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            
            self.attribute = HtmlAttribute(name: String(character), value: "")
            
            return .attributename
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the attribute name
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
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
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character before the attribute value
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeBeforeAttributeValue(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isApostrophe || character.isQuotationMark {
            return .attributevalue
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the attribute value
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeAttributeValue(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            
            if let attribute = self.attribute {
                
                attribute.value.append(character)
                
                self.attribute = attribute
            }
            
            return .attributevalue
        }
        
        if character.isApostrophe || character.isQuotationMark {
            
            if let token = self.token as? TagToken {
                
                if let attribute = self.attribute {
                    
                    token.upsert(attribute)
                    
                    self.attribute = nil
                }
                
                self.token = token
            }
            
            return .afterattributevalue
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character after attribute value
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeAfterAttributeValue(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isSolidus {
            return .selfclosing
        }
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the markup
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeMarkup(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            
            self.rounds = 7
            
            self.token = DocumentToken()
            
            return try bufferDoctype(character)
        }
        
        if character.isHyphenMinus {
            
            self.token = CommentToken(data: "")
            
            return .commentstart
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character before the comment
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeCommentStart(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isHyphenMinus {
            return .commentstartdash
        }
        
        if character.isGreaterThanSign {
            throw TokenizerError.emptyComment
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the comment dash
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeCommentStartDash(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isWhitespace || character.isNewline {
            return .comment
        }
        
        if character.isHyphenMinus {
            return .commentend
        }
        
        if character.isLetter {
            return try consumeComment(character)
        }
        
        if character.isGreaterThanSign {
            throw TokenizerError.emptyComment
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the comment
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeComment(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isHyphenMinus {
            return .commentenddash
        }
        
        if let token = self.token as? CommentToken {
            
            token.data.append(character)
            
            self.token = token
        }
        
        return .comment
    }
    
    /// Consumes the comment dash
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeCommentEndDash(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isHyphenMinus {
            return .commentend
        }
        
        if character.isLetter {
            return try consumeComment(character)
        }
        
        throw TokenizerError.missingCommentDash
    }
    
    /// Consumes the character after the comment
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeCommentEnd(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Buffers the character of the document type
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func bufferDoctype(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            
            self.temp.append(character)
            
            self.rounds = rounds - 1
            
            return .doctype
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the document type
    ///
    /// - Parameter string: The doctype
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeDoctype(_ string: String) throws -> TokenizerState {
        
        print(#function, string)
        
        if string.uppercased() == "DOCTYPE" {
            
            self.temp = ""
            self.rounds = 4
            
            return .rootdeclaration
        }
        
        throw TokenizerError.noDoctype(string)
    }
    
    /// Buffers the character of the root declaration
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func bufferRootDeclaration(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            
            self.temp.append(character)
            
            self.rounds = rounds - 1
            
            return .rootdeclaration
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the root declaration
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeRootDeclaration(_ string: String) throws -> TokenizerState {
        
        print(#function, string)
        
        if string.uppercased() == "HTML" {
            
            self.temp = ""
            self.rounds = 6
            
            return .keyword
        }
        
        throw TokenizerError.noRootDeclaration(string)
    }
    
    /// Buffers the character of the keyword
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func bufferKeyword(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isLetter {
            
            self.temp.append(character)
            
            self.rounds = rounds - 1
            
            return .keyword
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the keyword
    ///
    /// - Parameter string: The keyword
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeKeyword(_ string: String) throws -> TokenizerState {
        
        print(#function, string)
        
        if string.uppercased() == "SYSTEM" {
            
            if let token = self.token as? DocumentToken {
                
                token.name = string
                
                self.token = token
            }
            
            self.temp = ""
            self.rounds = 0
            
            return .beforepublicidentifier
        }
        
        if string.uppercased() == "PUBLIC" {
            
            if let token = self.token as? DocumentToken {
                
                token.name = string
                
                self.token = token
            }
            
            self.temp = ""
            self.rounds = 0
            
            return .beforepublicidentifier
        }
        
        throw TokenizerError.noKeyword(string)
    }
    
    /// Consumes the character before the public identifier
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeBeforePublicIdentifier(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isApostrophe || character.isQuotationMark  {
            return .publicidentifier
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the public identifier
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumePublicIdentifier(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isApostrophe || character.isQuotationMark  {
            return .afterpublicidentifier
        }
        
        if let token = self.token as? DocumentToken {
            
            token.publicId?.append(character)
            
            self.token = token
        }
        
        return .publicidentifier
    }
    
    /// Consumes the character after the public identifier
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeAfterPublicIdentifier(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isWhitespace || character.isNewline {
            return .beforeurireference
        }
        
        if character.isGreaterThanSign {
            return .data
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character before the uri reference
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeBeforeUriReference(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isApostrophe || character.isQuotationMark  {
            return .urireference
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the uri reference
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeUriReference(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isApostrophe || character.isQuotationMark  {
            return .afterurireference
        }
    
        if let token = self.token as? DocumentToken {
            
            token.systemId?.append(character)
            
            self.token = token
        }
        
        return .urireference
    }
    
    /// Consumes the character after the uri reference
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeAfterUriReference(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
    
        throw TokenizerError.invalidCharacter(character)
    }
}
