import XCTest
@testable import EagerBeaver

final class TokenizerTests: XCTestCase {
    
    // Tests consuming a start tag
    func testStartTag() throws {
        
        // ...in its correct form
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<html>"))
        
        // ...when it is self-closing
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<html/>"))
        
        // ...when the tag name contains a number
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<html/>"))
        
        // ...when it contains an invalid character
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<?html>"))
        
        // ...when the tag name is missing
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<>"))
    }
    
    // Tests consuming a end tag
    func testEndTag() throws {
        
        // ...in its correct form
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("</html>"))
        
        // ...when the tag name is missing
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("</>"))
    }
    
    // Tests consuming a doctype
    func testDocumentType() throws {
        
        // ...with html 5 specification
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<!DOCTYPE html>"))
        
        // ...with html 4 strict specification
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">"))
        
        // ...with html 4 transitional specification
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">"))
        
        // ...with html 4 frameset specification
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\">"))
        
        // ...when there is no whitespace between the doctype and the root declaration
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!DOCTYPEHTML PUBLIC>"))
        
        // ...when there is no whitespace between the root declaration and the keyword
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!DOCTYPE HTMLPUBLIC>"))
        
        // ...when the public identifier is missing
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!DOCTYPE HTML PUBLIC>"))
        
        // ...when the root declaration is missing
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!DOCTYPE>"))
        
        // ...when the doctype is incorrect
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!DOCYPE html>"))
        
        // ...when the root element is incorrect
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!DOCTYPE HML PBLIC>"))
        
        // ...when the keyword is incorrect
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!DOCTYPE HTML PBLIC>"))
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!DOCTYPE HTML STEM>"))

    }
    
    // Tests consuming a comment
    func testComment() throws {
        
        // ...in its correct form
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<!--Comment-->"))
        
        // ...with spaces before and after
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<!-- Comment -->"))
        
        // ...with spaces inbetween
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<!--Comment comment-->"))
        
        // ...with hyphen minus in between
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<!--Comment-comment-->"))
        
        // ...when it has no content
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!-->"))
        
        // ...when a dash is missing
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!-Comment-->"))
        XCTAssertThrowsError(try Tokenizer(log: .information).consume("<!-- Comment ->"))
    }

    // Tests consuming a attribute
    func testAttribute() throws {
        
        // ...with single quotation mark
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<html name='value'>"))
        
        // ...with single quotation mark and no value
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<html name=''>"))
        
        // ...with double quotation mark
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<html name=\"value\">"))
        
        // ...with double quotation mark and no value
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<html name=\"\">"))
    }
    
    // Tests consuming a whole element
    func testElement() throws {
        
        // ...with content
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<title>content</tile>"))
        
        // ...with content seperated by a whitespace
        XCTAssertNoThrow(try Tokenizer(log: .information).consume("<title>content content</title>"))
    }
}
