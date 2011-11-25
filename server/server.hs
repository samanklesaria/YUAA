{-# LANGUAGE ForeignFunctionInterface #-}
module Main where
import Network.Fancy
import Foreign
import Foreign.C.Types
import Foreign.C.String
import System.IO

main = do
    streamServer serverSpec{address = (IP "localhost" 9000)} (\h a-> do
        tag <- newCString "AL"
        value <- newCString "102"
        str <- peekCString (createProtocolMessage tag value)
        hPutStrLn h str
        hFlush h)
    sleepForever

foreign import ccall "Parser.h createProtocolMessage"
     createProtocolMessage :: CString -> CString -> CString
