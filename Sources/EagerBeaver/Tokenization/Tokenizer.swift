/// A tokenizer
internal class Tokenizer {
    
    /// A enumeration of possible errors
    internal enum TokenizerError: Error {
        
        case invalidCharacter(Character)
        case invalidDoctype(String)
        case invalidRootDeclaration(String)
        case invalidKeyword(String)
        case missingRootDeclaration
        case missingTagName
        case missingCommentDash
        case missingPublicIdentifier
        case missingSystemIdentifier
        case missingWhitespace
        case emptyComment
        
        internal var description: String {
            
            switch self {
            case .emptyComment:
                return "Empty comment."
                
            case .missingWhitespace:
                return "Missing whitespace."
                
            case .missingSystemIdentifier:
                return "Missing system identifier."
                
            case .missingPublicIdentifier:
                return "Missing public identifier."
                
            case .missingCommentDash:
                return "Missing dash."
                
            case .missingTagName:
                return "Missing tag name."
                
            case .missingRootDeclaration:
                return "Missing root declaration."
                
            case .invalidKeyword(let string):
                return "Invalid keyword \(string)."
                
            case .invalidRootDeclaration(let string):
                return "Invalid root declaration \(string)."
                
            case .invalidDoctype(let string):
                return "Invalid doctype \(string)."
                
            case .invalidCharacter(let character):
                return "Invalid character \(character)."
            }
        }
    }
    
    /// A enumeration of different states of the tokenizer
    ///
    /// Data is the initial state.
    internal enum TokenizerState {
        
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
        case doctype
        case rootdeclaration
        case keyword
        case beforepublicidentifier
        case publicidentifier
        case afterpublicidentifier
        case beforesystemidentifier
        case systemidentifier
        case aftersystemidentifier
        case text
    }
    
    /// A enumeration of different level of the logging
    ///
    /// None is the initial state.
    internal enum LogLevel {
        
        case none
        case information
        case debug
    }
    
    /// The collection of the emitted tokens
    private var tokens: [HtmlToken]
    
    /// The temporary token
    private var token: HtmlToken?
    
    /// The  state of the tokenizer
    private var state: TokenizerState
    
    /// The level of logging
    private var level: LogLevel
    
    /// The position of the tokenizer
    private var position: Int
    
    private var rounds: Int = 0
    
    private var temp: String = ""
    
    /// Creates a tokenizer
    internal init(state: TokenizerState = .data, log level: LogLevel = .none) {
        
        self.tokens = []
        self.state = state
        self.level = level
        self.position = 0
    }
    
    /// Logs the steps of the tokenizer depending on the log level
    private func log(_ message: Any...) {
        
        switch self.level {
        case .information:
            print("Message:", message)
            
        case .debug:
            print("Position:", self.position, "Message:", message)
            
        default:
            break
        }
    }
    
    /// Resets the buffer
    private func reset(rounds: Int) {
        
        self.temp = ""
        self.rounds = rounds
    }
    
