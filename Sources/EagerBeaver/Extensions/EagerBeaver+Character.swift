import Foundation
extension Character {
    
    public var isAmpersand: Bool {
        
        if self == "&" {
            return true
        }
        
        return false
    }
    
    public var isQuestionMark: Bool {
        
        if self == "?" {
            return true
        }
        
        return false
    }
    
    public var isGreaterThanSign: Bool {
        
        if self == ">" {
            return true
        }
        
        return false
    }
    
    public var isLessThanSign: Bool {
        
        if self == "<" {
            return true
        }
        
        return false
    }
    
    public var isSolidus: Bool {
        
        if self == "/" {
            return true
        }
        
        return false
    }
    
    public var isExclamationMark: Bool {
        
        if self == "!" {
            return true
        }
        
        return false
    }
    
    public var isEqualSign: Bool {
        
        if self == "=" {
            return true
        }
        
        return false
    }
    
    public var isApostrophe: Bool {
        
        if self == "'" {
            return true
        }
        
        return false
    }
    
    public var isQuotationMark: Bool {
        
        if self == "\"" {
            return true
        }
        
        return false
    }
    
    public var isHyphenMinus: Bool {
        
        if self == "-" {
            return true
        }
        
        return false
    }
    
    public var isNumberSign: Bool {
        
        if self == "#" {
            return true
        }
        
        return false
    }
}
