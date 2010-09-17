
{-| The Bourne shell escaper, made available for reference purposes. This is
    an internal module; it's interface is unstable. 
 -}

module Text.ShellEscape.Sh where

import Data.ByteString (ByteString)

import Text.ShellEscape.Escape
import qualified Text.ShellEscape.Put as Put
import Text.ShellEscape.EscapeVector


{-| A Bourne Shell escaped 'ByteString'. 
 -}
newtype Sh                   =  Sh (EscapeVector EscapingMode)
 deriving (Eq, Ord, Show)

instance Escape Sh where
  escape                     =  Sh . escWith classify
  unescape (Sh v)            =  stripEsc v
  bytes (Sh v)               =  interpretEsc v act finish ([], Literal)
   where
    finish Quote             =  Put.putChar '\''
    finish Backslash         =  Put.putChar '\\'
    finish Literal           =  return ()


{-| Accept the present escaping mode and desired escaping mode and yield an
    action and the resulting mode.
 -}
act :: EscapingMode -> (Char, EscapingMode) -> (Put.Put, EscapingMode)
act Quote (c, Quote)         =  (Put.putChar c                 , Quote)
act Quote (c, Literal)       =  (Put.putString ['\'', c]       , Literal)
act Quote (c, Backslash)     =  (Put.putString ['\'', '\\', c] , Literal)
act Backslash (c, Backslash) =  (Put.putChar c                 , Literal)
act Backslash (c, Quote)     =  (Put.putString ['\\', '\'', c] , Quote)
act Backslash (c, Literal)   =  (Put.putString ['\\', c]       , Literal)
act Literal (c, Literal)     =  (Put.putChar c                 , Literal)
act Literal (c, Backslash)   =  (Put.putString ['\\', c]       , Literal)
act Literal (c, Quote)       =  (Put.putString ['\'', c]       , Quote)

classify                    ::  Char -> EscapingMode
classify c | c <= '&'        =  Quote           --  0x00..0x26
           | c == '\''       =  Backslash       --  0x27
           | c <= ','        =  Quote           --  0x28..0x2c
           | c <= '9'        =  Literal         --  0x2d..0x39
           | c <= '?'        =  Quote           --  0x3a..0x3f
           | c <= 'Z'        =  Literal         --  0x40..0x5a
           | c <= '^'        =  Quote           --  0x5b..0x5e
           | c == '_'        =  Literal         --  0x5f
           | c == '`'        =  Quote           --  0x60
           | c <= 'z'        =  Literal         --  0x61..0x7a
           | c <= '\DEL'     =  Quote           --  0x7b..0x7f
           | otherwise       =  Quote           --  0x80..0xff

{-| Bourne Shell escaping modes. 
 -}
data EscapingMode            =  Backslash | Literal | Quote
 deriving (Eq, Ord, Show)