    /// Emits the temporary token to the token collection
    private func emit() throws {
        
        self.log(#function)
        
        if let token = self.token {
            self.tokens.append(token)
        }
        
        self.token = nil
    }
    
    /// Emits a token to the token collection
    private func emit(token: HtmlToken) throws {
        
        self.log(#function)
        
        self.tokens.append(token)
    }
    
    /// Consumes the content by the state the tokenizer is currently in
    internal func consume(_ content: String) throws -> [HtmlToken] {
        
        self.log(#function)
        
        for (index, character) in content.enumerated() {
            
            self.position = index
            
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
                self.state = try consumeDoctype(character)
                
            case .rootdeclaration:
                self.state = try consumeRootDeclaration(character)
              
            case .keyword:
                self.state = try consumeKeyword(character)
                
            case .beforepublicidentifier:
                self.state = try consumeBeforePublicIdentifier(character)
                
            case .publicidentifier:
                self.state = try consumePublicIdentifier(character)
                
            case .afterpublicidentifier:
                self.state = try consumeAfterPublicIdentifier(character)
                
            case .beforesystemidentifier:
                self.state = try consumeBeforeSystemIdentifier(character)
                
            case .systemidentifier:
                self.state = try consumeSystemIdentifier(character)
                
            case .aftersystemidentifier:
                self.state = try consumeAfterSystemIdentifier(character)
                
            case .text:
                self.state = try consumeText(character)
                
            default:
                self.state = try consumeData(character)
            }
        }
        
        return self.tokens
    }
    
    /// Consumes the character
    private func consumeData(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isLessThanSign {
            return .starttag
        }
        
        return .data
    }
    
    /// Consumes the character of the start tag
    private func consumeStartTag(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
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
    private func consumeTagName(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isWhitespace || character.isNewline {
            
            try self.emit()
            
            return .beforeattributename
        }
        
        if character.isSolidus {
            return .selfclosing
        }
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .text
        }
        
        if character.isLetter || character.isNumber {
            
            if let token = self.token as? TagToken {
                
                token.name.append(character)
                
                self.token = token
            }
            
            return .tagname
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the end tag
    private func consumeEndTag(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
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
    private func consumeSelfClosingTag(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
        
        return .selfclosing
    }
    
    /// Consumes the character before the attribute name
    private func consumeBeforeAttributeName(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isLetter {
            
            self.token = AttributeToken(name: String(character), value: "")
            
            return .attributename
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the attribute name
    private func consumeAttributeName(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isLetter {
            
            if let token = self.token as? AttributeToken {
                
                token.name.append(character)
                
                self.token = token
            }
            
            return .attributename
        }
        
        if character.isEqualSign {
            return .beforeattributevalue
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character before the attribute value
    private func consumeBeforeAttributeValue(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isApostrophe || character.isQuotationMark {
            return .attributevalue
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the attribute value
    private func consumeAttributeValue(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isLetter {
            
            if let token = self.token as? AttributeToken {
                
                token.value.append(character)
                
                self.token = token
            }
            
            return .attributevalue
        }
        
        if character.isApostrophe || character.isQuotationMark {
            
            try self.emit()
            
            return .afterattributevalue
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character after attribute value
    private func consumeAfterAttributeValue(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isSolidus {
            return .selfclosing
        }
        
        if character.isGreaterThanSign {
            return .data
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the markup
    private func consumeMarkup(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isLetter {
            
            self.reset(rounds: 7)
            
            self.token = DocumentToken()
            
            return try consumeDoctype(character)
        }
        
        if character.isHyphenMinus {
            
            self.token = CommentToken(data: "")
            
            return .commentstart
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character before the comment
    private func consumeCommentStart(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isHyphenMinus {
            return .commentstartdash
        }
        
        if character.isGreaterThanSign {
            throw TokenizerError.emptyComment
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the comment dash
    private func consumeCommentStartDash(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
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
    private func consumeComment(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
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
    private func consumeCommentEndDash(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isHyphenMinus {
            return .commentend
        }
        
        if character.isLetter {
            return try consumeComment(character)
        }
        
        throw TokenizerError.missingCommentDash
    }
    
    /// Consumes the character after the comment
    private func consumeCommentEnd(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the document type
    private func consumeDoctype(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isGreaterThanSign {
            throw TokenizerError.missingRootDeclaration
        }
        
        if character.isLetter {
            
            if self.rounds > 0 {
                
                self.temp.append(character)
                
                self.rounds = rounds - 1
                
                return .doctype
            }
            
            throw TokenizerError.missingWhitespace
        }
        
        if character.isWhitespace || character.isNewline {
            
            try checkDoctype()
            
            self.reset(rounds: 4)
            
            return .rootdeclaration
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Checks the document type
    private func checkDoctype() throws {
        
        self.log(#function)
        
        if self.temp.uppercased() != "DOCTYPE" {
            throw TokenizerError.invalidDoctype(self.temp)
        }
    }
    
    /// Consumes the character of the root declaration
    private func consumeRootDeclaration(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
        
        if character.isLetter {
            
            if self.rounds > 0 {
                
                self.temp.append(character)
                
                self.rounds = rounds - 1
                
                return .rootdeclaration
            }
            
            throw TokenizerError.missingWhitespace
        }
        
        if character.isWhitespace || character.isNewline {
            
            try checkRootDeclaration()
            
            self.reset(rounds: 6)
            
            return .keyword
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Checks the root declaration
    private func checkRootDeclaration() throws {
        
        self.log(#function)
        
        if self.temp.uppercased() != "HTML" {
            throw TokenizerError.invalidRootDeclaration(self.temp)
        }
    }
    
    /// Consumes the character of the keyword
    private func consumeKeyword(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isGreaterThanSign {
            throw TokenizerError.missingPublicIdentifier
        }
        
        if character.isLetter {
            
            if self.rounds > 0 {
                
                self.temp.append(character)
                
                self.rounds = rounds - 1
                
                return .keyword
            }
            
            throw TokenizerError.missingWhitespace
        }
        
        if character.isWhitespace || character.isNewline {
            
            try checkKeyword()
            
            self.reset(rounds: 0)
            
            return .beforepublicidentifier
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Checks the keyword
    private func checkKeyword() throws {
        
        self.log(#function)
        
        if self.temp.uppercased() != "PUBLIC" {
            throw TokenizerError.invalidKeyword(self.temp)
        }
    }
    
    /// Consumes the character before the public identifier
    private func consumeBeforePublicIdentifier(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isApostrophe || character.isQuotationMark  {
            return .publicidentifier
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the public identifier
    private func consumePublicIdentifier(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isApostrophe || character.isQuotationMark  {
            return .afterpublicidentifier
        }
        
        if let token = self.token as? DocumentToken {
            
            if var publicId = token.publicId {
                
                publicId.append(character)
                
                token.publicId = publicId
                
            } else {
                token.publicId = String(character)
            }
            
            self.token = token
        }
        
        return .publicidentifier
    }
    
    /// Consumes the character after the public identifier
    private func consumeAfterPublicIdentifier(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isWhitespace || character.isNewline {
            return .beforesystemidentifier
        }
        
        if character.isGreaterThanSign {
            return .data
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character before the system identifier
    private func consumeBeforeSystemIdentifier(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isApostrophe || character.isQuotationMark  {
            return .systemidentifier
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the system identifier
    private func consumeSystemIdentifier(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isApostrophe || character.isQuotationMark  {
            return .aftersystemidentifier
        }
    
        if let token = self.token as? DocumentToken {
            
            if var systemId = token.systemId {
                
                systemId.append(character)
                
                token.systemId = systemId
                
            } else {
                token.systemId = String(character)
            }
            
            self.token = token
        }
        
        return .systemidentifier
    }
    
    /// Consumes the character after the system identifier
    private func consumeAfterSystemIdentifier(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
    
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character when its text
    private func consumeText(_ character: Character) throws -> TokenizerState {
        
        self.log(#function, character)
        
        if character.isLessThanSign {
            
            try self.emit()
            
            return .starttag
        }
        
        if character.isASCII {
            
            if let token = self.token as? TextToken {
                
                token.data.append(character)
                
                self.token = token
                
            } else {
                self.token = TextToken(data: String(character))
            }
            
            return .text
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
}

