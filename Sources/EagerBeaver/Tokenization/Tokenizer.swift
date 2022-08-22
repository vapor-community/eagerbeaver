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
    }
    
    /// The collection of the emitted tokens
    private var tokens: [HtmlToken]
    
    /// The temporary token
    private var token: HtmlToken?
    
    /// The temporary attribute
    private var attribute: HtmlAttribute?
    
    /// The  state of the tokenizer
    private var state: TokenizerState
    
    private var rounds: Int = 0
    
    private var temp: String = ""
    
    /// Creates a tokenizer
    internal init(state: TokenizerState = .data) {
        
        self.tokens = .init()
        self.state = state
    }
    
    /// Resets the buffer
    private func reset(rounds: Int) {
        
        self.temp = ""
        self.rounds = rounds
    }
    
    /// Emits the temporary token to the token collection
    private func emit() throws {
        
        print(#function)
        
        if let token = self.token {
            self.tokens.append(token)
        }
        
        self.token = nil
    }
    
    /// Emits a token to the token collection
    ///
    /// - Parameter token: The token
    /// - Throws:
    private func emit(token: HtmlToken) throws {
        
        print(#function)
        
        self.tokens.append(token)
    }
    
    /// Consumes the content by the state the tokenizer is currently in
    ///
    /// - Parameter content: The html string
    /// - Throws:
    internal func consume(_ content: String) throws -> [HtmlToken] {
        
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
                
            default:
                self.state = try consumeData(character)
            }
        }
        
        return self.tokens
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
        
        try self.emit(token: CharacterToken(data: String(character)))
        
        return .data
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
    
    /// Consumes the character of the document type
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeDoctype(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
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
    ///
    /// - Throws:
    private func checkDoctype() throws {
        
        print(#function)
        
        if self.temp.uppercased() != "DOCTYPE" {
            throw TokenizerError.invalidDoctype(self.temp)
        }
    }
    
    /// Consumes the character of the root declaration
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeRootDeclaration(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
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
    ///
    /// - Throws:
    private func checkRootDeclaration() throws {
        
        print(#function)
        
        if self.temp.uppercased() != "HTML" {
            throw TokenizerError.invalidRootDeclaration(self.temp)
        }
    }
    
    /// Consumes the character of the keyword
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeKeyword(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
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
    ///
    /// - Throws:
    private func checkKeyword() throws {
        
        print(#function)
        
        if self.temp.uppercased() != "PUBLIC" {
            throw TokenizerError.invalidKeyword(self.temp)
        }
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
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeAfterPublicIdentifier(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isWhitespace || character.isNewline {
            return .beforesystemidentifier
        }
        
        if character.isGreaterThanSign {
            return .data
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character before the system identifier
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeBeforeSystemIdentifier(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isApostrophe || character.isQuotationMark  {
            return .systemidentifier
        }
        
        throw TokenizerError.invalidCharacter(character)
    }
    
    /// Consumes the character of the system identifier
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeSystemIdentifier(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
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
    ///
    /// - Parameter character: The next input character
    /// - Throws:
    /// - Returns: A new tokenizer state
    private func consumeAfterSystemIdentifier(_ character: Character) throws -> TokenizerState {
        
        print(#function, character)
        
        if character.isGreaterThanSign {
            
            try self.emit()
            
            return .data
        }
    
        throw TokenizerError.invalidCharacter(character)
    }
}

